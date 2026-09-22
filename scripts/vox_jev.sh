#!/usr/bin/env bash
# vox_jev.sh - mechanical audits and Jev judgments for vox.
#
#   vox_jev.sh check    <change>          audits, no Jev, exits 1 on violation
#   vox_jev.sh gaps     <change>          one Noul per Scenario: already in the code?
#   vox_jev.sh slices   <change>          one Choice per CP: vertical slice or layer?
#   vox_jev.sh coverage <change> <CP-N>   one Noul per Scenario: does this CP's test cover it?
#
#   --dry-run   assemble and print the request, call nothing
#   --json      print the raw jev.sh envelope instead of the table
#
# Run from the repository root; the living specs are resolved as `.specify/...`.
#
# Advisory only. Every Jev judgment is printed for the agent to adjudicate; this
# script never edits a spec, a plan, or a coverage marker. The audits in `check`
# are the only thing here that can fail.
#
# Judgments go through ~/dotfiles/scripts/jev.sh, which owns batching, the pacing
# choke point, the 429 breaker, and the tagged envelope. Nothing here speaks HTTP.
#
# State versions ride in every request, so a reading from one instrument is never
# averaged with a reading from another. See ~/.pi/jev-tip.md: the instrument is
# the tuple (model, state representation, question), and it has to be pinned
# before a judgment means anything.
#
# Representations are assembled here, in code, and handed to Jev whole. The
# identifier grep is deliberately narrow: Jev gets the few code regions the spec
# names itself, never a repository to search.
set -uo pipefail

JEV_SH="${JEV_SH:-$HOME/dotfiles/scripts/jev.sh}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/jev"
LOG_FILE="$CACHE_DIR/vox.jsonl"

VOX_STATE_SCHEMA="vox.state.v1"
VOX_GAPS_Q="vox.gaps.noul.v2"
VOX_SLICES_Q="vox.slices.choice.v2"
VOX_COVERAGE_Q="vox.coverage.noul.v2"

# Pinned, not floating: the instrument is (model, state representation, question),
# and a floating alias leaves the model unpinned under the log.
VOX_MODEL="${VOX_MODEL:-jev-1.13.0}"

EVIDENCE_TOKENS="${VOX_EVIDENCE_TOKENS:-3}"
EVIDENCE_CHARS="${VOX_EVIDENCE_CHARS:-1400}"
MAX_SPEC_CHARS="${VOX_MAX_SPEC_CHARS:-100000}"

SEP=$(printf '\036')
DRY=0
JSON_OUT=0
FAILED=0

SLICE_VERTICAL="One behavior delivered end to end through every layer it touches"
SLICE_HORIZONTAL="One layer across many behaviors, delivering nothing on its own"

# Each question names the entry it is about, by that entry's path in `state`.
# Question ids are the caller's handle and the API does not send them to the model,
# so a question asking about "this question's key" names nothing: every sibling
# question reads identically and so does every answer. Per-item paths are TypeSafe's
# own fan-out shape (`items[i]`), and their guidance for indirection is to identify
# the relevant parts of state by name.
slice_instruction() {
  local s="Is the checkpoint in \`checkpoints[$1].plan\` a vertical slice "
  s+="or a horizontal layer? A vertical slice delivers one behavior end to "
  s+="end and is testable on its own. A horizontal layer is one layer across "
  s+="many behaviors and cannot be verified until a later checkpoint lands."
  printf '%s' "$s"
}
gaps_instruction() {
  local s="Is the behavior described in \`scenarios[$1].scenario_text\` already "
  s+="present in the code shown in \`scenarios[$1].code\`? "
  s+="Answer yes only if that code already implements it."
  printf '%s' "$s"
}
coverage_instruction() {
  local s="Does the test code shown in \`scenarios[$1].code\` exercise the "
  s+="behavior described in \`scenarios[$1].scenario_text\`? "
  s+="Answer yes only if the tests assert it, not merely mention it."
  printf '%s' "$s"
}

die() { printf 'vox_jev.sh: %s\n' "$1" >&2; exit 2; }
fail() { printf 'FAIL  %s\n' "$1"; FAILED=$(( FAILED + 1 )); }
pass() { printf 'ok    %s\n' "$1"; }

