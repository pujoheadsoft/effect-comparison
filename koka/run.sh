#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${KOKA:=koka}"

mapfile -t flags < <(./koka-flags.sh)

echo "== Koka run =="
"$KOKA" "${flags[@]}" -e src/main.kk
echo "OK: Koka run"
