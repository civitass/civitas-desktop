# Network boundary

Civitas Desktop is local-first, not a blanket promise that every optional
feature is offline. This document identifies the reviewed local listeners,
default egress behavior, and user-enabled destinations in the consumer build.

## Default behavior on a fresh install

- The durable global network mode is **Local-only**. Migrated installs without
  a current remote-boundary receipt also fail closed to Local-only.
- The core API binds only to `127.0.0.1`.
- Local API authentication is always on in the consumer build.
- Product analytics are off; crash diagnostics are local-only.
- Automatic update checks are off.
- No Civitas account, Railway service, Supabase project, Civitas cloud gateway,
  fleet endpoint, or team-sync service is required.
- Remote AI profiles and third-party connections are inactive until the user
  configures them.
- The optional conversational assistant runtime is not installed or downloaded
  on first launch. Search, graph browsing, capture, export, and local API/MCP
  access remain usable without it.
- Local model files may need to be downloaded before the selected local
  feature can run. The download host, model, license, size, and removal path
  must be shown by the relevant setup surface; strict Local-only mode does not
  download a missing model.

## Durable global network mode

**Settings → Privacy → Network boundary** is the owner-facing source of truth.
The choice is persisted in the encrypted settings store and installed in the
native process before credential migration, provider construction, model
loading, the updater, calendar polling, or engine startup. Enabling remote
features requires the current versioned disclosure receipt. Missing, invalid,
or stale settings are migrated to Local-only.

The policy is checked at reviewed feature entry points and again immediately
before the in-process transports that Civitas controls:

| Category | Local-only behavior |
| --- | --- |
| Loopback HTTP/HTTPS/WS/WSS | Allowed only for exact `localhost`, `127.0.0.0/8`, or `::1` destinations |
| Provider inference and model listing | Remote denied; loopback providers remain available |
| Batch and live transcription | Remote denied; local Whisper and loopback-compatible transcription remain available |
| Connection tests, ICS feeds, and workflow connection proxy | Remote denied; filesystem connections and exact loopback endpoints remain available |
| External MCP | Remote HTTP denied; loopback HTTP allowed; stdio MCP denied because a user-supplied subprocess can open arbitrary sockets |
| Product analytics and updater | Disabled, even when their individual opt-in remains stored |
| Assistant-runtime and model downloads | Missing downloads denied; already verified local artifacts remain usable |

Immutable model artifacts are a separately classified egress purpose, not an
exception to Local-only. To fetch one, the owner must temporarily enable remote
features and approve that model's host/license/size disclosure; Civitas still
verifies the pinned digest before use.

`CIVITAS_NETWORK_MODE=deny` is a stricter process override for CI and
high-assurance launches. It cannot be weakened from the UI. Unknown non-empty
values fail closed; remove the override and restart before enabling remote
features.

## Local listeners

| Listener | Default | Purpose | Boundary |
| --- | --- | --- | --- |
| `127.0.0.1:3030` | On while the engine runs | Capture/search/graph API, local provider gateway, workflows, connections | Loopback only; bearer authentication required; exact local Origin/Host checks |
| `127.0.0.1:11435` | Desktop app only | Focus, notifications, app icons, installed-app metadata | Loopback only; route-specific authentication and Host/Origin controls |
| `127.0.0.1:11434` | External/local provider | Default Ollama-compatible endpoint | Not started by Civitas; profile accepts loopback hosts only |
| `127.0.0.1:5273` | Optional developer helper | Apple Foundation Models compatibility server | Loopback only; not required for the standard desktop path |

The consumer application has no LAN-bind setting and no mDNS peer
advertisement. A stored `listenOnLan` value from an older build is ignored by
the current schema.

Loopback is a trust boundary, not a complete sandbox: another process running
as the same user may attempt to connect. Bearer keys, per-workflow tokens,
bounded bodies, origin checks, rate limits, and scoped routes reduce that risk.
Keep the OS account and local software trusted.

