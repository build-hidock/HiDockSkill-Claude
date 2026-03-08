# HiDockSkill-Claude

A Claude Code skill that teaches Claude how to operate the [HiDockSkill](https://github.com/build-hidock/HiDockSkill) CLI — syncing recordings from HiDock P1, transcribing with Whisper, and storing Markdown meeting notes.

## What This Is

This is a **Claude Code skill** (not a standalone app). It provides Claude with the knowledge and wrapper scripts to operate the existing HiDockSkill CLI tools on your behalf.

When you say things like "sync my HiDock meetings" or "check my HiDock", Claude loads this skill and runs the appropriate commands.

## Prerequisites

- [HiDockSkill](https://github.com/build-hidock/HiDockSkill) installed (set `HIDOCK_SKILL_DIR` env var to point to it)
- Node.js and npm
- `OPENAI_API_KEY` set in environment or `.env`
- HiDock P1 device connected via USB

## Installation

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/build-hidock/HiDockSkill-Claude ~/.claude/skills/hidock-skill
```

## Trigger Phrases

The skill activates when you mention:
- "HiDock", "meeting recordings", "transcription sync"
- "sync my meetings", "check HiDock", "start watching"
- "P1 recordings", "USB watch", "meeting notes"

## Supported Workflows

| Workflow | What It Does |
|----------|-------------|
| **sync** | Pull recordings, transcribe, summarize, save as Markdown |
| **watch** | Start USB monitor with auto-sync on plug-in |
| **status** | Check running processes and last sync time |
| **stop-watch** | Safely stop the USB watcher |
| **check** | List recordings on device without processing |

## Project Structure

```
HiDockSkill-Claude/
├── SKILL.md                        # Skill definition (loaded by Claude)
├── scripts/
│   ├── check-hidock-ready.sh       # Pre-flight checks
│   ├── sync-recordings.sh          # Wrapper for meetings:sync
│   └── watch-status.sh             # Process and sync status
├── references/
│   ├── cli-reference.md            # CLI flags and env vars
│   ├── storage-layout.md           # Storage structure and tiering
│   ├── troubleshooting.md          # Error codes and fixes
│   └── memdock-backend.md          # Memdock HTTP backend config
└── examples/
    └── common-workflows.md         # Example interaction transcripts
```

## License

MIT
