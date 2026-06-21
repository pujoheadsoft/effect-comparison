#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${KOKA:=koka}"

mapfile -t flags < <(./koka-flags.sh)

echo "== Koka build =="
"$KOKA" "${flags[@]}" -c src/main.kk
echo "OK: Koka build"
