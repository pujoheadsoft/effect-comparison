#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "## Test all"
"$ROOT/eff/test.sh"
"$ROOT/koka/test.sh"

echo "== Haskell tests =="
(
  cd "$ROOT/haskell"
  stack test
)
echo "OK: Haskell tests"

echo "OK: test all"
