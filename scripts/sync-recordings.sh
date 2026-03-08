#!/usr/bin/env bash
# Wrapper for HiDockSkill meetings:sync CLI.
# Handles cd, .env sourcing, and passes all arguments through.

set -euo pipefail

HIDOCK_DIR="/Users/seansong/seanslab/HiDockSkill"

if [ ! -d "$HIDOCK_DIR" ]; then
  echo "ERROR: HiDockSkill directory not found at $HIDOCK_DIR" >&2
  exit 1
fi

cd "$HIDOCK_DIR"

# Source .env if present (for OPENAI_API_KEY, MEMDOCK_*, etc.)
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

exec npm run meetings:sync -- "$@"
