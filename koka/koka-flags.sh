#!/usr/bin/env bash
set -euo pipefail
: "${KOKA:=koka}"

flags=(--include=src)
if [[ -n "${KOKA_SHAREDIR:-}" ]]; then
  flags=(--sharedir="$KOKA_SHAREDIR" "${flags[@]}")
else
  share="$($KOKA --version 2>/dev/null | awk -F': ' '/share  :/ {print $2}' || true)"
  if [[ -n "$share" && ! -d "$share" && -d /usr/local/share/koka ]]; then
    latest="$(find /usr/local/share/koka -maxdepth 1 -type d -name 'v*' 2>/dev/null | sort -V | tail -n 1 || true)"
    if [[ -n "$latest" ]]; then
      flags=(--sharedir="$latest" "${flags[@]}")
    fi
  fi
fi

printf '%s
' "${flags[@]}"
