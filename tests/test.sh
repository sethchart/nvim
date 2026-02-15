#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: rg is required to run tests"
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "error: nvim is required to run tests"
  exit 1
fi

XDG_BASE="${XDG_BASE:-/tmp/nvim-config-tests}"
export XDG_CONFIG_HOME="$XDG_BASE/config"
export XDG_DATA_HOME="$XDG_BASE/data"
export XDG_STATE_HOME="$XDG_BASE/state"
export XDG_CACHE_HOME="$XDG_BASE/cache"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

rg --files -g '*.lua' | xargs -r luac -p
nvim --headless -u NONE -i NONE -n +"lua dofile('tests/run.lua')" +qa
