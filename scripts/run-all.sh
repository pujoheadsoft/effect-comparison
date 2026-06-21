#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "## Run all"
"$ROOT/eff/run.sh"
"$ROOT/koka/run.sh"

echo "== Haskell run =="
(
  cd "$ROOT/haskell"
  stack run state-example
)
echo "OK: Haskell run"

echo "OK: run all"
