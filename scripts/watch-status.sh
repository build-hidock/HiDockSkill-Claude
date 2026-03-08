#!/usr/bin/env bash
# Check HiDock watcher and sync process status.

set -euo pipefail

STORAGE_DIR="${MEETING_STORAGE_DIR:-/Users/seansong/seanslab/Obsidian/OpenClawWorkspace/MeetingNotes}"
STATE_FILE="$STORAGE_DIR/.hidock-sync-state.json"

echo "=== HiDock Process Status ==="

# Check for running watcher
watcher_pids=$(pgrep -af "usb:watch" 2>/dev/null || true)
if [ -n "$watcher_pids" ]; then
  echo "Watcher: RUNNING"
  echo "$watcher_pids" | while read -r line; do
    echo "  PID: $line"
  done
else
  echo "Watcher: NOT RUNNING"
fi

# Check for running sync
sync_pids=$(pgrep -af "meetings:sync" 2>/dev/null || true)
if [ -n "$sync_pids" ]; then
  echo "Sync: IN PROGRESS"
  echo "$sync_pids" | while read -r line; do
    echo "  PID: $line"
  done
else
  echo "Sync: idle"
fi

echo ""
echo "=== Last Sync State ==="

# Read sync state file
if [ -f "$STATE_FILE" ]; then
  last_success=$(python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    state = json.load(f)
print('Last successful sync:', state.get('lastSuccessfulSyncAt', 'never'))
print('Last run started:', state.get('lastRunStartedAt', 'never'))
processed = state.get('processedFiles', [])
print('Processed recordings:', len(processed))
" 2>/dev/null || echo "  (could not parse state file)")
  echo "$last_success"
else
  echo "  No sync state file found at $STATE_FILE"
  echo "  (no sync has been run yet, or custom state file path is in use)"
fi

echo ""
echo "=== Storage ==="
echo "Storage dir: $STORAGE_DIR"
if [ -f "$STORAGE_DIR/meetingindex.md" ]; then
  meeting_count=$(grep -c "^- DateTime:" "$STORAGE_DIR/meetingindex.md" 2>/dev/null || echo "0")
  echo "Meeting notes indexed: $meeting_count"
fi
if [ -f "$STORAGE_DIR/whisperindex.md" ]; then
  whisper_count=$(grep -c "^- DateTime:" "$STORAGE_DIR/whisperindex.md" 2>/dev/null || echo "0")
  echo "Whisper memos indexed: $whisper_count"
fi