The optional MCP HTTP bridge also binds only to loopback, but every endpoint
(including its minimal health check) requires a separate inbound bearer. That
bearer must be a random 32–4096-character printable ASCII secret and is never
forwarded to the core API. MCP scope checks apply to both tool discovery and
execution; sessions are count- and idle-bounded. Every MCP client receives a
separate `sp_mcp_*` credential stored in the operating-system vault with its
name, server-enforced scopes, issue time, expiry, last use, and revocation
state. The credential defaults to read-only access for 90 days. The bridge
rejects device-owner and knowledge-graph grant keys, never substitutes either
for the dedicated credential, and cannot reach owner surfaces such as raw SQL,
connections, credential administration, retention, vault control, or workflow
installation.

## Automated workflow boundary

Scheduled and background workflows have no shell or arbitrary-network tool.
Their only HTTP surface is the typed `civitas_api` tool, which is fixed to
`http://127.0.0.1:3030` and injects a short-lived `sp_pipe_*` bearer that is
not exposed to model-authored code. The token-bearing bootstrap file is removed
before any workflow tool becomes available; a file that cannot be removed
causes startup to fail closed.

Permission evaluation is **deny → explicit allow → reader default → reject**.
The reader default is exactly:

- `GET /search`
- `GET /activity-summary`
- `GET /elements`
- `GET /meetings`
- `GET /meetings/*`
- `GET /meetings/status`
- `GET /speakers`
- `GET /pipes/info`
- `GET /health`

A workflow's app, window, content-type, day, and time rules are enforced in
both the typed tool and the server middleware. Scoped search results are also
filtered row by row after retrieval. For a scoped workflow request,
`pagination.total` is the number of rows returned on that bounded page after
scope filtering, not an unrestricted database count and not a scoped
all-pages count. Routes whose records cannot prove the declared scope, such as
frame-by-ID reads under an app/window/time restriction, fail closed.

A declared connection adds only `GET /connections/<id>` and
`GET /connections/<id>/*` for that exact, identifier-safe connection ID.
Filesystem-backed `obsidian`, `logseq`, `codex`, and `claude-code` connections
do not receive even that implicit grant. Mutating methods and purpose-built
filesystem operations require an explicit `Api(...)` permission.

The workflow transport permits at most a 1,024-byte path, 64 query fields,
2,048 bytes per query value, a 128 KiB JSON body, and a 256 KiB response. It
uses a 15-second request deadline, rejects redirects, disallows bodies on
`GET`/`DELETE`, and accepts idempotency keys only when they contain 8–128
ASCII letters, digits, `.`, `_`, `:`, or `-`.

## Remote AI destinations

Remote inference occurs only after a profile is saved, its destination is
shown, the data-boundary acknowledgement is accepted, and the profile is used.

| Profile | Destination policy | Data that can leave |
| --- | --- | --- |
| OpenAI | Exact HTTPS host `api.openai.com` | Selected prompt, instructions, evidence, and explicitly selected media supported by the feature |
| Anthropic | Exact HTTPS host `api.anthropic.com` | Selected text prompt/instructions/evidence and tool/schema definitions; the current adapter does not send image blocks |
| OpenRouter | Exact HTTPS host `openrouter.ai` | Selected data; OpenRouter may route it to the selected upstream provider |
| Bedrock inference | Exact HTTPS host `bedrock-runtime.<region>.amazonaws.com` | Selected prompt/evidence and tool/schema definitions to the configured AWS region |
| Bedrock model discovery | Exact HTTPS host `bedrock.<region>.amazonaws.com`; short-term API-key mode only | Credential and model-catalog request metadata; no question or evidence |
| Compatible | User-visible HTTPS host, or HTTP/HTTPS loopback | Selected data to that operator |
| Local | `localhost`, `127.0.0.1`, or `::1` only | No remote-provider egress |

