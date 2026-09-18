#!/usr/bin/env bash
# jev.sh - batch typed judgments from TypeSafe System One (Jev).
#
# Emits one JSON object on stdout and exits 0 for every judgment outcome,
# including failure, so a caller never has to tell "no verdict" apart from
# "broken script". Bad arguments are the exception: they exit 2 with a message
# on stderr, because that is a programmer error and not a judgment.
#
# Usage
#   jev.sh --noul 'Is this an account takeover signal?' < evidence.txt
#   jev.sh --choice 'Which queue?' --option support='ordinary' --option sec='incident'
#   jev.sh --score 'How grounded?' --level low='unsafe' --level high='grounded'
#   jev.sh --spec request.json        # raw {state, model, questions} body
#
# Questions batch: repeat the question flags and one request carries them all.
# Adding questions costs only question tokens, so one call per decision cycle.
#
# Flags
#   --state TEXT | --state-file FILE   default: stdin (string state)
#   --threshold N            noul band threshold (default 0.70)
#   --uncertainty-margin N   half-width of the uncertain band (default 0.10)
#   --model M                default jev-latest
#   --timeout S              per-attempt timeout (default 10)
#   --stub                   deterministic offline judge, no network
#   --no-pace                skip the choke point (tests, replay)
#   --verbose                request and response trace on stderr
#
# Envelope. `status` is the discriminant; there is no boolean gate and no
# optional error string sitting beside a success payload.
#   {"schema_version":"1","status":"ok","model":..,"answers":{..},
#    "verdicts":{..},"usage":{..}}
#   {"schema_version":"1","status":"disabled"}
#   {"schema_version":"1","status":"error","reason":"timeout"}
#
# `verdicts` adds local banding on top of the raw answers: a noul gains
# threshold, margin, and a band of yes|no|uncertain. The uncertain band is a
# decision for the caller, never rounded away here.
#
# Credentials: ~/.config/typesafe/credentials.env (TYPESAFE_API_KEY=...), mode
# 600. Override the path with JEV_CRED_FILE. A key is never taken from argv.
#
# Pacing: one process-wide 2s choke point plus an escalating 429 breaker. The
# published quota is 1,200 req/min but the real one is unpublished, so this
# stays modest on purpose. See ~/.pi/typesafe-jev-assessment.md section 8.3.
#
# `set -e` is deliberately absent: the contract is to always emit an envelope,
# and errexit would abort before the error envelope could be written.

set -uo pipefail

ENDPOINT="${JEV_ENDPOINT:-https://api.typesafe.ai/v1/systemone}"
CRED_FILE="${JEV_CRED_FILE:-$HOME/.config/typesafe/credentials.env}"
CACHE_DIR="${JEV_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/jev}"
PACE_FILE="$CACHE_DIR/last_request"
BREAKER_FILE="$CACHE_DIR/breaker"
MIN_INTERVAL="${JEV_MIN_INTERVAL:-2}"
MAX_COOLDOWN=3600

MODEL="${JEV_MODEL:-jev-latest}"
THRESHOLD="${JEV_THRESHOLD:-0.70}"
MARGIN="${JEV_UNCERTAINTY_MARGIN:-0.10}"
TIMEOUT="${JEV_TIMEOUT:-10}"

STATE=""
STATE_FILE=""
SPEC=""
STUB=0
PACE=1
VERBOSE=0
CUR=-1
POST_CODE=""
POST_FILE=""
declare -a NAMES=() TYPES=() INSTRS=() CRIT=()

cleanup() {
  [[ -n "$POST_FILE" && -f "$POST_FILE" ]] && rm -f "$POST_FILE"
  return 0
}
trap cleanup EXIT

die() {
  printf 'jev.sh: %s\n' "$1" >&2
  exit 2
}

trace() {
  (( VERBOSE )) || return 0
  printf 'jev.sh: %s\n' "$1" >&2
}

emit_error() {
  jq -cn --arg r "$1" '{schema_version:"1",status:"error",reason:$r}'
  exit 0
}

emit_disabled() {
  jq -cn '{schema_version:"1",status:"disabled"}'
  exit 0
}

emit_stub() {
  local answers verdicts
  answers=$(stub_answers "$1")
  verdicts=$(band_verdicts "$answers") || emit_error invalid
  jq -cn --arg model "$MODEL" --argjson a "$answers" --argjson v "$verdicts" \
    '{schema_version:"1",status:"ok",stub:true,model:$model,
      answers:$a,verdicts:$v,usage:null}'
  exit 0
}

need_arg() {
  (( $# >= 2 )) || die "$1 needs a value"
  printf '%s' "$2"
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --state)              STATE=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --state-file)         STATE_FILE=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --spec)               SPEC=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --noul)               add_question noul "$(need_arg "$1" "${2:-}")"; shift 2 ;;
      --choice)             add_question choice "$(need_arg "$1" "${2:-}")"; shift 2 ;;
      --score)              add_question score "$(need_arg "$1" "${2:-}")"; shift 2 ;;
      --option|--level)     add_criterion "$(need_arg "$1" "${2:-}")"; shift 2 ;;
      --threshold)          THRESHOLD=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --uncertainty-margin) MARGIN=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --model)              MODEL=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --timeout)            TIMEOUT=$(need_arg "$1" "${2:-}"); shift 2 ;;
      --stub)               STUB=1; shift ;;
      --no-pace)            PACE=0; shift ;;
      --verbose)            VERBOSE=1; shift ;;
      -h|--help)            usage; exit 0 ;;
      *)                    die "unknown argument: $1" ;;
    esac
  done
}

