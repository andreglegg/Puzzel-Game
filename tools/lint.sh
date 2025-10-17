#!/usr/bin/env bash
set -euo pipefail

if ! command -v luacheck >/dev/null 2>&1; then
  echo "[lint] luacheck not found. Install via 'luarocks install luacheck'." >&2
  exit 1
fi

luacheck . "$@"