Official provider endpoints reject alternate hosts, URL credentials, query
strings, and fragments. HTTP redirects are disabled. Bedrock regions are
validated before host construction. Named AWS profiles are an explicitly
advanced boundary: their configured SDK chain may use AWS SSO, IAM, or STS,
assume a role, or run a local `credential_process`. SDK HTTP requests are
checked against the global network mode, and non-loopback plain-HTTP metadata
destinations are rejected. The setup acknowledgement names these additional
identity paths before Civitas uses the profile.

## Other optional egress

| Feature | When traffic occurs | Typical destination/data |
| --- | --- | --- |
| GitHub updater | User enables Auto-update or presses Check for updates | GitHub Releases metadata and signed artifacts; no capture content |
| Product analytics | Versioned analytics consent is enabled | PostHog; valid event names plus allowlisted booleans, numeric metrics, and bounded client-protocol metadata |
| Local crash diagnostics | A native panic occurs | Local log file only; no automatic network request |
| Optional assistant runtime | User reviews the disclosure in **Settings → AI** and presses **Install runtime** | Integrity-locked packages from `registry.npmjs.org`; ordinary request metadata only, with no capture, prompt, credential, database, or conversation content |
| Local model download | User accepts the model disclosure and selects a local feature whose reviewed model is absent | Revision-pinned `huggingface.co`, `github.com`, and their bounded file-delivery redirects; model filename/request metadata only |
| Deepgram transcription | User enters a Deepgram key and selects it | Audio selected for transcription |
| Compatible transcription | User explicitly configures the endpoint | Audio selected for transcription |
| Browser extension | User installs/connects it, invokes it on the active tab, and requests browser context | Bounded page outline over authenticated loopback; one approved HTTPS URL for navigation |
| Third-party connection | User saves and enables that connection | Requests to the integration's displayed API host |
| MCP server connection | User configures an MCP server | Tool schemas, arguments, and results defined by that server |
| External-memory file bridge | User enables Claude Code or Codex connection | Up to 200 higher-priority local memories written to the selected local files; no network by Civitas, but the receiving assistant may send them under its own provider boundary |
| Website/documentation link | User clicks a link | Browser request to the displayed site |

Connection credentials stay in the encrypted local secret store. Workflows call
an authenticated local proxy; the proxy injects a credential after verifying
the workflow's declared method/path/host scope. A workflow does not receive the
secret value.

### Credential-injecting connection proxy

The consumer build exposes proxy transport only for the reviewed connections
below. The connection ID selects a compiled base URL; callers provide only the
relative API path and query.

| Connection ID | Pinned proxy base |
| --- | --- |
| `airtable` | `https://api.airtable.com` |
| `clickup` | `https://api.clickup.com/api/v2` |
| `fireflies` | `https://api.fireflies.ai` |
| `granola` | `https://public-api.granola.ai/v1` |
| `limitless` | `https://api.limitless.ai/v1` |
| `linear` | `https://api.linear.app` |
| `mochi` | `https://app.mochi.cards/api` |
| `otter` | `https://otter.ai` |
| `perplexity` | `https://api.perplexity.ai` |
| `pocket` | `https://public.heypocketai.com/api/v1/public` |
| `readwise` | `https://readwise.io` |
| `todoist` | `https://api.todoist.com` |
| `toggl` | `https://api.track.toggl.com/api/v9` |
| `workflowy` | `https://workflowy.com` |

The proxy permits only `GET`, `POST`, `PUT`, and `PATCH`; `DELETE` and every
other method are rejected. It allows a 2 KiB relative path, an 8 KiB query,
a 1 MiB request body, and a 2 MiB response, with at most four concurrent
requests. DNS resolution is bounded to three seconds, connection establishment
to five seconds, and the complete request to 15 seconds. An optional
`Idempotency-Key` must contain 8–128 ASCII letters, digits, `.`, `_`, `:`, or
`-`. Caller-controlled authentication, cookie, host, user-agent, and arbitrary
headers are not forwarded; only `Content-Type`, a bounded `Accept`, and a valid
idempotency key can accompany the proxy-injected credential.