usage() {
  awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 && !/^$/ {exit}' "$0"
}

# ---------------------------------------------------------------- text extraction

# Print every block starting with a line matching $2, each terminated by $SEP, so
# a block may carry newlines without ambiguity. A block ends at the next heading
# of any depth. Reads stdin when $1 is `-`.
blocks() {
  awk -v start="$2" -v sep="$SEP" '
    $0 ~ start { if (b != "") printf "%s%s", b, sep; b = $0 "\n"; next }
    b != "" {
      if ($0 ~ /^#{2,4} /) { printf "%s%s", b, sep; b = ""; next }
      b = b $0 "\n"
    }
    END { if (b != "") printf "%s%s", b, sep }
  ' "${1:--}"
}

# Like blocks, but a block ends only at a heading shallower than $2 levels, so a
# requirement keeps the `#### Scenario:` subsections nested under it.
sections() {
  awk -v start="$2" -v shallow="^#{2,"$3"} " -v sep="$SEP" '
    $0 ~ start { if (b != "") printf "%s%s", b, sep; b = $0 "\n"; next }
    b != "" {
      if ($0 ~ shallow) { printf "%s%s", b, sep; b = ""; next }
      b = b $0 "\n"
    }
    END { if (b != "") printf "%s%s", b, sep }
  ' "${1:--}"
}

headline() { printf '%s' "${1%%$'\n'*}" | sed -E 's/^#+ //'; }
strip_prefix() { printf '%s' "$1" | sed -E "s/^$2: ?//"; }

# Identifier-shaped tokens the text names itself, in document order, deduped.
identifiers() {
  local pattern='`[^`]+`'
  pattern+='|[a-z][a-z0-9]*_[a-z0-9_]+'
  pattern+='|[a-z][a-zA-Z0-9]*[A-Z][a-zA-Z0-9]*'
  pattern+='|[a-z0-9_./-]+\.[a-z]{2,5}'
  printf '%s' "$1" | grep -oE "$pattern" | tr -d '`' \
    | awk 'length($0) >= 4 && !seen[$0]++' | head -n 6
}

# ------------------------------------------------------------------- resolution

resolve_change() {
  local name="$1" cand
  for cand in "$name" ".specify/changes/$name" ".specify/specs/$name"; do
    [[ -d "$cand" ]] && { printf '%s' "${cand%/}"; return 0; }
  done
  cand=$(ls -d .specify/changes/*/ .specify/specs/*/ 2>/dev/null | grep -F -- "$name" | head -n 1)
  [[ -n "$cand" ]] && { printf '%s' "${cand%/}"; return 0; }
  return 1
}

# Delta layout has per-domain specs; legacy has one spec.md beside the plan.
spec_files() {
  local dir="$1" f
  for f in "$dir"/specs/*/spec.md; do [[ -f "$f" ]] && printf '%s\n' "$f"; done
  [[ -f "$dir/spec.md" ]] && printf '%s\n' "$dir/spec.md"
  return 0
}

# ---------------------------------------------------------------- evidence

# Code the spec names itself. Narrow on purpose, so the judgment stays
# identifiable instead of becoming a search problem.
# ponytail: identifiers, not symbols resolved through a language server. Replace
# when a spec's own names stop finding the code that implements it.
evidence_items() {
  local text="$1" tok file hit line start end snippet taken=0 i
  local -a items=()
  while IFS= read -r tok; do
    (( taken >= EVIDENCE_TOKENS )) && break
    file=$(git grep -l -F -e "$tok" -- . ':(exclude).specify' 2>/dev/null | head -n 1)
    [[ -z "$file" ]] && continue
    # -h suppresses the filename prefix, so the first field is the line number.
    hit=$(git grep -h -n -m1 -F -e "$tok" -- "$file" 2>/dev/null | head -n 1)
    [[ -z "$hit" ]] && continue
    line="${hit%%:*}"
    [[ "$line" =~ ^[0-9]+$ ]] || continue
    start=$(( line > 6 ? line - 6 : 1 ))
    end=$(( line + 14 ))
    snippet=$(sed -n "${start},${end}p" "$file" 2>/dev/null | cut -c1-200)
    [[ -z "$snippet" ]] && continue
    items+=("${tok} at ${file}:${line}"$'\n'"${snippet:0:EVIDENCE_CHARS}")
    taken=$(( taken + 1 ))
  done < <(identifiers "$text")
  (( ${#items[@]} )) || return 0
  printf '%s' "${items[0]}"
  for (( i = 1; i < ${#items[@]}; i++ )); do printf '%s%s' "$SEP" "${items[$i]}"; done
  return 0
}

# A CP's Touches line names files; those are the evidence for a coverage judgment.
cat_sources() {
  local files="$1" f out="" first=1
  for f in $files; do
    [[ -f "$f" ]] || continue
    if (( first )); then out="$f"$'\n'; first=0; else out="$out$SEP$f"$'\n'; fi
    out="$out$(cut -c1-200 "$f" | sed -n '1,120p')"
  done
  printf '%s' "$out"
}

to_array() {
  local raw="$1" x
  [[ -z "$raw" ]] && { printf '[]'; return; }
  local -a items=()
  while IFS= read -r -d "$SEP" x; do items+=("$x"); done <<<"$raw$SEP"
  jq -cn --args '$ARGS.positional' "${items[@]}"
}

# ------------------------------------------------------------------------ the call

log_event() {
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 0
  printf '%s\n' "$1" >>"$LOG_FILE" 2>/dev/null || true
}

label_for() {
  case "$1:$2" in
    gaps:yes | coverage:yes) printf 'satisfied' ;;
    gaps:no)                 printf 'GAP' ;;
    coverage:no)             printf 'NOT COVERED' ;;
    *)                       printf 'uncertain - read it yourself' ;;
  esac
}

print_table() {
  local envelope="$1" mode="$2" id a b c note
  if [[ "$mode" == "slices" ]]; then
    while IFS=$'\t' read -r id a b c; do
      [[ -z "$id" ]] && continue
      # A near-zero confidence is not a weak vote, it is no vote. Say so, or the
      # caller reads a coin flip as a finding.
      note=""
      if awk -v v="$c" 'BEGIN { exit !(v < 0.2) }'; then
        note="  <- confidence $c, treat as no signal"
      fi
      if [[ "$a" == "horizontal" ]]; then
        printf '%-4s %-11s %-8s %-8s %s\n' "$id" "$a" "p=$b" "c=$c" \
          "HORIZONTAL LAYER - re-slice$note"
      else
        printf '%-4s %-11s %-8s %-8s %s\n' "$id" "$a" "p=$b" "c=$c" \
          "vertical slice$note"
      fi
    done < <(jq -r '.verdicts | to_entries[] |
      [.key, (.value.choice // "?"), ((.value.probability // 0) | tostring),
       ((.value.confidence // 0) | tostring)] | @tsv' <<<"$envelope")
    return 0
  fi
  while IFS=$'\t' read -r id a b; do
    [[ -z "$id" ]] && continue
    printf '%-4s %-9s %-8s %s\n' "$id" "$a" "n=$b" "$(label_for "$mode" "$a")"
  done < <(jq -r '.verdicts | to_entries[] |
    [.key, (.value.band // "?"), ((.value.noul // 0) | tostring)] | @tsv' <<<"$envelope")
  return 0
}

ask() {
  local spec="$1" mode="$2" qid="$3" envelope status len
  if (( DRY )); then printf '%s\n' "$spec" | jq .; return 0; fi
  len=${#spec}
  if (( len > MAX_SPEC_CHARS )); then
    printf 'vox_jev.sh: request is %d chars, over the %d budget\n' "$len" "$MAX_SPEC_CHARS" >&2
  fi

  envelope=$("$JEV_SH" --spec - <<<"$spec") || die "jev.sh did not return an envelope"
  status=$(jq -r '.status // "error"' <<<"$envelope")

  if jq -e . <<<"$envelope" >/dev/null 2>&1; then
    log_event "$(jq -cn --arg mode "$mode" --arg qid "$qid" --argjson env "$envelope" \
      '{ts: (now * 1000 | floor), kind: "decision", mode: $mode, question: $qid,
        envelope: $env}')"
  fi

  (( JSON_OUT )) && printf '%s\n' "$envelope" | jq .
  if [[ "$status" != "ok" ]]; then
    printf 'jev: %s %s\n' "$status" "$(jq -r '.reason // ""' <<<"$envelope")" >&2
    printf 'Proceed without the judgment. Do not read its absence as a verdict.\n' >&2
    return 2
  fi
  (( JSON_OUT )) && return 0
  print_table "$envelope" "$mode"
  return 0
}

emit_spec() {
  local mode="$1" qid="$2" change="$3" q="$4" entries="$5" key spec
  case "$mode" in
    gaps)     key="scenarios" ;;
    coverage) key="scenarios" ;;
    *)        key="checkpoints" ;;
  esac
  spec=$(jq -cn --arg schema "$VOX_STATE_SCHEMA" --arg qid "$qid" --arg change "$change" \
    --arg key "$key" --arg m "$VOX_MODEL" --argjson q "$q" --argjson e "$entries" \
    '{state: {schema: $schema, question: $qid, change: $change, ($key): $e},
      model: $m, questions: $q}')
  ask "$spec" "$mode" "$qid"
}

# ------------------------------------------------------------------- judgments

judge_scenarios() {
  local mode="$1" builder="$2" change="$3" source_filter="${4:-}"
  local q='{}' entries='[]' n=0 file rq rs rt rdesc st body ev
  while IFS= read -r file; do
    # Each requirement keeps its own scenarios. Iterating the file per requirement
    # instead would judge every scenario once per requirement, under the wrong one.
    while IFS= read -r -d "$SEP" rq; do
      [[ -z "$rq" ]] && continue
      rt=$(strip_prefix "$(headline "$rq")" Requirement)
      # The description is the SHALL statement; the scenarios are separated out so
      # the same identifiers are not counted twice in the evidence grep.
      rdesc=$(printf '%s' "$rq" | awk '/^#### Scenario:/ { exit } { print }')
      while IFS= read -r -d "$SEP" rs; do
        [[ -z "$rs" ]] && continue
        n=$(( n + 1 ))
        st=$(strip_prefix "$(headline "$rs")" Scenario)
        # GIVEN/WHEN/THEN is the distinction being judged, so it travels whole.
        body="${rdesc}"$'\n'"${rs}"
        if [[ -n "$source_filter" ]]; then ev=$(cat_sources "$source_filter")
        else ev=$(evidence_items "$body"); fi
        # The entry at index n-1 is the one this question is about, because n
        # counts scenarios while the array is appended in the same order.
        q=$(jq -c --arg k "s$n" --arg i "$("$builder" "$(( n - 1 ))")" \
          '. + {($k): {type: "noul", instructions: $i}}' <<<"$q")
        entries=$(jq -c --arg id "s$n" --arg req "$rt" --arg rtext "${rdesc%$'\n'}" \
          --arg scen "$st" --arg stext "${rs%$'\n'}" \
          --argjson ev "$(to_array "$ev")" \
          '. + [{id: $id, requirement: $req, requirement_text: $rtext,
                 scenario: $scen, scenario_text: $stext, code: $ev}]' <<<"$entries")
      done < <(printf '%s' "$rq" | blocks - '^#### Scenario:')
    done < <(sections "$file" '^### Requirement:' 3)
  done < <(spec_files "$change")
  (( n )) || die "no requirements with scenarios found under $change"
  emit_spec "$mode" "$( [[ "$mode" == gaps ]] && printf '%s' "$VOX_GAPS_Q" \
    || printf '%s' "$VOX_COVERAGE_Q" )" "$change" "$q" "$entries"
}

cmd_slices() {
  local change="$1" plan q='{}' entries='[]' n=0 blk title body spec
  plan="$change/IMPLEMENTATION_PLAN.md"
  [[ -f "$plan" ]] || die "no IMPLEMENTATION_PLAN.md under $change"
  while IFS= read -r -d "$SEP" blk; do
    [[ -z "$blk" ]] && continue
    n=$(( n + 1 ))
    title=$(headline "$blk")
    body="${blk:0:3000}"
    q=$(jq -c --arg k "c$n" --arg i "$(slice_instruction "$(( n - 1 ))")" \
      --arg v "$SLICE_VERTICAL" --arg h "$SLICE_HORIZONTAL" \
      '. + {($k): {type: "choice", instructions: $i,
                    criteria: {vertical: $v, horizontal: $h}}}' <<<"$q")
    entries=$(jq -c --arg id "c$n" --arg title "$title" --arg body "$body" \
      '. + [{id: $id, checkpoint: $title, plan: $body}]' <<<"$entries")
  done < <(sections "$plan" '^### CP-' 3)
  (( n )) || die "no checkpoints found in $plan"
  spec=$(jq -cn --arg schema "$VOX_STATE_SCHEMA" --arg qid "$VOX_SLICES_Q" \
    --arg change "$change" --arg m "$VOX_MODEL" --argjson q "$q" --argjson e "$entries" \
    '{state: {schema: $schema, question: $qid, change: $change, checkpoints: $e},
      model: $m, questions: $q}')
  ask "$spec" "slices" "$VOX_SLICES_Q"
}

# ---------------------------------------------------------------------- audits

# Every Scenario region owns exactly one coverage marker.
audit_markers() {
  local file="$1" bad
  bad=$(awk '
    /^#{2,4} / {
      if (name != "" && n != 1) printf "  %s (markers: %d)\n", name, n
      if ($0 ~ /^#### Scenario:/) { name = $0; n = 0 } else { name = ""; n = 0 }
      next
    }
    name != "" && /vox:covered/ { n++ }
    END { if (name != "" && n != 1) printf "  %s (markers: %d)\n", name, n }
  ' "$file")
  if [[ -n "$bad" ]]; then
    fail "$file: scenarios without exactly one vox:covered marker"
    printf '%s\n' "${bad%$'\n'}"
  else
    # Regions are clean, so a count mismatch is a marker that never sat in a
    # scenario region at all: a stray or an overflow past the last scenario.
    local scenarios markers
    scenarios=$(grep -c '^#### Scenario:' "$file")
    markers=$(grep -c 'vox:covered' "$file")
    if (( markers != scenarios )); then
      fail "$file: $markers markers for $scenarios scenarios, marker outside a scenario region"
    fi
  fi
  return 0
}

# Every Requirement region owns at least one Scenario.
# A Scenario heading counts before anything is flushed, otherwise the requirement
# that owns it has not seen its own scenario yet and reports zero.
audit_requirement_scenarios() {
  local file="$1" bad
  bad=$(awk '
    /^#{2,4} / {
      if ($0 ~ /^#### Scenario:/ && name != "") { n++; next }
      if (name != "" && n < 1) printf "  %s (scenarios: %d)\n", name, n
      if ($0 ~ /^### Requirement:/) { name = $0; n = 0 } else { name = ""; n = 0 }
      next
    }
    END { if (name != "" && n < 1) printf "  %s (scenarios: %d)\n", name, n }
  ' "$file")
  if [[ -n "$bad" ]]; then
    fail "$file: requirements with no scenario"
    printf '%s\n' "${bad%$'\n'}"
  fi
  return 0
}

# Every CP region owns a Verification line.
audit_cp_verification() {
  local plan="$1" bad
  bad=$(awk '
    /^#{2,4} / {
      if (name != "" && n < 1) printf "  %s\n", name
      if ($0 ~ /^### CP-/) { name = $0; n = 0 } else { name = ""; n = 0 }
      next
    }
    name != "" && /\*\*Verification\*\*/ { n++ }
    END { if (name != "" && n < 1) printf "  %s\n", name }
  ' "$plan")
  if [[ -n "$bad" ]]; then
    fail "$plan: checkpoints without a verification command"
    printf '%s\n' "${bad%$'\n'}"
  fi
  return 0
}

cmd_check() {
  local change="$1" plan file total done_n bad found
  plan="$change/IMPLEMENTATION_PLAN.md"

  if [[ -f "$plan" ]]; then
    total=$(grep -c '^### CP-' "$plan")
    done_n=$(grep -c '^### CP-.*✅' "$plan")
    if (( total > 0 && done_n == total )); then
      pass "$plan: all $total checkpoints marked done"
    else
      fail "$plan: $done_n of $total checkpoints marked done"
      grep -n '^### CP-' "$plan" | grep -v '✅' | sed 's/^/  /'
    fi
    audit_cp_verification "$plan"
  else
    fail "$change: no IMPLEMENTATION_PLAN.md"
  fi

  found=0
  while IFS= read -r file; do
    found=1
    # Archive strips coverage markers on purpose, so the marker audit is about
    # pending changes only. Flagging an archived delta here would be noise.
    if [[ "$change" == *archive* ]]; then
      pass "$file: archived, coverage markers already stripped"
    else
      audit_markers "$file"
    fi
    audit_requirement_scenarios "$file"
  done < <(spec_files "$change")
  (( found )) || fail "$change: no spec.md found"

  bad=$(grep -rnE '^## (ADDED|MODIFIED|REMOVED)' .specify/specs/ 2>/dev/null)
  if [[ -n "$bad" ]]; then
    fail "a living spec carries delta headers"
    printf '%s\n' "$bad" | sed 's/^/  /'
  else
    pass "living specs carry no delta headers"
  fi

  bad=$(grep -rn 'vox:covered' .specify/archive/ .specify/spec-archive/ 2>/dev/null)
  if [[ -n "$bad" ]]; then
    fail "coverage markers left in archived deltas"
    printf '%s\n' "$bad" | sed 's/^/  /'
  else
    pass "no coverage markers in the archive"
  fi

  if (( FAILED )); then
    printf '\n%d audit failure(s). Resolve before archive.\n' "$FAILED"
    return 1
  fi
  printf '\nall audits pass\n'
  return 0
}

# ------------------------------------------------------------------------ main

CMD=""
CHANGE=""
CP=""
while (( $# )); do
  case "$1" in
    --dry-run) DRY=1; shift ;;
    --json)    JSON_OUT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        die "unknown flag: $1" ;;
    *)
      if [[ -z "$CMD" ]]; then CMD="$1"
      elif [[ -z "$CHANGE" ]]; then CHANGE="$1"
      elif [[ -z "$CP" ]]; then CP="$1"
      else die "unexpected argument: $1"; fi
      shift
      ;;
  esac
