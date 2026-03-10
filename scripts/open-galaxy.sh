#!/usr/bin/env bash
# Open the HiDock Galaxy dashboard in the browser.
# If the server is already running, just open the URL.
# Otherwise, start the galaxy server and then open.

set -euo pipefail

HIDOCK_SKILL_DIR="${HIDOCK_SKILL_DIR:-/Users/seansong/seanslab/HiDockSkill}"
GALAXY_URL="http://127.0.0.1:18180"

# Check if server is already running
if curl -s --max-time 2 "$GALAXY_URL/status" >/dev/null 2>&1; then
  echo "Galaxy server already running at $GALAXY_URL"
  open "$GALAXY_URL"
  exit 0
fi

# Server not running — start it with data and open browser
echo "Starting galaxy server..."
cd "$HIDOCK_SKILL_DIR"

# Load env if available
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

npm run galaxy:open &
GALAXY_PID=$!

# Wait for server to be ready (up to 15 seconds)
for i in $(seq 1 30); do
  if curl -s --max-time 1 "$GALAXY_URL/status" >/dev/null 2>&1; then
    echo "Galaxy server ready at $GALAXY_URL"
    exit 0
  fi
  sleep 0.5
done

echo "Warning: server may not have started in time, opening anyway"
open "$GALAXY_URL"
