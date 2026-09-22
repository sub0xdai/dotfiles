#!/usr/bin/env bash
# jev_sieve_report.sh - the calibration gate for the sieve instrument.
#
# Answers one question about the instrument in use: is it qualified to mutate
# context? It is the judgment-lifecycle counterpart of __check.sh, and like that
# script it prints a verdict rather than a pile of numbers.
#
# Why one instrument and not all of them. A superseded version sits in the log
# forever, flat and unqualified, and failing on it every run would make the gate
# useless. The gate therefore targets the most recently used instrument, or the one
# named on the command line, and lists the rest for context without judging them.
#
# What feeds it. A hide candidate is a block the band marked `no`. Both sieve modes
# cache the text of every candidate, so in shadow the candidate set is a labeling
# dataset with nothing mutated. Only `on` names a stub, so only `on` yields a free
# label: a read-back of the cache file means the hide was wrong.
#
# Why the free label is not enough. A hide the agent never notices leaves no record,
# so read-backs bound the false-negative rate from below and the bound is optimistic.
# The gate treats them as necessary and not sufficient, which is why `--samples`
# exists: label a sample by hand before trusting any threshold.
#
# Usage:
#   jev_sieve_report.sh                 gate the most recently used instrument
#   jev_sieve_report.sh <question-id>   gate that one
#   jev_sieve_report.sh --samples [q]   TSV worklist for hand labeling
#
# Exit: 0 when the gated instrument is qualified, 1 when it is not.
#
# Thresholds (env):
#   JEV_SIEVE_MIN_SAMPLES  cached candidates before labeling is worth it   (100)
#   JEV_SIEVE_MIN_LIVE     on-mode hides before a bound is computed        (100)
#   JEV_SIEVE_MAX_FN_PCT   accepted upper bound on false negatives, pct    (2)
set -uo pipefail

LOG="${JEV_SIEVE_LOG:-${XDG_CACHE_HOME:-$HOME/.cache}/jev/sieve.jsonl}"
BLOCKS="${JEV_SIEVE_BLOCKS:-${XDG_CACHE_HOME:-$HOME/.cache}/jev/blocks}"
MIN_SAMPLES="${JEV_SIEVE_MIN_SAMPLES:-100}"
MIN_LIVE="${JEV_SIEVE_MIN_LIVE:-100}"
MAX_FN_PCT="${JEV_SIEVE_MAX_FN_PCT:-2}"
Z=1.645

[[ -f "$LOG" ]] || { printf 'no sieve log at %s\n' "$LOG"; exit 0; }

FILES=$(ls "$BLOCKS" 2>/dev/null | jq -Rn '[inputs]' 2>/dev/null) || FILES='[]'
[[ -n "$FILES" ]] || FILES='[]'

