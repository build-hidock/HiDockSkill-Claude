# CLI Reference

## `meetings:sync` — Sync & Transcribe Recordings

```bash
cd /Users/seansong/seanslab/HiDockSkill
npm run meetings:sync -- [options]
```

### CLI Flags

| Flag | Value | Description |
|------|-------|-------------|
| `--storage <dir>` | directory path | Storage root directory (default: `/Users/seansong/seanslab/Obsidian/OpenClawWorkspace/MeetingNotes`) |
| `--state-file <path>` | file path | Sync state file path (default: `<storage>/.hidock-sync-state.json`) |
| `--storage-backend <id>` | `local` or `memdock` | Notes storage backend (default: `local`) |
| `--memdock-base-url <url>` | URL | Memdock API base URL (required for memdock backend) |
| `--memdock-api-key <token>` | string | Memdock bearer token (optional) |
| `--memdock-api-path <path>` | path | Memdock API path prefix (default: `/api/v1/notes`) |
| `--memdock-workspace <name>` | string | Memdock workspace header override (optional) |
| `--memdock-collection <name>` | string | Memdock collection header override (optional) |
| `--memdock-timeout-ms <n>` | integer | Memdock request timeout in ms (default: 10000) |
| `--whisper-model <id>` | model ID | Whisper model (default: `whisper-1`) |
| `--summary-model <id>` | model ID | Summary LLM model (default: `gpt-4o-mini`) |
| `--language <code>` | language code | Whisper language hint (e.g., `en`, `zh`) |
| `--prompt <text>` | string | Custom prompt for Whisper |
| `--temperature <n>` | float | Whisper temperature (0.0 - 1.0) |
| `--limit <n>` | positive integer | Process only the newest N files |
| `--whisper-only` | flag | Only process Whisper (quick memo) recordings |
| `--meetings-only` | flag | Only process meeting recordings (non-Whisper) |
| `--dry-run` | flag | List selected files without transcribing |
| `-h, --help` | flag | Show help text |

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `OPENAI_API_KEY` | Yes (unless `--dry-run`) | OpenAI API key for Whisper + GPT | — |
| `MEETING_STORAGE_DIR` | No | Storage root directory | `~/seanslab/Obsidian/OpenClawWorkspace/MeetingNotes` |
| `WHISPER_MODEL` | No | Whisper model ID | `whisper-1` |
| `SUMMARY_MODEL` | No | Summary model ID | `gpt-4o-mini` |
| `WHISPER_LANGUAGE` | No | Language hint | (auto-detect) |
| `WHISPER_PROMPT` | No | Custom prompt | (none) |
| `HIDOCK_NOTES_BACKEND` | No | Storage backend | `local` |
| `HIDOCK_SYNC_STATE_FILE` | No | State file path | `<storage>/.hidock-sync-state.json` |
| `HIDOCK_NOTES_TIER_HOT_MAX_DAYS` | No | Hot tier age threshold | `30` |
| `HIDOCK_NOTES_TIER_WARM_MAX_DAYS` | No | Warm tier age threshold | `180` |
| `MEMDOCK_BASE_URL` | When backend=memdock | Memdock API base URL | — |
| `MEMDOCK_API_KEY` | No | Memdock bearer token | (none) |
| `MEMDOCK_API_PATH` | No | Memdock API path prefix | `/api/v1/notes` |
| `MEMDOCK_WORKSPACE` | No | Memdock workspace header | (none) |
| `MEMDOCK_COLLECTION` | No | Memdock collection header | (none) |
| `MEMDOCK_TIMEOUT_MS` | No | Memdock request timeout | `10000` |

### Mutually Exclusive Flags
- `--whisper-only` and `--meetings-only` cannot be used together.

---

## `usb:watch` — USB Plug-In Monitor

```bash
cd /Users/seansong/seanslab/HiDockSkill
npm run usb:watch -- [options]
```

### CLI Flags

| Flag | Value | Description |
|------|-------|-------------|
| `--interval-ms <n>` | positive integer | USB poll interval in ms (default: 5000) |
| `--emit-on-startup` | flag | Emit notification if device already connected on first poll (default: on) |
| `--no-emit-on-startup` | flag | Suppress first-poll notification |
| `--slack-target <dest>` | string | Slack DM target for plug-in notifications via OpenClaw |
| `--slack-thread-id <id>` | string | Slack thread root message ID for active routing |
| `--slack-activity-target <dest>` | string | Slack target to inspect for thread activity (default: `--slack-target`) |
| `--slack-activity-user-id <id>` | string | Only count activity from this user ID |
| `--active-window-minutes <n>` | positive integer | Active routing window in minutes (default: 5) |
| `--no-slack-forward` | flag | Disable Slack forwarding even if env is set |
| `--openclaw-bin <path>` | file path | OpenClaw CLI binary path (default: `openclaw`) |
| `--auto-sync` | flag | Auto-sync on plug-in (default: on) |
| `--no-auto-sync` | flag | Disable auto-sync (watch-only mode) |
| `--sync-debounce-ms <n>` | positive integer | Debounce window before auto-sync (default: 1500) |
| `-h, --help` | flag | Show help text |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HIDOCK_USB_WATCH_SLACK_TARGET` | Slack target for forwarding | (disabled) |
| `HIDOCK_USB_WATCH_SLACK_THREAD_ID` | Slack thread root message ID | (none) |
| `HIDOCK_USB_WATCH_SLACK_ACTIVITY_TARGET` | Slack target for activity check | (same as SLACK_TARGET) |
| `HIDOCK_USB_WATCH_SLACK_ACTIVITY_USER_ID` | User ID for activity filtering | (none) |
| `HIDOCK_USB_WATCH_ACTIVE_WINDOW_MINUTES` | Active window in minutes | `5` |
| `HIDOCK_USB_WATCH_OPENCLAW_BIN` | OpenClaw CLI path | `openclaw` |
| `HIDOCK_USB_WATCH_AUTO_SYNC` | Set `0` to disable auto-sync | (enabled) |
| `HIDOCK_USB_WATCH_SYNC_DEBOUNCE_MS` | Debounce window in ms | `1500` |
| `HIDOCK_NOTES_BACKEND` | Storage backend for auto-sync | `local` |
| `MEMDOCK_BASE_URL` | Memdock URL for auto-sync | — |

### Auto-Sync Behavior

When `--auto-sync` is enabled (default):
- Each plug-in event triggers `meetings:sync` with default options
- A debounce window (default 1500ms) coalesces burst events
- Single-flight lock prevents concurrent syncs
- Uses the same env vars as manual `meetings:sync` runs
