# Memdock Backend Configuration

## Overview

The Memdock backend stores meeting notes via HTTP API instead of (or in addition to) local filesystem. It is an alternative to the default `local` backend.

When Memdock is selected but unavailable, the system **automatically falls back to local storage** — no data is lost.

## Enabling Memdock

### Via environment variables

```bash
export HIDOCK_NOTES_BACKEND=memdock
export MEMDOCK_BASE_URL=http://127.0.0.1:7788
npm run meetings:sync
```

### Via CLI flags

```bash
npm run meetings:sync -- --storage-backend memdock --memdock-base-url http://127.0.0.1:7788
```

CLI flags override environment variables.

## Configuration Reference

| Variable / Flag | Required | Description | Default |
|----------------|----------|-------------|---------|
| `HIDOCK_NOTES_BACKEND` / `--storage-backend` | To enable | Set to `memdock` | `local` |
| `MEMDOCK_BASE_URL` / `--memdock-base-url` | Yes (for memdock) | Memdock API base URL | — |
| `MEMDOCK_API_KEY` / `--memdock-api-key` | No | Bearer token for authorization | (none) |
| `MEMDOCK_API_PATH` / `--memdock-api-path` | No | API path prefix | `/api/v1/notes` |
| `MEMDOCK_WORKSPACE` / `--memdock-workspace` | No | Workspace header override (`x-memdock-workspace`) | (none) |
| `MEMDOCK_COLLECTION` / `--memdock-collection` | No | Collection header override (`x-memdock-collection`) | (none) |
| `MEMDOCK_TIMEOUT_MS` / `--memdock-timeout-ms` | No | Request timeout in ms | `10000` |

## API Endpoints

The Memdock adapter calls two endpoints (both POST):

### `POST <MEMDOCK_API_PATH>/is-indexed`

Check if a recording has already been processed.

**Request body:**
```json
{
  "sourceFileName": "20260221-132825-Rec00.hda",
  "kind": "meeting"
}
```

**Response:**
```json
{
  "indexed": true
}
```

### `POST <MEMDOCK_API_PATH>/save`

Save a meeting/whisper document.

**Request body:**
```json
{
  "kind": "meeting",
  "sourceFileName": "20260221-132825-Rec00.hda",
  "document": {
    "timestamp": "2026-02-21T13:28:25.000Z",
    "sourceFileName": "20260221-132825-Rec00.hda",
    "title": "Weekly Sync",
    "attendee": "Team",
    "brief": "Discussed project timeline and next steps",
    "summary": "...",
    "transcript": "..."
  }
}
```

**Response:**
```json
{
  "notePath": "meetings/hotmem/202602/20260221-132825-weekly-sync.md",
  "indexPath": "memdock://default/notes/meetingindex.md",
  "relativeNotePath": "meetings/hotmem/202602/20260221-132825-weekly-sync.md",
  "skipped": false
}
```

## HTTP Headers

| Header | When Sent | Value |
|--------|-----------|-------|
| `Content-Type` | Always | `application/json` |
| `Authorization` | When `MEMDOCK_API_KEY` is set | `Bearer <token>` |
| `x-memdock-workspace` | When `MEMDOCK_WORKSPACE` is set | Workspace name |
| `x-memdock-collection` | When `MEMDOCK_COLLECTION` is set | Collection name |

## Fallback Behavior

The Memdock adapter wraps a local storage adapter as fallback:

1. **Missing `MEMDOCK_BASE_URL`** — logs a warning once, uses local storage for all operations
2. **HTTP error / timeout** — logs the failure, falls back to local storage for that specific save/check
3. **Invalid response** — treated as error, falls back to local

This means notes are **never lost** even if Memdock is down — they land in local filesystem storage.

## Index Path Format

When using Memdock, index paths use a virtual URI format:
```
memdock://<workspace>/<collection>/meetingindex.md
memdock://<workspace>/<collection>/whisperindex.md
```

Defaults: `memdock://default/notes/meetingindex.md`

## Auto-Sync Integration

The `usb:watch` auto-sync uses the same backend configuration:
- Set `HIDOCK_NOTES_BACKEND=memdock` and `MEMDOCK_BASE_URL` in the environment
- The watcher passes these to `meetings:sync` automatically
