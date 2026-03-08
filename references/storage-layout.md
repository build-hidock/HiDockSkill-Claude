# Storage Layout

## Default Storage Path

Configured via `MEETING_STORAGE_DIR` env var or `--storage` CLI flag. See source code for the compiled-in default.

## Directory Structure

```
<storage>/
├── meetingindex.md              # Master index — one line per meeting note
├── whisperindex.md              # Master index — one line per whisper memo
├── .hidock-sync-state.json      # Sync state tracker
├── meetings/
│   ├── hotmem/                  # 0-30 days old (recent)
│   │   └── YYYYMM/
│   │       └── YYYYMMDD-HHMMSS-<title-slug>.md
│   ├── warmmem/                 # 31-180 days old
│   │   └── YYYYMM/
│   │       └── YYYYMMDD-HHMMSS-<title-slug>.md
│   └── coldmem/                 # 181+ days old (archived)
│       └── YYYYMM/
│           └── YYYYMMDD-HHMMSS-<title-slug>.md
└── whispers/
    ├── hotmem/
    │   └── YYYYMMDD-HHMMSS.md
    ├── warmmem/
    │   └── YYYYMMDD-HHMMSS.md
    └── coldmem/
        └── YYYYMMDD-HHMMSS.md
```

## Tiered Storage

Recordings are placed in tiers based on the **recording timestamp** age (not sync time):

| Tier | Age Range | Default Max Days | Env Override |
|------|-----------|-----------------|--------------|
| `hotmem` | 0 to HOT_MAX days | 30 | `HIDOCK_NOTES_TIER_HOT_MAX_DAYS` |
| `warmmem` | HOT_MAX+1 to WARM_MAX days | 180 | `HIDOCK_NOTES_TIER_WARM_MAX_DAYS` |
| `coldmem` | > WARM_MAX days | — | — |

The warm tier max is always >= hot tier max (enforced by code).

## Index Files

### `meetingindex.md`

Header: `# Meeting Index`

Each entry:
```
- DateTime: YYYY-MM-DD HH:MM:SS | Title: <title> | Attendee: <attendee> | Brief: <brief-14-words> | Source: <source-filename> | Note: meetings/hotmem/YYYYMM/YYYYMMDD-HHMMSS-title-slug.md
```

### `whisperindex.md`

Header: `# Whisper Index`

Each entry:
```
- DateTime: YYYY-MM-DD HH:MM:SS | Brief: <brief-14-words> | Source: <source-filename> | Note: whispers/hotmem/YYYYMMDD-HHMMSS.md
```

## Note Format

### Meeting Note

```markdown
# <Title>

- DateTime: YYYY-MM-DD HH:MM:SS
- Attendee: <attendee>
- Brief: <14-word brief>
- Source: <source-filename>

## Summary

<LLM-generated summary>

## Transcript

<Whisper transcript>
```

### Whisper Memo Note

```markdown
# Whisper YYYYMMDD-HHMMSS

- DateTime: YYYY-MM-DD HH:MM:SS
- Brief: <14-word brief>
- Source: <source-filename>

## Summary

<LLM-generated summary>

## Transcript

<Whisper transcript>
```

## Sync State File

Located at `<storage>/.hidock-sync-state.json` (override with `--state-file` or `HIDOCK_SYNC_STATE_FILE`).

Tracks:
- `lastSuccessfulSyncAt` — ISO timestamp of last fully successful sync
- `lastRunStartedAt` — ISO timestamp of when last run started
- `processedFiles` — array of file entries already processed (used for deduplication)

The state file is only updated on fully successful runs (zero failures). This ensures failed files are retried on next sync.

## Deduplication

Two layers of deduplication prevent reprocessing:
1. **Sync state file** — files listed in `processedFiles` are filtered out before selection
2. **Index file check** — if `Source: <filename>` appears in the index, the file is skipped even if not in state
