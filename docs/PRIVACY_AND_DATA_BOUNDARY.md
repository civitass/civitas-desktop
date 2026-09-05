# Privacy and data boundary

Civitas handles unusually sensitive data. Its useful input can include what is
visible on a screen, what is said near the computer, and derived statements
about a person's work. The consumer architecture therefore treats local
storage, informed capture, inspectable evidence, and bounded egress as product
requirements.

## What can be captured

Only modalities enabled by the user and permitted by the operating system are
available:

- screen frames and OCR;
- accessibility text and UI structure;
- active application, window title, and browser URL context;
- microphone and system audio;
- local transcripts and speaker labels;
- keyboard or typed-text rows;
- clipboard rows and content.

Raw keyboard/typed-text and clipboard persistence are off by default.
Incognito/private-browser detection is on by default. Capture pauses for known
DRM/remote-desktop surfaces by default on new profiles. Users can exclude apps,
window-title patterns, URLs, monitors, audio devices, and schedules.

Detection is best effort. An unknown password manager, a renamed private
window, content rendered into an allowed app, or OS metadata limitations can
defeat automatic classification. Use Private mode or pause capture before
handling exceptionally sensitive material.

## Visible control

The menu-bar/tray state shows whether Civitas is capturing, paused, private,
stopped, or degraded. The same surface provides:

- immediate resume/pause;
- 15-minute and one-hour pauses;
- pause until tomorrow;
- pause until manually resumed;
- Private mode;
- per-app inclusion/exclusion context.

Persisted pause/private intent is reapplied on restart so the engine does not
silently resume against the displayed state.

## Local data

The default root is `~/.civitas` or the explicit `CIVITAS_DATA_DIR`.

Typical contents include:

| Data | Location/type | Notes |
| --- | --- | --- |
| Structured capture, transcripts, graph, saved search terms/filters, provider profile metadata | `db.sqlite` plus SQLite WAL/SHM | Credentials are not stored in profile rows |
| Screen/audio media | local data/media subdirectories | Can be evicted separately from derived text where supported |
| Application settings | `store.bin` | Encrypted by default; crash-atomic native writes and restrictive permissions |
| Provider and connection credentials | encrypted secret rows protected by an OS-vault key | Never returned to the webview |
| Chat history | `chats/` below the selected data root | Individual crash-atomic JSON files; included in portable export and full wipe |
| Renderer personal caches | Webview IndexedDB/local storage | Timeline cache, daily summaries, per-chat browser URLs, notifications, and bounded diagnostic counts |
| Workflows and local skills | `pipes/`, skill/session directories | User-installed code is a separate trust boundary |
| Logs and crash remnants | local log/panic files | Redacted where implemented; review before sharing |
| Local model weights | model/cache directories | Separate model licenses apply |
| Optional assistant runtime | `pi-agent/` under the local data directory | Absent by default; installed or removed explicitly in **Settings → AI** without deleting work data |

The application excludes its default data directory from Spotlight on macOS to
avoid unnecessary indexing.

On macOS, the desktop also applies and verifies Foundation's public
`NSURLIsExcludedFromBackupKey` value on the resolved data root. The local Data
Inspector reports whether that protection is active. Windows and Linux do not
have an equivalent supported app-level API, so Civitas reports the limitation
instead of claiming protection. All platforms warn when the data root appears
inside iCloud Drive, OneDrive, Dropbox, or Google Drive. Backup exclusion does
not stop a sync provider from copying a folder; move Civitas to a local-only
location when that warning appears. These checks return fixed status codes and
provider names, never the path or file content.

The settings plugin is an in-process cache, not a disk writer. In encrypted
mode, settings are serialized and scrubbed in native memory, encrypted with an
OS-vault-backed key, written to a private temporary file, flushed, atomically
renamed, and followed by a directory flush. The plugin's direct save and
auto-save paths are disabled, so it never materializes a plaintext
`store.bin`. Recovery snapshots and pre-restore artifacts are also encrypted
while this mode is active. If a user explicitly disables whole-settings
encryption, the credential-free JSON remains restricted to the OS account;
provider and connection secrets still cannot enter it.

## Credentials

