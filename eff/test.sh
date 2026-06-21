#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${EFF:=eff}"

echo "== Eff test: State laws =="
"$EFF" -l src/state.eff test/state_test.eff
echo "OK: Eff State laws"

echo "== Eff test: State + Ask =="
"$EFF" -l src/state.eff -l src/ask.eff -l src/state_ask.eff test/state_ask_test.eff
echo "OK: Eff State + Ask"

echo "OK: Eff tests"
