---
name: hidock-skill
description: >
  Manages HiDock USB meeting recorder: syncs recordings, transcribes with Whisper,
  summarizes with GPT-4o-mini, and stores as Markdown notes. Use when user mentions
  HiDock, meeting recordings, transcription sync, USB watch, meeting notes, "sync my
  meetings", "check HiDock", "start watching", or "P1 recordings".
---

# HiDock Skill

Operate the HiDockSkill CLI to sync, transcribe, and summarize recordings from the HiDock P1 USB meeting recorder.

**Skill directory:** `<skill-dir>` refers to the base directory specified when this skill was loaded.

**HiDockSkill install directory** is referenced as `$HIDOCK_SKILL_DIR` throughout this skill. Resolve it by checking the `HIDOCK_SKILL_DIR` env var, or by locating the repo (look for the `hidockskill` package in `package.json`). Common location: a `HiDockSkill` directory within the user's workspace.

## Automatic Flow (MANDATORY)

**IMPORTANT: Every HiDock operation MUST follow this automatic sequence. Do NOT ask the user to perform manual steps or wait between stages. Run each step, and only stop if a step fails with an unrecoverable error.**

### Step 1: Detect Device (instant, never hangs)

```bash
bash <skill-dir>/scripts/detect-device.sh
```

- Exit 0 + `CONNECTED: <name>` → device is plugged in, proceed to Step 2.
- Exit 1 + `NOT_CONNECTED` → device is NOT plugged in. Tell the user: _"HiDock P1 is not connected via USB. Please plug it in and make sure HiNotes web/browser is closed."_ Then STOP — do NOT run sync or dry-run (they will hang).

### Step 2: Pre-flight Check

```bash
bash <skill-dir>/scripts/check-hidock-ready.sh
```

