#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${EFF:=eff}"

echo "== Eff build =="
"$EFF" -l src/state.eff -l src/ask.eff -l src/state_ask.eff src/main.eff
echo "OK: Eff build"
