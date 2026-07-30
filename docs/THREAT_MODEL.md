# Civitas Desktop threat model

## Scope

This model covers the consumer desktop application, embedded engine, local
APIs, capture/storage pipeline, provider adapters, workflows, connections,
MCP, browser extension boundary, updater, and release pipeline. Private Civitas
cloud, fleet, organization, and enterprise-policy systems are outside the
consumer repository because the consumer build does not require them.

The model assumes a single person controls the OS account. It does not assume
that captured webpages, documents, meetings, workflows, browser extensions,
local processes, remote providers, or third-party integrations are trustworthy.

## Assets

Highest-value assets are:

- raw screen and audio media;
- OCR, accessibility trees, transcripts, keyboard and clipboard content;
- graph facts, decisions, relationships, routines, and Next Actions;
- provider, integration, MCP, and local API credentials;
- OS capture permissions;
- workflow and agent execution authority;
- exported archives and backups;
- updater signing/notarization keys and release provenance.

Availability matters too: corruption, runaway capture, model downloads, or
workflow loops can consume storage/CPU and destroy trust in the memory.

## Trust boundaries

1. **OS capture boundary** — macOS/Windows/Linux permissions and APIs deliver
   screen, audio, accessibility, and input signals.
2. **Local persistence boundary** — engine processes data into SQLite, media,
   settings, logs, indexes, and models.
3. **Loopback boundary** — desktop UI, CLI, MCP, extension, workflows, and
   other same-user processes can reach local listeners.
4. **Webview/Tauri boundary** — untrusted rendered content is separated from
   native commands by CSP and per-window capabilities.
5. **Inference boundary** — selected evidence crosses to a loopback or remote
   provider.
6. **Workflow/tool boundary** — model output proposes calls that may read local
   data or contact a declared connection.
7. **Browser-extension boundary** — an explicitly installed extension exposes
   a bounded outline of a user-invoked active tab and one-shot approved
   navigation of that tab.
8. **Update/supply-chain boundary** — source, dependencies, CI, signing,
   notarization, artifacts, updater metadata, and the optional assistant
   runtime become executable code.
9. **Human/export boundary** — the user can copy, export, or share sensitive
   evidence beyond Civitas' control.

The durable global network posture spans boundaries 5–8. New and migrated
consumer installs start Local-only; the native process installs that setting
before services start. Exact loopback is a permitted destination class.
Remote services, immutable model artifacts, and unbounded user-supplied
subprocesses are distinct denied classes until the owner enables remote
features.

## Adversaries and failure modes

- A malicious webpage, email, document, transcript participant, or captured
  prompt attempting prompt injection.
- A malicious or compromised local process probing loopback APIs.
- A malicious workflow, MCP server, browser extension, or third-party
  integration.
- A compromised AI provider account, credential, endpoint, or upstream routed
  model.
- Malware or another user with access to the OS account/data directory.
- A dependency, GitHub Action, release account, or download source compromise.
- An accidental user action, ambiguous capture indicator, faulty exclusion, or
  overbroad export.
- A model hallucination or ranking error presented as personal evidence.

## Abuse cases and controls

### Capture without informed intent

**Risk:** the app records a private window, microphone, locked screen, DRM
surface, or excluded app while the user believes it is paused.

**Controls:** separate OS permissions; onboarding disclosure; visible tray
state; one-click and timed pause; Private mode; persisted pause intent;
incognito detection on; DRM/remote-desktop pause on for new profiles; app,
window, URL, monitor, audio-device, and schedule controls; audio stops while
locked by default; capture-state tests.

**Residual risk:** classifiers and OS metadata are imperfect. A sensitive
document inside an allowed app can still be captured.

### Local data theft

**Risk:** malware or another local user reads SQLite/media/settings.

**Controls:** per-user data root; restrictive permissions; settings encryption
on by default through a native temp-write/fsync/atomic-replace path; encrypted
recovery artifacts; separate vault encryption; OS credential vault; Spotlight
exclusion; no LAN bind; auth on local APIs; full-disk encryption guidance.

**Residual risk:** code running as the same OS user may read files or memory.
Application encryption cannot defend a fully compromised logged-in account.

### Loopback API or MCP abuse

**Risk:** a webpage or local process queries/deletes data or invokes tools.

**Controls:** loopback-only bind; mandatory bearer authentication;
credential rotation; exact Host/Origin/CORS allowlists; websocket subprotocol
authentication; request/body bounds; rate limiting; per-workflow and per-MCP
scope; no token in media URLs; no LAN/mDNS feature.

**Residual risk:** a same-user process can steal tokens from compromised
process memory or authorized client configuration.

### Prompt injection and unintended actions

**Risk:** captured content instructs a model to disclose data, run shell
commands, or act through a connection.

**Controls:** evidence treated as data; structured system boundaries; workflow
permission manifests; external curl blocked in workflow shells; filesystem
roots; connection method/path/host scope; credentials injected locally; Next
Actions are drafts and never auto-execute; sensitive/high-risk candidates
suppressed; explicit approval for visible actions.

**Residual risk:** user-installed workflows and approved tools are powerful.
Users must review requested scopes and the final action.

### Optional assistant dependency substitution

**Risk:** first launch silently downloads executable packages, a mutable
dependency resolves to different code, an install script executes, or a global
agent/package manager bypasses the reviewed application boundary.

**Controls:** no startup/chat bootstrap; an explicit **Settings → AI**
disclosure and install action; exact direct and internal agent versions; an
embedded integrity-bearing Bun lockfile; frozen production-only installation;
dependency lifecycle scripts disabled; the version-pinned bundled Bun sidecar;
post-install manifest, lock, entrypoint, and key package-version checks; no npm
or global-agent fallback; Local-only rejection; no automatic Git/PortableGit
installer.