Remote-provider and connection secrets are accepted only at a save/test
boundary and protected by a key held in macOS Keychain, Windows Credential
Manager, or the supported OS vault. The database stores encrypted values and
non-secret references.

If vault access is missing, denied, or unavailable, persistent credential
saving fails. There is no plaintext or base64 fallback. For an inference
provider, the user can explicitly keep a credential only in process memory for
the current Civitas session; it is never written to disk and must be re-entered
after restart. Profile views reveal only credential presence, storage mode,
kind, and an optional four-character suffix.

Deleting a profile removes its local protected credential, but it does not
revoke the provider-side key. Revoke it at the provider too.

## Derived knowledge

OCR, transcripts, episodes, entities, claims, decisions, blockers, procedures,
search indexes, embeddings, suggestions, and summaries are derived from source
evidence. Derived data can be just as sensitive as raw capture.

Visible knowledge should include:

- an evidence pointer and time;
- confidence;
- whether it was observed, inferred, user-authored, or user-confirmed;
- contradiction/supersession state where applicable;
- a correction or rejection path.

Deletion must remove or invalidate dependent derived records rather than
leaving an unexplained claim. Because SQLite, SSD wear leveling, backups, and
filesystem snapshots exist, application deletion is logical deletion and
best-effort file removal—not a promise of forensic secure erasure. Use
full-disk encryption and manage backups for device-level protection.

## AI egress

Search, storage, capture, and export do not require a remote model. A loopback
profile can keep model prompts on the computer.

Search facets and saved-query management use authenticated, owner-only
loopback routes. Saved names, terms, and filters stay in SQLite rather than
browser storage; broad scoped client credentials cannot read them. Hostname
facets omit browser paths, queries, and fragments. See
[Local search and saved queries](SEARCH.md) for the bounded contract.

Saved-query follow-ups are also local and opt-in. Their interval and last
review timestamp remain beside the saved query in SQLite. Next Actions checks
that metadata only when the owner pulls suggestions; it does not run saved
queries in the background or send their terms to an AI provider. Reopening the
evidence restores the saved local filters and advances only that enabled
cadence.

The two behavioural Next Actions sources are equally local. Open threads are
computed from the structured artifact references (pull request, issue, ticket,
document, file, branch) and timestamps already stored beside captured actions;
they never read typed-text samples, run a model, or leave SQLite. Decision
follow-ups read only grounded knowledge-graph decision claims and the captured
moment they point at. Both run the same secret-material and sensitive-domain
abstention as every other inferred candidate, and a `done` rating that closes a
commitment updates only the memory row the owner wrote. The policy is
documented in [Next Actions](NEXT_ACTIONS.md).

When a remote profile is used, the provider necessarily receives the request:
system instructions, the user's prompt, and the selected evidence or media.
The setup UI displays the exact destination and requires a versioned
acknowledgement. Provider terms, retention, training settings, location, and
charges apply independently of Civitas.

Civitas does not proxy consumer inference through Railway or a Civitas cloud
gateway. The official OpenAI, Anthropic, OpenRouter, and Bedrock adapters pin
their hosts; compatible endpoints show the exact user-selected host.

Conversational Ask and Chat use an optional, version-pinned local agent process.
It is not fetched on first launch or when a chat is opened. The user must review
the package name, version, registry destination, data boundary, and local
storage location in **Settings → AI**, then press **Install runtime**. That
action sends only package requests and ordinary network metadata to
`registry.npmjs.org`; it does not include captured work, prompts, provider
keys, database content, or conversations. Installation uses the bundled Bun
runtime, a reviewed frozen lockfile, and disabled dependency lifecycle scripts.
There is no system npm or global-agent fallback. Network-deny mode rejects the
install before contacting the registry.

See `docs/NETWORK_BOUNDARY.md` for the complete inventory.

## Workflows, connections, browser, and MCP

Captured content is untrusted input. A sentence visible in a webpage or
transcript cannot authorize a tool call.

Bundled workflows use per-run tokens, declared API scopes, restricted
filesystem roots, blocked external shell networking, bounded output, and
approval boundaries. User-installed workflows are code and should be reviewed
before enabling.