Remote destinations must use HTTPS port 443. URL credentials and fragments,
private/link-local/metadata/documentation addresses, local-network suffixes,
and any DNS result set containing a non-public address are rejected. Validated
DNS answers are pinned into the HTTP client and redirects are disabled.
Explicit-port HTTP(S) loopback remains available to a compiled local connector,
but none of the reviewed consumer proxy definitions above uses it. Upstream
error bodies are not returned; the API exposes only a sanitized error category
and status.

### ICS calendar feeds

ICS access is read-only and owner-authenticated at
`GET /connections/ics-calendar/status` and
`GET /connections/ics-calendar/events`. At most eight enabled feeds are read
per request. `hours_back` and `hours_ahead` each accept 0–744 hours; event
requests default to 0 hours back and 8 hours ahead.

`webcal://` is normalized to HTTPS. Remote feeds must use HTTPS port 443;
plain HTTP is accepted only for an explicit-port loopback URL. URL credentials,
fragments, private/link-local/metadata/documentation addresses,
local-network suffixes, and mixed public/private DNS answers are rejected.
DNS answers are pinned and redirects are disabled. Each feed has a five-second
connection timeout, a 15-second total timeout, and a 2 MiB response ceiling.
Feed URLs remain in the local settings store and are omitted from API status
and connection-list responses. A rejected, unavailable, oversized, non-UTF-8,
or invalid feed contributes no events and records only a credential-safe local
warning.

Stopping the Claude Code/Codex file bridge removes the Civitas-owned marker
block and sidecar from the configured local path. It does not retract content
already read or transmitted by the receiving assistant.

The optional assistant installer uses the Bun sidecar included in the verified
Civitas application. Its reviewed `package.json` and integrity-bearing
`bun.lock` are embedded in the binary; installation uses a frozen lockfile,
production dependencies only, and disabled lifecycle scripts. Civitas does not
fall back to a system package manager or a global agent executable. On Windows,
assistant tools can use an existing Git for Windows Bash installation, but
Civitas never downloads or executes a Git installer.

The optional browser extension is also loopback-only. Its configurable origin
accepts only plain HTTP `localhost` or `127.0.0.1`; its API credential travels
in a WebSocket subprotocol header, never a URL. Chrome's temporary `activeTab`
grant requires the user to invoke the extension on the chosen tab. The
extension runs a bundled snapshot function that omits form values and URL
query/fragment data. It exposes no arbitrary code, cookie, hidden-tab, click,
form-fill, or submission command. Every HTTPS navigation waits for a separate
desktop **Allow once** decision showing the complete destination.

Only pairing start and status are owner-bearer exemptions. Both require a
loopback client plus an exact `chrome-extension://`, `moz-extension://`, or
`extension://` Origin. Starting a pair returns a random one-time challenge;
status polling must return that challenge in
`X-Civitas-Pairing-Challenge`. Pairing requests expire after two minutes and
the engine retains at most 16 at once. Desktop approval mints a
`sp_browser_*` credential only when the OS credential vault is available.
The credential is delivered once, expires after 30 days, is bound to the exact
extension Origin, and authorizes only `GET /connections/browser/status` and
the authenticated `GET /connections/browser/ws` upgrade. The owner API key is
never returned to the extension. Credential inventory and revocation routes
remain owner-authenticated.

Snapshot text enters the local Civitas process. If the user then invokes a
workflow or remote inference profile, selected snapshot text can leave through
that separately disclosed connection/provider boundary. The extension itself
has no remote endpoint or analytics.

## Analytics and crash-diagnostic boundary

Product analytics are disabled until the global mode allows remote features,
`analyticsEnabled` is true, and the stored consent version matches the current
version. Historic implicit opt-ins are migrated to off.