# Every candidate for every instrument version, deduped by cache file name.
CANDIDATES='
  [.[] | select(.kind == "decision")] as $d
  | $d
  | map(. as $e | .verdicts[]? | select(.band == "no")
        | { q: ($e.question // $e.schema // "unversioned"),
            named: ($e.namedInTask // false),
            live: ($e.mode == "on"),
            noul: .noul,
            file: "\($e.session)-\(.id)-\(.from)-\(.to).txt" })
  | unique_by(.file)
'

if [[ "${1:-}" == "--samples" ]]; then
  want="${2:-}"
  printf '# file\tinstrument\tnamedInTask\tnoul\n'
  printf '# read from %s\n' "$BLOCKS"
  jq -s -r --arg want "$want" "$CANDIDATES"' | .[]
    | select($want == "" or .q == $want)
    | [.file, .q, (.named | tostring), (.noul | tostring)] | @tsv' "$LOG"
  exit 0
fi

# One row per instrument: qid docs blocks candidates cached live-hides read-backs last-ts
GATE='
  [.[] | select(.kind == "decision")] as $d
  | [.[] | select(.kind == "recall") | .file] as $recalled
  | $d
  | group_by(.question // .schema // "unversioned")
  | .[]
  | . as $g
  | ($g[0].question // $g[0].schema // "unversioned") as $q
  | ([$g[] | .ts] | max) as $last
  | [$g[] | . as $e | .verdicts[]? | select(.band == "no")
      | { f: "\($e.session)-\(.id)-\(.from)-\(.to).txt", live: ($e.mode == "on") }] as $cand
  | [($cand | map(.f) | unique)[] | select(. as $n | $files | index($n))] as $cached
  | [($cand[] | select(.live) | .f) | unique[]] as $live
  | ([$live[] | select(. as $n | $recalled | index($n))] | length) as $rb
  | [$q, ($g | length), ([$g[] | .verdicts | length] | add // 0),
     ($cand | map(.f) | unique | length), ($cached | length), ($live | length), $rb, $last]
  | @tsv
'

ROWS=$(jq -s -r --argjson files "$FILES" "$GATE" "$LOG")
if [[ -z "$ROWS" ]]; then
  printf 'no decisions logged yet. Nothing to gate.\n'
  exit 0
fi

# The gate targets one instrument: the named one, or the most recently used.
if [[ -n "${1:-}" ]]; then
  TARGET=$(printf '%s\n' "$ROWS" | awk -F'\t' -v q="$1" '$1 == q { print $1; exit }')
  if [[ -z "$TARGET" ]]; then
    printf 'no decisions logged for instrument %s\n' "$1"
    printf 'known: %s\n' "$(printf '%s\n' "$ROWS" | cut -f1 | paste -sd' ')"
    exit 1
  fi
else
  TARGET=$(printf '%s\n' "$ROWS" |
    awk -F'\t' 'NR == 1 || $8 + 0 > m { m = $8 + 0; t = $1 } END { print t }')
fi

rc=0
while IFS=$'\t' read -r qid docs blocks cand cached live rb last; do
  [[ -z "$qid" ]] && continue
  if [[ "$qid" != "$TARGET" ]]; then
    printf 'other: %s docs=%s candidates=%s cached=%s (superseded, not gated)\n' \
      "$qid" "$docs" "$cand" "$cached"
    continue
  fi

  tenths=$(( cand == 0 ? 0 : cand * 1000 / (blocks == 0 ? 1 : blocks) ))
  printf 'instrument=%s docs=%s blocks=%s\n' "$qid" "$docs" "$blocks"
  printf '  hide candidates=%s (%s.%s%% of blocks)  cached=%s  on-mode hides=%s  read-backs=%s\n' \
    "$cand" "$(( tenths / 10 ))" "$(( tenths % 10 ))" "$cached" "$live" "$rb"

  if (( cand == 0 )); then
    printf '  verdict: NOT READY - the band holds no blocks at all, so this\n'
    printf '           instrument does not separate. Fix the question before sampling.\n'
    rc=1
  elif (( cached == 0 )); then
    printf '  verdict: NOT READY - %s candidates but nothing on disk to label.\n' "$cand"
    printf '           If shadow is running, the cache write is broken.\n'
    rc=1
  elif (( cached < MIN_SAMPLES )); then
    printf '  verdict: NOT READY - %s cached candidates, want %s. Keep sampling.\n' \
      "$cached" "$MIN_SAMPLES"
    rc=1
  elif (( live < MIN_LIVE )); then
    printf '  verdict: READY TO LABEL - %s samples. Label a batch, then run one `on`\n' "$cached"
    printf '           session for read-back labels. Run --samples for the worklist.\n'
  else
    # Wilson one-sided 95% upper bound. With zero read-backs this is z^2/(n+z^2).
    bound=$(awk -v n="$live" -v r="$rb" -v z="$Z" '
      BEGIN {
        p = r / n; z2 = z * z
        u = (p + z2 / (2 * n) + z * sqrt(p * (1 - p) / n + z2 / (4 * n * n))) / (1 + z2 / n)
        printf "%.2f", u * 100
      }')
    if awk -v b="$bound" -v m="$MAX_FN_PCT" 'BEGIN { exit !(b <= m) }'; then
      printf '  verdict: QUALIFIED - false-negative upper bound %s%%, under the %s%% bar.\n' \
        "$bound" "$MAX_FN_PCT"
    else
      printf '  verdict: NOT QUALIFIED - false-negative bound %s%%, over the %s%% bar.\n' \
        "$bound" "$MAX_FN_PCT"
      printf '           Raise the threshold, or accept fewer hides.\n'
      rc=1
    fi
  fi
done <<< "$ROWS"

exit "$rc"