done

[[ -n "$CMD" ]] || { usage; exit 2; }
[[ -n "$CHANGE" ]] || die "$CMD needs a change name"
[[ -d .specify ]] || die "run this from the repository root (no .specify/ here)"

DIR=$(resolve_change "$CHANGE") || die "no change or spec matching: $CHANGE"

case "$CMD" in
  check)
    cmd_check "$DIR"
    ;;
  gaps)
    judge_scenarios gaps gaps_instruction "$DIR"
    ;;
  coverage)
    [[ -n "$CP" ]] || die "coverage needs a checkpoint id, e.g. coverage <change> CP-1"
    plan="$DIR/IMPLEMENTATION_PLAN.md"
    [[ -f "$plan" ]] || die "no IMPLEMENTATION_PLAN.md under $DIR"
    touched=$(awk -v want="$CP" '
      $0 ~ /^### CP-/ { on = (index($0, want) > 0) }
      on && /\*\*Touches\*\*/ {
        sub(/^.*\*\*Touches\*\*: */, ""); gsub(/[`,]/, " "); print; exit
      }' "$plan" | tr ' ' '\n' | grep -E '\.(rs|ts|tsx|js|py|go|sh)$' | sort -u)
    [[ -n "$touched" ]] || die "no files listed in $CP's Touches line"
    judge_scenarios coverage coverage_instruction "$DIR" "$touched"
    ;;
  slices)
    cmd_slices "$DIR"
    ;;
  *)
    die "unknown subcommand: $CMD"
    ;;
esac
