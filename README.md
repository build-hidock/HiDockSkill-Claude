# HiDockSkill-Claude

AI agent skill that teaches Claude Code and OpenClaw how to operate [HiDockSkill](https://github.com/build-hidock/HiDockSkill) — syncing recordings from HiDock P1, transcribing with Whisper, and browsing your meeting galaxy.

## What This Is

This is an **agent skill** (not a standalone app). It provides AI agents with the knowledge and wrapper scripts to operate the HiDockSkill CLI on your behalf.

Say "HiDock" and your agent opens the galaxy dashboard. Say "sync HiDock" and it syncs your latest recordings.

## Prerequisites

- [HiDockSkill](https://github.com/build-hidock/HiDockSkill) installed and built (`npm install && npm run build`)
- Node.js and npm
- `OPENAI_API_KEY` set in environment or in HiDockSkill's `.env`
- HiDock P1 device (for sync/watch — not needed for dashboard)

## Installation

### Claude Code

```bash
git clone https://github.com/build-hidock/HiDockSkill-Claude ~/.claude/skills/hidock-skill
```

### OpenClaw

```bash
git clone https://github.com/build-hidock/HiDockSkill-Claude ~/.openclaw/skills/hidock-skill
```

Or symlink if you already have it cloned:

```bash
ln -s /path/to/HiDockSkill-Claude ~/.openclaw/skills/hidock-skill
```

### Set HiDockSkill location

Point the skill to your HiDockSkill install:

```bash
export HIDOCK_SKILL_DIR=/path/to/HiDockSkill
```

Or the skill will auto-detect it if it's in a standard location.

## Commands

| Say this | What happens |
|----------|-------------|
| "HiDock" | Opens the galaxy dashboard (no device needed) |
| "sync HiDock" / "sync my meetings" | Syncs new recordings from device |
| "check HiDock" | Lists files on device without syncing |
| "start watching" | Starts USB watcher with auto-sync |
| "HiDock status" | Shows watcher/sync process status |
| "stop watching" | Stops the USB watcher |

## How It Works

1. **"HiDock" (bare)** — Runs `open-galaxy.sh`, which starts the galaxy server (if not running) and opens the browser. No device or API key required.

2. **Sync/watch commands** — The skill first runs `detect-device.sh` to verify the P1 is connected (instant, never hangs), then `check-hidock-ready.sh` for pre-flight checks (node, npm, API key), then executes the requested action.

3. **Galaxy dashboard** — After sync, the web page auto-refreshes from a "Syncing HiDock device" animation to the full galaxy visualization with your meeting notes.

## Project Structure

```
HiDockSkill-Claude/
├── SKILL.md                        # Skill definition (loaded by agents)
├── scripts/
│   ├── open-galaxy.sh              # Open galaxy dashboard in browser
│   ├── detect-device.sh            # Check if P1 is connected (instant)
│   ├── check-hidock-ready.sh       # Pre-flight: node, npm, API key, device
│   ├── sync-recordings.sh          # Wrapper for meetings:sync
│   ├── start-watcher.sh            # Start USB watcher in background
│   └── watch-status.sh             # Process and sync status
├── references/
│   ├── cli-reference.md            # CLI flags and env vars
│   ├── storage-layout.md           # Storage structure and tiering
│   ├── troubleshooting.md          # Error codes and fixes
│   └── memdock-backend.md          # Memdock HTTP backend config
└── examples/
    └── common-workflows.md         # Example interaction transcripts
```

## Verify Installation

### Claude Code

```
> HiDock
# Should open galaxy dashboard at http://127.0.0.1:18180
```

### OpenClaw

```bash
openclaw skills list | grep hidock
# Should show: ✓ ready │ hidock-skill
```

Then in chat:
```
> HiDock
# Should open galaxy dashboard
```

## License

MIT
