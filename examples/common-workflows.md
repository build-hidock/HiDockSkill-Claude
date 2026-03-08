# Common Workflows

Example interactions showing how the HiDock skill handles typical user requests.

---

## 1. "Sync my HiDock meetings"

**User:** Sync my HiDock meetings

**Claude's actions:**
1. Run pre-flight check: `bash <skill-dir>/scripts/check-hidock-ready.sh`
2. Run sync: `bash <skill-dir>/scripts/sync-recordings.sh`
3. Report results

**Expected output:**
```
HiDock pre-flight OK
  node: v22.x.x
  npm: 10.x.x
  dir: <hidock-skill-dir>
  OPENAI_API_KEY: set

> meetings:sync
> npm run build && node dist/cli/meetingsSync.js

[HiDock Sync] start at 2026-03-08T10:30:00.000Z total=5 candidate=2 selected=2 backend=local lastSuccess=2026-03-07T15:00:00.000Z
[1/2] 20260308-091500-Rec00.hda
[1/2] download complete (1048576 bytes)
[1/2] saved -> <storage>/meetings/hotmem/202603/20260308-091500-weekly-standup.md
[2/2] 20260308-093000-Wip00.hda
[2/2] download complete (524288 bytes)
[2/2] saved -> <storage>/whispers/hotmem/20260308-093000.md
[HiDock Sync] end at 2026-03-08T10:32:00.000Z saved=2, skipped=0, failed=0
```

**Claude's response:**
"Synced 2 new recordings from HiDock:
- Meeting note saved: `meetings/hotmem/202603/20260308-091500-weekly-standup.md`
- Whisper memo saved: `whispers/hotmem/20260308-093000.md`

All recordings are stored in the configured `MEETING_STORAGE_DIR`."

---

## 2. "What's on my HiDock?"

**User:** What's on my HiDock? / Check my HiDock / How many recordings do I have?

**Claude's actions:**
1. Run pre-flight check
2. Run dry-run: `bash <skill-dir>/scripts/sync-recordings.sh --dry-run`

**Expected output:**
```
[HiDock Sync] start at ... total=5 candidate=2 selected=2 backend=local lastSuccess=...
  1 | 20260308-091500-Rec00.hda | 1048576 B
  2 | 20260308-093000-Wip00.hda | 524288 B
[HiDock Sync] end at ... saved=0, skipped=0, failed=0
```

**Claude's response:**
"Your HiDock P1 has 5 total recordings, 2 of which haven't been synced yet:
1. `20260308-091500-Rec00.hda` (1.0 MB) — meeting recording
2. `20260308-093000-Wip00.hda` (0.5 MB) — whisper memo

Would you like me to sync them?"

---

## 3. "Start watching for HiDock"

**User:** Start watching my HiDock / Start the USB watcher

**Claude's actions:**
1. Run pre-flight check
2. Check for existing processes: `pgrep -af "usb:watch|meetings:sync"`
3. Warn about USB exclusivity
4. Start watcher: `cd "$HIDOCK_SKILL_DIR" && npm run usb:watch`

**Claude's response before starting:**
"Before I start the HiDock USB watcher, note that:
- HiDock can only be connected to one app at a time
- If HiNotes web is open in your browser, it will lose connection
- The watcher will auto-sync new recordings when you plug in HiDock

Starting the watcher now..."

---

## 4. "Is the HiDock watcher running?"

**User:** Is my HiDock watcher running? / Check HiDock status

**Claude's actions:**
1. Run status check: `bash <skill-dir>/scripts/watch-status.sh`

**Claude's response:**
"HiDock status:
- Watcher: RUNNING (PID 12345)
- Last successful sync: 2026-03-08 10:30:00
- Meeting notes indexed: 47
- Whisper memos indexed: 12"

---

## 5. "Stop the HiDock watcher"

**User:** Stop the watcher / Stop watching HiDock

**Claude's actions:**
1. Kill the process: `pkill -f "npm run usb:watch"`
2. Verify: `pgrep -af "usb:watch|meetings:sync"`

**Claude's response:**
"HiDock USB watcher stopped. You can now use HiNotes web or other apps with your HiDock."

---

## 6. "Sync only my latest meeting"

**User:** Just sync the latest recording / Sync only the newest one

**Claude's actions:**
1. Run pre-flight check
2. Run sync with limit: `bash <skill-dir>/scripts/sync-recordings.sh --limit 1`

---

## 7. "Sync only whisper memos"

**User:** Sync just my whisper memos / Only process quick memos

**Claude's actions:**
1. Run pre-flight check
2. Run sync: `bash <skill-dir>/scripts/sync-recordings.sh --whisper-only`

---

## 8. Pre-flight failure handling

**User:** Sync my meetings (but OPENAI_API_KEY is not set)

**Pre-flight output:**
```
HiDock pre-flight FAILED:
  - OPENAI_API_KEY is not set (export it or add to $HIDOCK_SKILL_DIR/.env)
```

**Claude's response:**
"Can't sync — your OpenAI API key isn't set. To fix this:
```bash
export OPENAI_API_KEY=sk-your-key-here
```
Or add it to `$HIDOCK_SKILL_DIR/.env`. The key is needed for Whisper transcription and GPT summarization."
