#!/usr/bin/env bash
# Pre-flight check for HiDockSkill operations.
# Exit 0 if everything is ready, non-zero with a descriptive message otherwise.

set -euo pipefail

HIDOCK_DIR="/Users/seansong/seanslab/HiDockSkill"
errors=()

# Check node
if ! command -v node &>/dev/null; then
  errors+=("node is not installed or not in PATH")
fi

# Check npm
if ! command -v npm &>/dev/null; then
  errors+=("npm is not installed or not in PATH")
fi

# Check HiDockSkill directory
if [ ! -d "$HIDOCK_DIR" ]; then
  errors+=("HiDockSkill directory not found at $HIDOCK_DIR")
else
  # Check node_modules
  if [ ! -d "$HIDOCK_DIR/node_modules" ]; then
    errors+=("node_modules not found — run 'npm install' in $HIDOCK_DIR")
  fi

  # Check dist (compiled output)
  if [ ! -d "$HIDOCK_DIR/dist" ]; then
    errors+=("dist/ not found — run 'npm run build' in $HIDOCK_DIR")
  fi
fi

# Check OPENAI_API_KEY
if [ -f "$HIDOCK_DIR/.env" ]; then
  # shellcheck disable=SC1091
  source "$HIDOCK_DIR/.env" 2>/dev/null || true
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  errors+=("OPENAI_API_KEY is not set (export it or add to $HIDOCK_DIR/.env)")
fi

# Report
if [ ${#errors[@]} -gt 0 ]; then
  echo "HiDock pre-flight FAILED:"
  for err in "${errors[@]}"; do
    echo "  - $err"
  done
  exit 1
fi

echo "HiDock pre-flight OK"
echo "  node: $(node --version)"
echo "  npm: $(npm --version)"
echo "  dir: $HIDOCK_DIR"
echo "  OPENAI_API_KEY: set"
exit 0
