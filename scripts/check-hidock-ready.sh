#!/usr/bin/env bash
# Pre-flight check for HiDockSkill operations.
# Checks dependencies, environment, AND device presence.
# Exit 0 if everything is ready, non-zero with a descriptive message otherwise.
#
# Usage:
#   check-hidock-ready.sh              # Full check (deps + device)
#   check-hidock-ready.sh --skip-device # Skip device detection (for status/stop commands)

set -euo pipefail

HIDOCK_DIR="/Users/seansong/seanslab/HiDockSkill"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKIP_DEVICE=false

for arg in "$@"; do
  case "$arg" in
    --skip-device) SKIP_DEVICE=true ;;
  esac
done

errors=()
warnings=()

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

# Check device presence (unless skipped)
device_status="skipped"
if [ "$SKIP_DEVICE" = false ]; then
  device_output=$("$SCRIPT_DIR/detect-device.sh" 2>/dev/null) && device_status="connected" || device_status="not_connected"
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

if [ "$SKIP_DEVICE" = false ]; then
  if [ "$device_status" = "connected" ]; then
    echo "  device: $device_output"
  else
    echo "  device: NOT CONNECTED"
    echo ""
    echo "WARNING: HiDock P1 is not plugged in via USB."
    echo "Plug in the device and ensure HiNotes web/browser is closed."
    exit 2
  fi
fi

exit 0