This checks node, npm, HiDockSkill directory, compiled output, OPENAI_API_KEY, AND device presence. If it fails:
- **Missing OPENAI_API_KEY** → tell user to provide it, add to `$HIDOCK_SKILL_DIR/.env`, then re-run.
- **Missing node_modules** → run `cd $HIDOCK_SKILL_DIR && npm install`, then re-run.
- **Missing dist/** → run `cd $HIDOCK_SKILL_DIR && npm run build`, then re-run.
- **Other failures** → report the specific error and stop.

If pre-flight passes, proceed to Step 3.

### Step 3: Execute the Requested Action

Determine what the user wants and execute the matching workflow below. If the intent is ambiguous (e.g., "check HiDock"), default to **Check Device** to show what's on the device.

---

## Core Workflows

### 1. Check Device (`check`) — DEFAULT for ambiguous requests

List recordings on the HiDock without processing them.

```bash
bash <skill-dir>/scripts/sync-recordings.sh --dry-run
```

**After running, report to user:**
- Total file count
- Breakdown by type (Rec = meetings, Wip = whisper memos, Room = room recordings, Call = calls, Whsp = whisper)
- Date range
- Largest files
- How many are new (not yet synced)

### 2. Sync Recordings (`sync`)

Pull new recordings from HiDock, transcribe with Whisper, summarize, and save as Markdown notes.

```bash
bash <skill-dir>/scripts/sync-recordings.sh
```

**What happens:**
1. Connects to HiDock P1 via USB
2. Lists files on device, filters out already-processed ones (via `.hidock-sync-state.json`)
3. Downloads each new recording
4. Transcribes with OpenAI Whisper (`whisper-1` by default)
5. Summarizes with GPT-4o-mini
6. Saves Markdown note to tiered storage
7. Updates index files (`meetingindex.md` / `whisperindex.md`)

**Common flags:**
- `--dry-run` — list files that would be processed without actually syncing
- `--limit N` — process only the newest N files
- `--whisper-only` — only process Whisper (quick memo) recordings
- `--meetings-only` — only process meeting recordings (non-Whisper)
- `--language CODE` — Whisper language hint (e.g., `en`, `zh`)

**After sync, report to user:**
- Number of files saved, skipped, failed
- Path to generated notes
- Any errors encountered

### 3. Start USB Watch (`watch`)

Start a long-running process that monitors for HiDock plug-in events and auto-syncs.

```bash
cd "$HIDOCK_SKILL_DIR" && npm run usb:watch
```

**IMPORTANT: USB Exclusivity Warning**
HiDock can only be owned by one app at a time. Before starting the watcher:
1. Check if another watcher/sync process is already running (use `watch-status.sh`)
2. Warn the user that HiNotes web will not work while the watcher is running

**Common flags:**
- `--interval-ms N` — poll interval (default: 5000ms)
- `--no-auto-sync` — watch-only mode, no automatic sync on plug-in
- `--no-emit-on-startup` — suppress notification if device already connected
- `--sync-debounce-ms N` — debounce window before auto-sync (default: 1500ms)

### 4. Check Status (`status`)

Check if watcher/sync processes are running and when the last sync occurred. This does NOT require the device to be connected.

```bash
bash <skill-dir>/scripts/watch-status.sh
```

**Note:** For status checks, use `check-hidock-ready.sh --skip-device` for pre-flight (device not needed).

Report to user:
- Whether watcher is running (PID if yes)
- Whether a sync is in progress
- Last successful sync timestamp
- Number of processed recordings

### 5. Stop Watcher (`stop-watch`)

Safely stop the USB watcher process.

```bash
pkill -f "npm run usb:watch"
```

After stopping, verify with:
```bash
pgrep -af "usb:watch|meetings:sync"
```

If no output, watcher is stopped. Report to user.

---

## Environment

### Required
- `OPENAI_API_KEY` — needed for Whisper transcription and GPT summarization. Must be set in shell or in `$HIDOCK_SKILL_DIR/.env`.

### Optional
| Variable | Description | Default |
|----------|-------------|---------|
| `HIDOCK_SKILL_DIR` | HiDockSkill CLI install directory | (auto-detected) |
| `MEETING_STORAGE_DIR` | Root directory for meeting notes | (see code for compiled-in default) |
| `WHISPER_MODEL` | Whisper model ID | `whisper-1` |
| `SUMMARY_MODEL` | Summary model ID | `gpt-4o-mini` |
| `WHISPER_LANGUAGE` | Language hint for Whisper | (auto-detect) |
| `WHISPER_PROMPT` | Custom prompt for Whisper | (none) |
| `HIDOCK_NOTES_BACKEND` | Storage backend: `local` or `memdock` | `local` |
| `HIDOCK_SYNC_STATE_FILE` | Custom sync state file path | `<storage>/.hidock-sync-state.json` |
| `HIDOCK_NOTES_TIER_HOT_MAX_DAYS` | Hot tier max age in days | `30` |
| `HIDOCK_NOTES_TIER_WARM_MAX_DAYS` | Warm tier max age in days | `180` |

For Memdock backend variables, see `references/memdock-backend.md`.

## Storage

**Default path:** configured via `MEETING_STORAGE_DIR` env var or `--storage` flag.

Notes are organized into tiered storage based on recording age:
- **hotmem** (0-30 days) — recent, actively referenced
- **warmmem** (31-180 days) — older but still relevant
- **coldmem** (181+ days) — archived

Structure:
```
<storage>/
  meetingindex.md          # Master index of all meeting notes
  whisperindex.md          # Master index of all whisper memos
  meetings/
    hotmem/YYYYMM/         # Recent meeting notes
    warmmem/YYYYMM/        # Older meeting notes
    coldmem/YYYYMM/        # Archived meeting notes
  whispers/
    hotmem/                 # Recent whisper memos
    warmmem/                # Older whisper memos
    coldmem/                # Archived whisper memos
```

Index files contain one line per recording with DateTime, Title, Attendee, Brief, Source filename, and relative Note path.

## Error Handling

### `LIBUSB_ERROR_ACCESS` / cannot connect to device
1. Ensure HiDock P1 is plugged in via USB
2. Check if HiNotes web / browser is open (it holds USB exclusively)
3. Close HiNotes tab/browser, then retry
4. Kill any stale processes: `pkill -f "npm run usb:watch"` and `pkill -f "meetings:sync"`

### `OPENAI_API_KEY is required`
Set the API key: `export OPENAI_API_KEY=sk-...` or add it to `$HIDOCK_SKILL_DIR/.env`

### No files to process
- All recordings may already be synced (idempotent — safe to re-run)
- Check `.hidock-sync-state.json` for processed file list
- Use `--dry-run` to see what's on the device

### Device not found
- Run `detect-device.sh` first — it returns instantly and tells you if the device is connected
- Ensure HiDock P1 is connected via USB cable
- Try unplugging and re-plugging
- On macOS: check `System Information > USB` for "HiDock" device

## Constraints

1. **USB exclusivity** — only one app can access HiDock at a time. Always warn the user before starting sync/watch.
2. **No concurrent syncs** — never run two `meetings:sync` processes simultaneously. The sync coordinator uses a single-flight lock with debounce.
3. **Idempotent re-runs** — running sync multiple times is safe. Already-processed files are tracked in the state file and index, and will be skipped.
4. **Do NOT modify source code** — this skill wraps the CLI; never edit files in `$HIDOCK_SKILL_DIR/src/`.
5. **NEVER run sync or dry-run without detecting device first** — these commands will hang indefinitely if the device is not connected. Always run `detect-device.sh` before any USB-dependent operation.

## Reference Documentation

For deeper detail on specific topics:
- **CLI flags & env vars:** `references/cli-reference.md`
- **Storage layout & tiering:** `references/storage-layout.md`
- **Troubleshooting guide:** `references/troubleshooting.md`
- **Memdock backend config:** `references/memdock-backend.md`
- **Example workflows:** `examples/common-workflows.md`
