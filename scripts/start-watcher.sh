#!/usr/bin/env bash
# Start HiDock USB watcher with proper environment.
# Used by launchd plist and manual invocation.

set -euo pipefail

HIDOCK_DIR="/Users/seansong/seanslab/HiDockSkill"

cd "$HIDOCK_DIR"

# Source .env for OPENAI_API_KEY and other env vars
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# Merge stdout into stderr so launchd captures all output (avoids stdout buffering)
exec node dist/cli/usbWatch.js "$@" 1>&2