Immediately before transport, the web client reconstructs each event from a
fail-closed schema. It accepts only valid event names, bounded printable
protocol strings required by the analytics client, explicitly allowlisted
booleans, and finite non-negative allowlisted numeric metrics. Unknown
properties, nested values, person-profile updates, and timestamps are dropped.
Geolocation enrichment is disabled. Analytics must not contain:

- screen or image content;
- OCR/accessibility text;
- audio or transcripts;
- prompts, answers, graph facts, entities, notes, or filenames;
- captured URLs or window titles;
- credentials, email addresses, names, or contact data.

Only the web client has a first-party product-analytics path. The native app
and engine have no PostHog client, remote crash reporter, or automatic
crash-upload path. Panic records and application logs remain local unless the
user explicitly exports and shares them. Local-only mode prevents the reviewed
web PostHog initialization path.

## Model-download hosts

Runtime model downloads are limited to the immutable sources listed in
[`docs/MODEL_CATALOG.md`](MODEL_CATALOG.md):

- `huggingface.co` for pinned Whisper, Parakeet, Qwen, and optional Smart PII
  artifacts;
- `raw.githubusercontent.com` for pinned Silero VAD;
- `github.com` / `media.githubusercontent.com` for the digest-pinned
  pyannote/WeSpeaker artifacts mirrored in the last MIT Screenpipe baseline.

The HTTP client may follow at most five redirects from the named source to a
content-delivery host. Every redirect is treated as a fresh network attempt and
rechecked against the live global network mode before a socket is opened.
Every model file has an expected size and SHA-256 digest; redirected or mutable
bytes cannot be loaded unless they match the reviewed digest. Model requests
never contain captured audio, transcripts, or account credentials. Redirects
are disabled entirely for inference and transcription requests because those
requests can contain work content or credentials.

## Local-only mode and the environment override

Local-only is the default and can be selected at any time in **Settings →
Privacy**. For a launch-time override, set:

```bash
CIVITAS_NETWORK_MODE=deny civitas record --use-all-monitors
```

Reviewed effects:

- remote inference profiles are rejected;
- loopback inference remains available;
- remote batch and live transcription are rejected;
- remote connection tests, ICS polling, and workflow proxy calls are rejected;
- remote HTTP MCP and all stdio MCP execution are rejected, while authenticated
  loopback HTTP MCP remains available;
- missing model downloads are rejected; already verified local models remain
  usable;
- optional assistant-runtime installation is rejected; an already installed,
  integrity-checked runtime remains available to loopback or otherwise allowed
  provider profiles;
- optional PostHog analytics are disabled;
- local panic records remain local and are never uploaded automatically;
- automatic and manual updater network checks are blocked.

Every process begins Local-only. The desktop may install a previously
versioned, user-confirmed remote mode after reading its secure settings. The
standalone CLI never inherits that desktop choice: it requires
`--allow-remote` for that invocation, and `CIVITAS_NETWORK_MODE=deny` still
wins. CLI capture sources are independent and default off.

This is defense in depth, not a kernel socket sandbox or an operating-system
firewall. A separately running loopback provider can itself contact the
internet; a browser opened by the user follows the browser's policy; and code
outside the reviewed Civitas transports remains governed by the OS. Civitas
cannot revoke bytes already handed to a remote request before the mode changed.
For a high-assurance offline session:

1. pre-stage reviewed local models;
2. use local transcription and a loopback provider profile;
3. select Local-only and set `CIVITAS_NETWORK_MODE=deny`;
4. do not run untrusted local providers or helper processes;
5. enforce egress with the operating-system firewall or an isolated network;
6. verify with packet capture appropriate to the OS.

## Adding a destination

A change that introduces an outbound host must update:

- user-facing disclosure and opt-in;
- endpoint validation and redirect policy;
- credential and logging rules;
- this inventory;
- provider/connection contract tests;
- deny-network behavior where applicable;
- the threat model;
- the publication audit if the host is fixed.

Private Civitas production hosts are forbidden in consumer runtime source and
release assets.