usage() {
  awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "$0"
}

add_question() {
  NAMES+=("q$(( ${#NAMES[@]} + 1 ))")
  TYPES+=("$1")
  INSTRS+=("$2")
  CRIT+=('{}')
  CUR=$(( ${#NAMES[@]} - 1 ))
}

# `--option k=v` and `--level k=v` both land in that question's criteria map,
# which the API uses as the option set for choice and the levels for score.
add_criterion() {
  local pair="$1" k v
  (( CUR >= 0 )) || die "--option/--level before any question flag"
  [[ "$pair" == *=* ]] || die "expected key=value, got: $pair"
  k="${pair%%=*}"; v="${pair#*=}"
  CRIT[$CUR]=$(jq -c --arg k "$k" --arg v "$v" '. + {($k): $v}' <<<"${CRIT[$CUR]}")
}

# Trailing newline is trimmed so a state file does not carry one into the
# model's view of the text.
slurp() {
  local text
  text=$(cat "${1:--}")
  printf '%s' "${text%$'\n'}"
}

resolve_state() {
  if [[ -n "$STATE_FILE" ]]; then
    [[ -f "$STATE_FILE" ]] || die "no such state file: $STATE_FILE"
    STATE=$(slurp "$STATE_FILE")
  elif [[ -z "$STATE" ]]; then
    [[ -t 0 ]] && die "no state: pass --state, --state-file, or pipe stdin"
    STATE=$(slurp -)
  fi
  [[ -n "$STATE" ]] || die "state is empty"
}

build_questions() {
  local out='{}' i n t ins c
  for (( i=0; i<${#NAMES[@]}; i++ )); do
    n="${NAMES[$i]}"; t="${TYPES[$i]}"; ins="${INSTRS[$i]}"; c="${CRIT[$i]}"
    out=$(jq -c --arg n "$n" --arg t "$t" --arg i "$ins" --argjson c "$c" \
      '. + {($n): ({type:$t, instructions:$i}
                     + (if ($c | length) > 0 then {criteria:$c} else {} end))}' \
      <<<"$out") || die "could not assemble question $n"
  done
  printf '%s' "$out"
}

build_request() {
  jq -cn --argjson state "$1" --arg model "$MODEL" --argjson q "$2" \
    '{state:$state, model:$model, questions:$q}'
}

# Deterministic offline judge. The noul value varies with instruction text so
# all three bands are reachable in tests; choice and score pick the first key.
stub_answers() {
  jq -c '
    to_entries | map(
      .key as $k | .value as $v | ($v.criteria // {}) as $c |
      { key: $k,
        value: (
          if $v.type == "noul" then
            {type:"noul", noul: ((($v.instructions | length) % 9) / 10)}
          elif $v.type == "choice" then
            {type:"choice", choice: ($c | keys_unsorted[0]),
             probabilities: ($c | to_entries
                               | map({key:.key,
                                      value: (if .key == ($c | keys_unsorted[0])
                                              then 1 else 0 end)})
                               | from_entries),
             confidence: 1}
          else
            {type:"score", score: 1, legend: $c,
             probabilities: ($c | to_entries
                               | map({key:.key,
                                      value: (if .key == ($c | keys_unsorted[0])
                                              then 1 else 0 end)})
                               | from_entries),
             confidence: 1}
          end)
      }
    ) | from_entries' <<<"$1"
}

band_verdicts() {
  jq -c --argjson t "$THRESHOLD" --argjson m "$MARGIN" '
    to_entries | map(
      .key as $k | .value as $v |
      { key: $k,
        value: (
          if $v.type == "noul" then
            {type:"noul", noul:$v.noul, threshold:$t, margin:$m,
             band: (if $v.noul >= ($t + $m) then "yes"
                    elif $v.noul <= ($t - $m) then "no"
                    else "uncertain" end)}
          elif $v.type == "choice" then
            {type:"choice", choice:$v.choice,
             probability: ($v.probabilities[$v.choice] // null),
             confidence: ($v.confidence // null)}
          else
            {type:"score", score:$v.score, confidence: ($v.confidence // null)}
          end)
      }
    ) | from_entries' <<<"$1"
}

resolve_key() {
  local k="${TYPESAFE_API_KEY:-}" mode
  if [[ -z "$k" && -f "$CRED_FILE" ]]; then
    mode=$(stat -c '%a' "$CRED_FILE" 2>/dev/null || printf '')
    [[ "$mode" == "600" ]] || printf 'jev.sh: warning: %s mode is %s, want 600\n' \
      "$CRED_FILE" "$mode" >&2
    k=$(grep -E '^TYPESAFE_API_KEY=' "$CRED_FILE" | tail -1 | cut -d= -f2-)
    k="${k%\"}"; k="${k#\"}"; k="${k%\'}"; k="${k#\'}"
  fi
  printf '%s' "$k"
}

# One process-wide choke point. Returns 1 while the breaker is open, which the
# caller reports as rate_limited without touching the network, so a ban can
# never be refreshed by a retry loop.
pace_gate() {
  (( PACE )) || return 0
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 0
  local open_until=0 last=0 now wait
  if [[ -f "$BREAKER_FILE" ]]; then
    open_until=$(jq -r '.until // 0' "$BREAKER_FILE" 2>/dev/null) || open_until=0
    [[ "$open_until" =~ ^[0-9]+$ ]] || open_until=0
  fi
  now=$(date +%s)
  (( now < open_until )) && return 1
  [[ -f "$PACE_FILE" ]] && last=$(cat "$PACE_FILE" 2>/dev/null || printf '0')
  [[ "$last" =~ ^[0-9]+$ ]] || last=0
  wait=$(( MIN_INTERVAL - (now - last) ))
  (( wait > 0 )) && sleep "$wait"
  date +%s > "$PACE_FILE" 2>/dev/null || true
  return 0
}

record_success() {
  rm -f "$BREAKER_FILE" 2>/dev/null || true
}

record_429() {
  local fails=1 cooldown
  if [[ -f "$BREAKER_FILE" ]]; then
    fails=$(( $(jq -r '.failures // 0' "$BREAKER_FILE" 2>/dev/null || printf '0') + 1 ))
  fi
  cooldown=$(( 60 * (2 ** (fails - 1)) ))
  (( cooldown > MAX_COOLDOWN )) && cooldown=$MAX_COOLDOWN
  jq -cn --argjson f "$fails" --argjson u "$(( $(date +%s) + cooldown ))" \
    '{failures:$f, until:$u}' > "$BREAKER_FILE" 2>/dev/null || true
}

# Writes the body to POST_FILE and the HTTP status, or a transport class, to
# POST_CODE. It never emits: a command substitution would swallow the envelope
# and exit only the subshell, so the decision belongs to the caller.
post() {
  local raw rc
  POST_FILE=$(mktemp) || die "mktemp failed"
  raw=$(curl -sS -m "$TIMEOUT" -o "$POST_FILE" -w '%{http_code}' -X POST "$ENDPOINT" \
    -H "Authorization: Bearer $1" -H 'Content-Type: application/json' \
    --data-binary "$2" 2>/dev/null)
  rc=$?
  if (( rc != 0 )); then
    (( rc == 28 )) && POST_CODE=timeout || POST_CODE=transport
    return 0
  fi
  POST_CODE=$(printf '%s' "$raw" | tr -d '[:space:]')
  [[ "$POST_CODE" =~ ^[0-9]+$ ]] || POST_CODE=transport
}

main() {
  parse_args "$@"

  local req answers verdicts usage model

  if [[ -n "$SPEC" ]]; then
    if [[ "$SPEC" == "-" ]]; then
      req=$(slurp -)
    else
      [[ -f "$SPEC" ]] || die "no such spec file: $SPEC"
      req=$(cat "$SPEC")
    fi
    jq -e . <<<"$req" >/dev/null 2>&1 || die "spec is not valid JSON"
    model=$(jq -r '.model // empty' <<<"$req")
    MODEL="${model:-$MODEL}"
    req=$(jq -c --arg m "$MODEL" '. + {model:$m}' <<<"$req")
    (( STUB )) && emit_stub "$(jq -c '.questions // {}' <<<"$req")"
  else
    (( ${#NAMES[@]} > 0 )) || die "no questions: pass --noul/--choice/--score"
    resolve_state
    (( STUB )) && emit_stub "$(build_questions)"
    req=$(build_request "$(jq -cn --arg s "$STATE" '$s')" "$(build_questions)")
  fi

  local key
  key=$(resolve_key)
  [[ -n "$key" ]] || emit_disabled

  pace_gate || emit_error rate_limited
  trace "POST $ENDPOINT"
  post "$key" "$req"

  case "$POST_CODE" in
    200)      ;;
    timeout)  emit_error timeout ;;
    transport) emit_error transport ;;
    401)      emit_error unauthorized ;;
    422)      emit_error invalid ;;
    429)      record_429; emit_error rate_limited ;;
    529)      emit_error overloaded ;;
    *)        emit_error error ;;
  esac
  record_success

  answers=$(jq -c '.answers // empty' "$POST_FILE" 2>/dev/null)
  [[ -n "$answers" && "$answers" != "null" ]] || emit_error invalid
  usage=$(jq -c '.usage // null' "$POST_FILE" 2>/dev/null) || usage=null
  model=$(jq -r '.model // empty' "$POST_FILE" 2>/dev/null)
  verdicts=$(band_verdicts "$answers") || emit_error invalid

  jq -cn --arg model "${model:-$MODEL}" --argjson a "$answers" \
    --argjson v "$verdicts" --argjson u "$usage" \
    '{schema_version:"1",status:"ok",model:$model,answers:$a,verdicts:$v,usage:$u}'
}

main "$@"
