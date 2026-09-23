#!/usr/bin/env bash
# ponytail: bash next to its subject, matching __check.sh and jev_sieve_report.sh.
set -uo pipefail

JEV_SH="${JEV_SH:-$HOME/dotfiles/scripts/jev.sh}"
PORT=$(( 21000 + ($$ % 20000) ))
KEY="ts_test_key_do_not_leak_$$"
TMP=$(mktemp -d) || exit 2
REQ="$TMP/req.txt"
FAILED=0

cleanup() {
  [[ -n "${NC_PID:-}" ]] && kill "$NC_PID" 2>/dev/null
  rm -rf "$TMP"
  return 0
}
trap cleanup EXIT

printf 'TYPESAFE_API_KEY=%s\n' "$KEY" >"$TMP/creds.env"
chmod 600 "$TMP/creds.env"

fail() { printf 'FAIL  %s\n' "$1"; FAILED=1; }
pass() { printf 'ok    %s\n' "$1"; }

nc -l -p "$PORT" >"$REQ" 2>/dev/null &
NC_PID=$!
sleep 0.3

JEV_CRED_FILE="$TMP/creds.env" \
JEV_ENDPOINT="http://127.0.0.1:$PORT/v1/systemone" \
JEV_CACHE_DIR="$TMP/cache" \
  "$JEV_SH" --noul 'is this a probe?' --state 'probe' --no-pace --timeout 3 \
  >"$TMP/envelope.json" 2>"$TMP/stderr.txt" &
JEV_PID=$!

ARGV=""
for _ in $(seq 1 60); do
  for pid in $(pgrep -x curl 2>/dev/null); do
    line=$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null) || continue
    [[ "$line" == *":$PORT"* ]] || continue
    ARGV="$line"
  done
  [[ -n "$ARGV" ]] && break
  sleep 0.05
done
wait "$JEV_PID" 2>/dev/null

if [[ -z "$ARGV" ]]; then
  fail "no curl child for port $PORT was observed"
else
  if [[ "$ARGV" == *"$KEY"* ]]; then
    fail "the credential is in curl's argv"
  else
    pass "the credential is not in curl's argv"
  fi
  if [[ "$ARGV" == *"--config"* ]]; then
    pass "curl reads its headers from --config"
  else
    fail "curl was not handed a --config file"
  fi
fi

if [[ -f "$REQ" ]] && grep -qF "Authorization: Bearer $KEY" "$REQ"; then
  pass "the Authorization header still reaches the endpoint"
else
  fail "the request carried no Authorization header"
fi

status=$(jq -r '.status // "missing"' "$TMP/envelope.json" 2>/dev/null)
if [[ "$status" == "error" ]]; then
  pass "a dead endpoint yields an error envelope, not a verdict"
else
  fail "expected an error envelope, got: $status"
fi

if grep -qF "$KEY" "$TMP/stderr.txt" 2>/dev/null; then
  fail "stderr carries the credential"
else
  pass "stderr carries no credential"
fi

(( FAILED )) && exit 1
printf '\nall checks pass\n'
