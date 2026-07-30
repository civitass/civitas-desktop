# Portable data ownership

Civitas keeps capture, media, search indexes, derived knowledge, and chat JSON
in the selected local Civitas data directory. The desktop renderer also owns a
small set of durable personal-data stores: its IndexedDB timeline cache,
local daily summaries, saved per-chat browser-state URLs, notification
history, and bounded browser diagnostic counts. **Settings → Storage → Your
data** coordinates all of these stores for owner-only inspection, export,
assertion deletion, and full-library deletion. These operations do not contact
Civitas or another remote service.

## Inspect before acting

**What Civitas knows** shows exact row totals by local table and a bounded
sample of recent source evidence and derived knowledge. Samples are capped at
20 per category, text is truncated, and credentials and filesystem paths are
never returned. Claim samples include their provenance and can be deleted
individually; dependent graph rows and newly orphaned entities are removed in
the same database transaction. The inspector also reports the exact active
source-media, derived-data, and completed-audio retention clocks and their
current scopes.

## Backup and cloud-sync protection

On macOS, Civitas marks the resolved data-directory URL with Foundation's
public
[`NSURLIsExcludedFromBackupKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/isexcludedfrombackupkey?language=objc)
resource value at every desktop startup and reads the value back before
reporting success. A failure is logged with a bounded, content-free status and
does not prevent the local engine from starting. Civitas does not invoke
`tmutil`, a shell command, or an undocumented backup interface.

Windows and Linux do not expose an equivalent supported app-scoped backup
exclusion API. The inspector reports that limitation rather than claiming
protection it cannot verify. On every platform, Civitas conservatively detects
data roots inside common iCloud Drive, OneDrive, Dropbox, and Google Drive
folders. A backup exclusion does not disable cloud synchronization, so a
detected sync location always requires attention: move the data directory to a
local-only folder.

The inspector returns only the exclusion state, a fixed provider identifier
when detected, a fixed status code, and path-free guidance. It never returns
the configured path or filesystem contents.

## Independent retention lifecycles

**Settings → Storage → Storage lifecycle** keeps three policies separate:

- **Source media** ages local video, raw audio, and snapshot files. Searchable
  OCR, transcripts, frames, and provenance rows remain. A chunk that also
  contains newer evidence is not evicted early.
- **Derived intelligence** ages generated claims and their direct graph
  dependents, generated Scribe/workflow memories, entity-state and semantic
  edge history, local work-graph patterns, completed review/decision-nomination
  history, and Next Actions history. Captured frames, OCR, transcripts, media,
  user-authored memories, saved queries, access grants, and correction journals
  remain.
- **Completed audio sources** can be aged independently or removed immediately
  after derivation. Immediate deletion applies only to audio chunks whose
  durable status is `transcribed` or `silent`. Pending or failed audio, video,
  and snapshots are never selected by this policy.

Each automatic policy is persisted in SQLite, reapplied after restart, and can
be run immediately from Settings. Enabling a destructive policy requires an
explicit confirmation; source-media cleanup shows the current file and byte
impact first. Interrupted media deletion resumes from a durable local outbox.
The policy does not promise forensic erasure from SSDs, backups, or filesystem
snapshots.

## Portable export

Choose a new, empty destination outside the Civitas data directory. An export
is written to a staging directory and made visible only after it completes.
It contains:

- `source-events.jsonl` — captured source records in stable table and
  primary-key order;
- `derived-knowledge.jsonl` — locally derived episodes, memories, graph data,
  suggestions, feedback, indexes, provenance, owner-authored saved queries,
  and each assertion's content-free provider/model/runtime/prompt/schema/
  extractor trace;
- `settings.json` — an explicit allowlist of non-secret application
  preferences and safe database settings;
- `chats/` — exact local conversation JSON and any interrupted atomic-write
  remnants found below the selected data root;
- `renderer-data.json` — the versioned
  `civitas-renderer-portable/v1` snapshot of the IndexedDB timeline cache,
  daily-summary records, URL-bearing browser states, notification history, and
  content-free browser diagnostic counters;
- optional `media/` files with content-hashed names and
  `media-index.jsonl`; and
- `manifest.json` — schema version, deterministic encoding contract, record
  counts, byte counts, and SHA-256 for every exported data file.

The current schema is `civitas-portable-export/v1`. JSON object keys, table
order, and row order are deterministic, so an unchanged library produces an
identical manifest. The manifest does not checksum itself. Its
`durablePersonalDataContract` enumerates SQLite source and derived records,
settings metadata, chats, and each renderer-owned store so a partial exporter
cannot silently present itself as a complete portable copy.

Provider credentials, encrypted secret rows, credential references, MCP/agent
token hashes, session-only keys, and short-lived graph-merge capabilities are
never exported. The manifest records the intentionally omitted
`kg_access_grant` and `kg_entity_merge_previews` tables. The durable graph
correction journal is exported so merges, splits, alias edits, and rollbacks
remain intelligible after transfer. Renderer input is bounded to 64 MiB and
validated against exact store-key contracts. Corrupt notification or browser
cache values are preserved as their JSON/string value instead of silently
dropped. Symlinks, reparse points, paths outside the local data root,
unreadable files, non-files, and chat or media files that change while being
copied make an export fail closed.

Structured assertion provenance does not contain prompts, evidence bodies,
provider responses, endpoints, or credentials. Local provider-profile and
inference-audit identifiers remain in the owner export for correlation; normal
knowledge-graph read APIs expose only the smaller privacy-safe trace described
in [`KNOWLEDGE_PROVENANCE.md`](KNOWLEDGE_PROVENANCE.md).

An export is an independent copy. Deleting Civitas data later cannot delete
exports, backups, filesystem snapshots, or copies made by sync software.

## Delete the local library

The deletion review displays every affected table count, exact chat/media file
and byte totals, renderer-store item count, and any unsafe native file
references. It produces a SHA-256 preview token bound to the SQLite, media, and
chat inventory. The desktop app pauses capture, stops known local assistant
writers, requires the exact phrase:

```text
DELETE ALL LOCAL CIVITAS DATA
```

and clears then reads back every renderer personal-data store. Only a
`civitas-renderer-wipe/v1` acknowledgement listing all five verified-empty
stores can accompany the token. If the native library changes, deletion
returns `409 Conflict`; the app refreshes the counts and requires another
review. The renderer stores are read back again after native deletion to catch
a cache write that finished during the native operation.

Structured work data and media-deletion jobs commit atomically. Media removal
uses a durable local outbox and safe-root validation, so interrupted cleanup
can resume after restart. Chat deletion uses canonical-root, no-symlink, and
post-delete inventory checks. The endpoint refuses to begin when an unsafe
media/chat reference exists and returns a non-success response if database,
media, or chat postconditions retain personal data. The desktop likewise never
shows the success state if renderer readback fails. Capture remains paused
after success. Provider profiles and their protected credentials, retention
preferences, non-personal application preferences, exported copies, backups,
and remote-provider data are outside this wipe. Revoke provider keys at the
provider when needed.
Saved queries are part of the wiped local library. A user can instead delete
one from the Search surface without affecting captured evidence.

Deletion is logical deletion plus best-effort file removal, not forensic secure
erasure from SSD wear leveling, backups, or filesystem snapshots. Use
FileVault/BitLocker and manage backups for device-level protection.

## Local API contract

The desktop UI calls authenticated loopback routes on `127.0.0.1`. They require
the device-owner key; scoped MCP and agent credentials are denied.

| Method   | Route                               | Purpose                                                                                         |
| -------- | ----------------------------------- | ----------------------------------------------------------------------------------------------- |
| `GET`    | `/data/inspector?sample_limit=5`    | Bounded counts, samples, provenance, exact retention, and content-free storage-protection state |
| `GET`    | `/data/deletion-preview`            | Exact counts and preview token                                                                  |
| `POST`   | `/data/portable-export`             | Deterministic export to an explicit local path                                                  |
| `DELETE` | `/data/graph/assertions/{claim_id}` | Transactional assertion deletion                                                                |
| `POST`   | `/data/full-wipe`                   | Token-bound full local work-data wipe                                                           |

Direct API callers must pause every capture writer, stop chat writers, clear
and verify the five renderer stores, and supply the exact renderer-cleanup
acknowledgement before calling `/data/full-wipe`. The acknowledgement is an
owner assertion, not a way for the engine process to inspect browser storage.
Callers must keep capture paused when `captureMustRemainPaused` is true. The
supported desktop flow enforces the ordering and performs a second renderer
readback. Errors are JSON objects with an `error` string and non-2xx status.

The generated contract is available from the running local engine at
`/openapi.yaml` and `/openapi.json`; the reviewed snapshot is
[`openapi.yaml`](openapi.yaml).
