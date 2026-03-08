# Troubleshooting

## USB / Device Issues

### `LIBUSB_ERROR_ACCESS` — skill cannot connect to device

**Cause:** The HiDock USB interface is occupied by another application or session.

**Fix (in order):**
1. Ensure HiDock P1 is physically plugged in via USB
2. Check if HiNotes web / browser page is open and connected to HiDock — it holds the device exclusively
3. Close the HiNotes/HiDock browser tab (or the entire browser), then retry
4. Kill any stale processes:
   ```bash
   pkill -f "npm run usb:watch"
   pkill -f "meetings:sync"
   ```
5. Unplug and re-plug HiDock P1
6. On macOS: verify the device appears in `System Information > USB` as "HiDock"

### Device not found

**Cause:** HiDock P1 is not connected or not recognized.

**Fix:**
1. Check physical USB connection — try a different cable or port
2. On macOS: open `System Information > USB` and look for "HiDock"
3. On Linux: check `lsusb` output
4. Ensure USB permissions are correct:
   - macOS: `chmod a+rw /dev/usb/*` (if needed)
   - Linux: add appropriate udev rule

### USB exclusivity conflicts

HiDock can only be owned by one application at a time. Common conflicts:
- **HiNotes web app** — close the browser tab
- **Another `usb:watch` instance** — `pkill -f "npm run usb:watch"`
- **Another `meetings:sync` run** — `pkill -f "meetings:sync"`

To check what's holding the USB:
```bash
pgrep -af "usb:watch|meetings:sync|hidock"
```

## API / Authentication Issues

### `OPENAI_API_KEY is required`

**Cause:** The API key is not set in the environment.

**Fix:**
```bash
# Option 1: Export in shell
export OPENAI_API_KEY=sk-...

# Option 2: Add to .env file
echo "OPENAI_API_KEY=sk-..." >> /Users/seansong/seanslab/HiDockSkill/.env
```

The `.env` file is gitignored and will be sourced automatically by the sync wrapper script.

### Whisper / GPT API errors

- **Rate limits:** Wait and retry. Use `--limit N` to process fewer files per run.
- **Invalid model:** Check `--whisper-model` and `--summary-model` values. Defaults are `whisper-1` and `gpt-4o-mini`.
- **Network errors:** Verify internet connectivity. OpenAI API requires outbound HTTPS.

## Sync Issues

### No files to process

**Cause:** All recordings on the device have already been synced.

**Verify:**
```bash
# Check what's on the device
npm run meetings:sync -- --dry-run

# Check sync state
cat /Users/seansong/seanslab/Obsidian/OpenClawWorkspace/MeetingNotes/.hidock-sync-state.json
```

**If you need to re-process:**
Delete or edit `.hidock-sync-state.json` to remove specific files from the `processedFiles` array, then re-run sync.

### Partial sync failure

If some files fail during sync:
- The state file is NOT updated (only updated on fully successful runs)
- Failed files will be retried on next sync run
- Check error output for specific file failures (usually API errors or corrupted recordings)

### `Use only one of --whisper-only or --meetings-only`

These flags are mutually exclusive. Use one or the other, not both.

## Memdock Backend Issues

### `memdock selected but MEMDOCK_BASE_URL is empty`

**Cause:** Backend is set to `memdock` but the URL is not configured.

**Fix:**
```bash
export MEMDOCK_BASE_URL=http://127.0.0.1:7788
```

### Memdock request failures

When memdock is unreachable or returns errors, the system **automatically falls back to local storage**. Notes are still saved locally. Check logs for messages like:
```
[notes] memdock save failed for meeting; fallback local (...)
```

## Build Issues

### `dist/` directory not found

**Fix:**
```bash
cd /Users/seansong/seanslab/HiDockSkill
npm run build
```

### `node_modules/` not found

**Fix:**
```bash
cd /Users/seansong/seanslab/HiDockSkill
npm install
```

## Process Management

### Check running processes
```bash
pgrep -af "usb:watch|meetings:sync"
```

### Stop all HiDock processes
```bash
pkill -f "npm run usb:watch"
pkill -f "meetings:sync"
```

### Verify stopped
```bash
pgrep -af "usb:watch|meetings:sync"
# Should produce no output
```