Connection credentials are injected by a local proxy after scope checks.
Explicit browser automation uses only the user-installed browser extension;
Civitas does not launch a hidden owned browser or inherit/decrypt cookies from
Chrome, Arc, Edge, or other browsers. The extension has no cookie or arbitrary
code interface. The user invokes it on the exact active tab, snapshots omit
form values and URL query/fragment data, and every requested HTTPS navigation
requires a fresh in-app **Allow once** decision for the displayed destination.
Page titles and visible labels can still be sensitive. Snapshot content remains
local unless the user separately runs a workflow or remote provider request
that includes it.

The optional Claude Code/Codex memory file bridge is separately disabled until
the user enables it. It writes a bounded, importance-filtered memory digest into
the selected local assistant instruction file every five minutes. The bridge
does not make a network request, but the receiving assistant may send that file
to its own configured model provider. **Stop and remove** deletes the
Civitas-owned marker block and sidecar while preserving surrounding
user-authored text; it cannot retract content already processed by another
application or session.

MCP clients receive only the scopes granted to their local credential. Revoke a
client that is no longer trusted. Do not expose raw media unless the client and
task explicitly require it.

## Optional analytics and local crash diagnostics

Product analytics are off by default behind a versioned opt-in boundary.
Historic implicit analytics settings are migrated to off. Immediately before
transport, the web client reconstructs each event from a fail-closed allowlist:
valid event names, bounded protocol metadata, explicitly allowed booleans, and
finite non-negative numeric metrics. All other values are dropped. Work
content, free-form feature strings, prompts, transcripts, graph facts, captured
URLs, names, email, contact data, credentials, person profiles, arrays, and
objects are forbidden.

The native app and engine do not initialize a crash-reporting service or a
native analytics client. Panic records and logs stay in the local data
directory unless the user explicitly exports and shares them.

Disabling analytics stops future application reporting. It cannot retract
events already accepted by the analytics operator while consent was active.

## Retention, export, and deletion

Settings provide independent lifecycle controls for source media, derived
intelligence, and completed audio sources. Immediate
delete-after-derivation is limited to audio already marked transcribed or
silent; pending/failed audio and all screen media remain. The data inspector
reports the exact active scopes and ages. Exports are written only to an
explicit user-selected destination, use safe filenames, reject
traversal/symlink escapes, and include evidence metadata needed to understand
the output.

**Settings → Storage → Your data** provides an owner-only bounded inspector,
deterministic versioned JSON/JSONL export with per-file SHA-256 checksums,
individual graph-assertion deletion, exact deletion preview, and token-bound
full local work-data wipe. The portable contract includes chat files plus the
renderer timeline cache, local daily summaries, browser-state URLs,
notification history, and content-free browser diagnostic counters. Wipe
pauses capture, stops known chat writers, verifies renderer cleanup before and
after the native operation, and fails instead of claiming completion when a
database row, safe-root chat/media file, or renderer item remains. Credential
material and client token hashes are never portable data. Owner-authored saved
queries are included in portable export and full wipe but are intentionally
preserved by age-based retention. See
[Portable data ownership](PORTABLE_DATA.md) for the file format, preserved
preferences, deletion boundary, and local API contract.

Before sharing an export:

1. inspect it outside Civitas;
2. remove unrelated evidence and metadata;
3. confirm the destination's permissions;
4. remember that recipients and sync tools create independent copies.

“Delete everything” stops capture and known assistant writers, clears
renderer-owned personal caches, removes local chats, media, and structured
data, and verifies the postconditions. External provider requests, exports,
backups, screenshots, and files written to another tool are outside that local
deletion boundary.

## Safe-use checklist

- Grant only the capture permissions you need.
- Keep clipboard and raw typed-text persistence off unless the benefit is
  worth the risk.
- Exclude password managers, finance/health apps, private chats, and sensitive
  browser profiles.
- Pause before entering credentials or handling another person's confidential
  information.
- Use a local model or inspect the remote boundary before Ask/extraction.
- Protect the OS account with FileVault/BitLocker, a strong login, and current
  security updates.
- Never attach raw Civitas logs/data to a public issue.

This is an engineering description, not legal advice or a substitute for the
top-level privacy notice.