**Residual risk:** the user-authorized package set is executable code and its
transitive dependency graph is larger than the core application. Review lock
diffs, licenses, SBOM output, and upstream security advisories before every
update.

### Provider credential exposure

**Risk:** a key reaches React state, settings JSON, logs, a prompt, URL, or
export.

**Controls:** credentials accepted only during submit/test; Rust-only use;
encrypted secret rows protected by an OS-vault key; explicit process-memory
session mode that is never persisted and clears on quit; no plaintext fallback;
presence/storage-mode/suffix-only views; URL credential/query rejection; error
sanitization; fixed diagnostic prompt; rotation/deletion UI.

**Residual risk:** a compromised webview during the brief input interaction or
OS-level keylogger can observe typed credentials. Provider-side least
privilege, budget limits, and rotation remain necessary.

### Remote data disclosure

**Risk:** evidence goes to the wrong host, follows a redirect, or is sent
without understanding provider policy.

**Controls:** a durable Local-only default installed before startup services;
versioned global remote-boundary acknowledgement; a stricter environment
override; typed egress purposes and destination classes; exact loopback
recognition; transport-time rechecks for reviewed HTTP/WebSocket paths;
remote transcription, connections, ICS, workflow proxy, external MCP,
analytics, updater, assistant-runtime, and model-download gates; official host
pinning; HTTPS/WSS; redirects disabled for content-bearing requests; live
policy rechecks on bounded, checksum-verified model redirects; Bedrock region
validation; explicit compatible-host display; provider-specific
acknowledgement; audit records with purpose/host/size/status but not content.

**Residual risk:** this is not an OS firewall or kernel socket sandbox. A
separately running loopback provider, a browser opened by the user, or other
code outside reviewed Civitas transports may egress. A mode change cannot
revoke bytes already handed to a remote request. The intended provider may
retain or route data; DNS, certificate authorities, provider infrastructure,
and account configuration remain external dependencies.

### Browser session takeover

**Risk:** an agent silently inherits browser cookies or navigates an invisible
authenticated browser.

**Controls:** owned browser and cookie inheritance/decryption are removed from
the consumer build. The visible extension uses temporary `activeTab` rather
than persistent all-site access; accepts only loopback; authenticates without
URL credentials; runs only a bundled, bounded snapshot function; omits form
values and URL query/fragment data; exposes no arbitrary code, cookie,
hidden-tab, click, or submit command; and requires a fresh desktop **Allow
once** decision for every credential-free HTTPS navigation.

**Residual risk:** page titles and visible labels in a deliberately shared tab
can be sensitive, and a user-approved navigation affects a signed-in session.
A compromised same-user local process may steal the local credential. Invoke
the extension only on the needed tab and revoke/remove it when not needed.

### Unsafe export, import, or deletion

**Risk:** path traversal, symlink escape, overwrite, incomplete deletion, or
orphaned graph facts.

**Controls:** explicit destination; canonicalized allowlisted roots; safe
filenames; symlink/path traversal rejection; bounded archive content; local
retention and deletion routes; derived-lineage requirements; backups before
destructive migrations.

**Residual risk:** SSD/backups can retain blocks and external copies cannot be
recalled.

### Update and supply-chain compromise

**Risk:** a compromised dependency/action/account ships malicious capture code.

**Controls:** locked dependencies; full-SHA GitHub Actions; minimal job
permissions; publication and secret scans; pinned license-safe FFmpeg build;
separate architectures; Developer ID signing; hardened runtime; notarization
and stapling; updater signatures; checksums; SPDX SBOM; build provenance;
draft-only automated release; manual publication gate.

**Residual risk:** maintainer and CI credentials remain high value. Two-person
review and protected environments are organizational controls that must be
configured on GitHub.

### Incorrect knowledge or suggestions

**Risk:** a hallucination is presented as the user's history or a suggestion
causes harm.

**Controls:** evidence pointers, confidence, observed/inferred distinction,
contradiction/supersession, abstention, deterministic candidate generation,
risk/sensitivity filters, age/ambiguity penalties, reason display, dismiss/not
now/done feedback, no auto-execution.

**Residual risk:** source evidence itself can be wrong or ambiguous. Users must
inspect evidence before relying on a consequential suggestion.

## Security invariants

- Consumer runtime contains no Railway or private Civitas API dependency.
- Core listeners are loopback-only.
- Fresh and stale consumer settings resolve to durable Local-only mode; remote
  mode requires the current acknowledgement, and the environment override can
  only make policy stricter.
- Remote-provider credentials have no plaintext fallback.
- Product analytics do not initialize before both remote mode and current
  consent; native crash diagnostics remain local and have no automatic upload
  path.
- Background updater traffic is off by default.
- Captured content cannot authorize a tool.
- Next Actions cannot execute by itself.
- A source deletion must not leave an unexplained derived fact.
- Official releases remain drafts until a human verifies artifacts and gates.

CI tests and `scripts/audit-publication.mjs` enforce the invariants that can be
checked statically. Platform testing, packet capture, clean-machine install,
and independent security review are still required for a release candidate.

## Out of scope / non-goals

- Protecting data after the logged-in OS account is fully compromised.
- Forensic erasure from SSDs, backups, or provider systems.
- Guaranteeing the truth of captured speech or webpages.
- Auditing every third-party model/provider/integration's internal security.
- Treating the Local-only application policy or
  `CIVITAS_NETWORK_MODE=deny` as an OS firewall.

## Review triggers

Update this model when adding a capture modality, outbound host, Tauri
permission, browser capability, workflow tool, MCP scope, credential type,
automatic action, update channel, new executable/binary, or data export/import
format.
