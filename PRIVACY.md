# Civitas Desktop privacy notice

This notice describes the consumer, local-first Civitas Desktop application.
It should be read with the detailed
[privacy/data boundary](docs/PRIVACY_AND_DATA_BOUNDARY.md) and
[network inventory](docs/NETWORK_BOUNDARY.md).

## Short version

Civitas stores capture, media, search indexes, and personal knowledge-graph
data on the user's computer. No Civitas account or hosted Civitas AI service is
required.

If the user selects a remote AI provider, transcription service, connection,
MCP client, updater, or product-analytics option, that feature has its own explicit
network boundary. The selected third party receives the data needed for the
request and applies its own terms, retention, location, and charges.

## Data Civitas can process

Depending on OS permission and settings, Civitas can process:

- screen frames, OCR, accessibility text, application/window/URL context;
- microphone and system audio, transcripts, and speaker labels;
- keyboard/typed-text or clipboard events/content when separately enabled;
- meetings, notes, searches, projects, and local file metadata;
- derived episodes, entities, claims, relationships, decisions, reasons,
  blockers, procedures, embeddings, summaries, and Next Actions;
- local configuration, health, and diagnostic metadata.

Clipboard and raw typed-text persistence are off by default. Incognito/private
window detection is on, and capture pauses for known DRM/remote-desktop
surfaces by default for new profiles.

## Where data is stored

The default data directory is `~/.civitas`, or a directory explicitly selected
by the user. Structured data is primarily in SQLite; media, models, workflows,
exports, settings, and logs are local files.

Provider and connection credentials are encrypted through a secret store whose
key is protected by the operating-system credential vault. Civitas does not
fall back to plaintext when the vault is unavailable. For inference providers
only, you may explicitly choose temporary session-only use: that credential is
kept in process memory, is never persisted, and must be re-entered after Civitas
quits.

Full-disk encryption remains important. Application deletion cannot promise
forensic erasure from SSD wear leveling, OS snapshots, backups, or copies
exported elsewhere.

## Remote AI and transcription

The default AI choice is a loopback provider. A user may instead configure
OpenAI, Anthropic, OpenRouter, Amazon Bedrock, or a compatible endpoint.
Before a remote profile can be used, Civitas displays the destination and
requires an acknowledgement that selected prompt/evidence data will leave the
computer.

Remote transcription similarly sends selected audio only when the user
provides a credential and chooses that engine.

Civitas does not provide bundled API credits and does not proxy consumer
inference through Railway or a Civitas cloud gateway.

## Optional connections and MCP

Connections are disabled until configured. When enabled, Civitas may send the
requested data to the connection's displayed API host. Credentials are injected
by the local engine and are not put into workflow prompts.

The optional Claude Code/Codex memory file bridge makes no network request
itself, but writes up to 200 higher-priority local memory entries into the
assistant's local instruction file. That assistant may then send the file to
its configured model provider. Disabling the bridge removes Civitas-owned
marker content and its sidecar; it cannot retract content already processed by
another application or session.

An MCP client receives only the locally authorized scopes, but results leave
the Civitas process and enter that client. The client's own provider and data
policy then apply.

## Optional analytics and local crash diagnostics

Product analytics are off by default and require current, versioned consent.
Historic implicit opt-ins are migrated to off. Civitas has no automatic remote
crash-reporting path; panic records and application logs remain on the user's
computer unless the user explicitly exports and shares them.

Allowed analytics are reduced immediately before transport to a fail-closed
schema: valid event names, bounded protocol metadata required by the analytics
client, explicitly allowlisted booleans, and finite non-negative numeric
metrics. Unknown fields, strings from feature code, arrays, objects, person
profiles, timestamps, screen/audio/transcript content, prompts or answers,
knowledge facts, captured URLs/window titles, credentials, names, email, and
contact data are dropped. Server-side geolocation enrichment is disabled.

Automatic update checks are separately off by default.

## User choices and rights

The app provides controls to:

- grant or withhold each OS capture permission;
- pause or enter Private mode immediately;
- exclude apps, windows, URLs, monitors, devices, and scheduled periods;
- keep clipboard/raw typed-text persistence disabled;
- inspect local sources and derived evidence;
- correct/reject suggestions and graph assertions;
- set retention and evict media;
- export selected local data;
- delete source/derived data or the local data set;
- replace/delete credentials and revoke local API/MCP access;
- disable product analytics and automatic updates.

Deleting local data does not delete provider-side requests, exported copies,
backups, or data already delivered to an integration/MCP client.

## Security and contact

Do not attach personal capture, credentials, or unsanitized logs to a public
issue. Report suspected vulnerabilities through the private channel in
[SECURITY.md](SECURITY.md).

Material changes to capture modalities, destinations, analytics categories, or
retention require an updated notice and renewed consent where appropriate.
