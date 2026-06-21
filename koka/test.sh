#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${KOKA:=koka}"

mapfile -t flags < <(./koka-flags.sh)

echo "== Koka test: State laws =="
"$KOKA" "${flags[@]}" -e test/state-test.kk
echo "OK: Koka State laws"

echo "== Koka test: State + Ask =="
"$KOKA" "${flags[@]}" -e test/state-ask-test.kk
echo "OK: Koka State + Ask"

echo "OK: Koka tests"
