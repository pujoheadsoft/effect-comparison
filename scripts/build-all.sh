#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "## Build all"
"$ROOT/eff/build.sh"
"$ROOT/koka/build.sh"

echo "== Haskell build =="
(
  cd "$ROOT/haskell"
  stack build
)
echo "OK: Haskell build"

echo "OK: build all"
