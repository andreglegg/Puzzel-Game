#!/usr/bin/env bash
set -euo pipefail

if ! command -v busted >/dev/null 2>&1; then
  echo "[test] busted not found. Install via 'luarocks install busted'." >&2
  exit 1
fi

busted tests "$@"
