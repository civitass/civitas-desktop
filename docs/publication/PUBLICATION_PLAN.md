# Civitas consumer publication program

> Status: implementation plan and release gate
> Audit date: 2026-07-26
> Target public repository: `civitass/civitas-desktop`
> Target product: a local-first personal work memory, knowledge graph, query
> engine, and carefully consented next-action assistant

This document is the source of truth for turning the current private Civitas
codebase into a safe, useful, attractive public project. It is intentionally
strict. A screen-and-audio capture product has a much higher privacy burden
than a typical desktop utility, and GitHub visibility is effectively
irreversible once users can fork the history.

The goal is not merely to expose source code. The goal is to publish a product
that an individual can understand, trust, install, use without a Civitas
account, operate without Civitas infrastructure, and remove completely.

## 1. Executive decision

### 1.1 Repository publication matrix

| Repository | Current role | Public decision | Reason |
| --- | --- | --- | --- |
| `civitas-desktop` | Local capture, SQLite, knowledge graph, query, MCP, desktop UI, plus some cloud/team code | **Publish after all P0 gates pass** | This is the useful consumer product and contains the local execution path. |
| `civitas-cloud` | Organization identity, RBAC, SaaS connectors, governed team memory, workers, web application, cloud API | **Keep private** | It contains enterprise/SaaS control-plane logic, production topology, tenant operations, and proprietary product scope that a personal local app does not require. |
| `civitas-platform` | Railway, Supabase, R2, observability, migrations, notarization and production operations | **Keep private** | It is production infrastructure and migration history, not a consumer application. Publishing it would increase attack surface without helping an individual run Civitas locally. |

The consumer repository may contain a small, documented provider client and
optional self-host interfaces. It must not require either private sibling
repository.

### 1.2 Archive status

Before publication work began, exact private GitHub archives were created:

- `civitass/Civitas-cloud-archive`
- `civitass/Civitas-platform-archive`
- `civitass/Civitas-desktop-archive`

Each archive is private and GitHub-archived/read-only. Canonical remote refs
and local-only branch tips were copied, and the expected refs were compared by
exact object ID. These archives are the recovery point for the private history.
They must remain private even after a public repository exists.

### 1.3 Railway answer

**Implemented decision:** the consumer desktop no longer depends on Railway,
`api.civitas.team`, Supabase auth, a Civitas account, Civitas-hosted API
credits, or either private sibling repository.

- capture, local media, OCR, accessibility data, SQLite/FTS search, graph
  storage, export, deletion, feedback, and Next Actions state run locally;
- the loopback `/v1/chat/completions` route is implemented by
  `crates/civitas-engine/src/routes/inference_gateway.rs`;
- the gateway resolves a local or direct BYOK profile in Rust;
- supported direct profiles are OpenAI, Anthropic, OpenRouter, Amazon Bedrock,
  and an advanced compatible endpoint;
- the default local profile accepts loopback hosts only;
- remote cloud/team/fleet/control-plane and whole-data SFTP sync code is absent
  from the consumer tree.

The app is therefore fully hostable on the user's computer. Remote inference,
transcription, integrations, telemetry, model downloads, and GitHub updates
remain explicit optional boundaries rather than hidden dependencies.

Documentation uses **local-first** rather than an unqualified “fully offline”
claim. `CIVITAS_NETWORK_MODE=deny` blocks the reviewed remote inference,
telemetry, crash-report, and updater paths, but it is not an OS firewall.
High-assurance zero-egress verification still requires pre-staged models,
disabled integrations, an OS firewall/isolation, and packet-capture evidence.
See `docs/NETWORK_BOUNDARY.md`.

## 2. Non-negotiable release gates

The repository must remain private until every P0 item is complete.

### 2.0 Audit evidence recorded on 2026-07-26

A checksum-verified Gitleaks `8.30.1` scan was run against all reachable Git
history and separately against tracked `HEAD` trees. No secret values are
recorded in this document.

| Repository | History candidates | Tracked `HEAD` candidates |
| --- | ---: | ---: |
| `civitas-cloud` | 7 | 4 |
| `civitas-platform` | 2 | 0 |
| `civitas-desktop` | 36 | 31 |

These are unverified pattern matches, not a claim that every result is a live
credential. Many desktop matches are concentrated in redaction tests and
imported documentation, but none may be dismissed from its filename alone.
Each needs a human classification, service-side revocation/rotation check where
applicable, and a documented synthetic-test allowlist or fixture rewrite.

The desktop history also contains a commit explicitly described as a live
reasoning-memory graph from real laptop data (`b28372b`) followed by a partial
privacy-filter commit (`e0d987f`). That is sufficient to prohibit exposing the
existing history even if the current file looks redacted. The preferred public
root remains a sanitized snapshot.

### P0-A — history and data hygiene

- [ ] Scan the complete reachable history, tags, GitHub Actions logs, release
  artifacts, and current tree for credentials.
- [ ] Rotate every credential found, including expired or apparently test-only
  credentials that reached a shared service.
- [ ] Remove real capture data, names, account details, customer data, design
  partner material, private meeting traces, production URLs that are not meant
  to be public, and proprietary internal strategy.
- [ ] Replace real examples with generated synthetic fixtures carrying a
  machine-readable marker such as `synthetic_fixture: true`.
- [ ] Review at minimum
  `docs/visualizations/reasoning-memory-graph.live.html`,
  `apps/civitas-app-tauri/components/__tests__/url-detection-benchmark-data.json`,
  `crates/civitas-meeting-eval/evals/traces/meeting72_arc_real.jsonl`, design
  partner fixtures, screenshots, recordings, transcripts, benchmarks, and
  evaluation corpora.
- [ ] Assume deleted files remain public through Git history. Publish from a
  reviewed clean root commit or a verified history rewrite; deleting only from
  the tip is insufficient.
- [ ] Have two people independently approve the final allowlist of files.

Because the private archive preserves the original history, the preferred
approach is a new sanitized public root commit. This avoids exposing historic
PII and secrets while retaining provenance in `NOTICE.md`. A history rewrite or
orphan-root cutover is destructive and requires explicit owner approval before
execution.

### P0-B — licensing and provenance

- [x] Restore the upstream MIT notice in `LICENSE.md`.
- [x] Restore fork and operator attribution in `NOTICE.md`.
- [ ] Generate an SBOM and a complete third-party license inventory.
- [ ] Resolve the root `MIT OR Apache-2.0`, crate-level `MIT`, and empty Tauri
  application license metadata into one reviewed policy.
- [ ] Confirm that no post-relicense Screenpipe code or proprietary `ee/`
  material is present.
- [ ] Review copied models, icons, fonts, screenshots, audio fixtures, and
  binary assets independently from source-code licensing.
- [ ] Obtain counsel review for trademark wording, fork attribution, bundled
  model licenses, encryption export obligations, and the public privacy notice.

The repository must never rely on a README paragraph in place of an actual
license file.

### P0-C — local-first behavior

- [ ] No account or entitlement gate blocks capture, search, graph query, MCP,
  export, or deletion.
- [ ] Railway and `api.civitas.team` are absent from the default runtime path.
- [ ] Local-only mode is the first onboarding choice and works without network.
- [ ] Cloud sync, fleet, team policy, and hosted analytics are off and absent
  from the consumer build unless the user explicitly installs/enables them.
- [ ] A network inventory generated from code and a runtime integration test
  match the documentation.
- [ ] The app gives a clear pre-send disclosure whenever content will leave the
  machine.

### P0-D — credentials

- [ ] OpenAI, Anthropic, OpenRouter, Bedrock, and local-provider setup work from
  the UI.
- [ ] Secrets never enter React state longer than the submission interaction,
  never enter the settings JSON, never appear in logs, and are never returned
  by Tauri commands.
- [ ] Secrets are stored in the OS credential vault. On macOS this means
  Keychain; Windows uses Credential Manager/DPAPI; Linux uses Secret Service
  with an explicit unavailable-vault error.
- [ ] There is no plaintext/base64 fallback. If secure storage is unavailable,
  persistent secret storage is disabled and the UI explains the temporary
  session-only alternative.
- [ ] Connection tests use a fixed non-sensitive prompt and show the endpoint,
  provider, model, expected data boundary, and likely billing owner before
  sending.
- [ ] Delete, replace, rotate, and test operations are available for each
  credential.

### P0-E — privacy and security defaults

- [x] Change new-install telemetry default to off.
- [x] Add versioned telemetry consent and migrate historic implicit opt-ins to
  off.
- [x] Stop sending account email/name/contact data to product analytics.
- [x] Remove native analytics and automatic crash upload; keep crash records
  local and initialize the optional web analytics client only after versioned
  consent.
- [ ] Independently verify analytics-off, updater-off, and error paths with
  packet capture on the release candidate.
- [ ] Make screen, accessibility, audio, clipboard, and typed-text capture
  separately understandable and separately controllable.
- [ ] Keep clipboard and raw typed-text capture off by default.
- [ ] Add a persistent capture indicator and a one-click pause.
- [ ] Add privacy zones, app/window exclusions, incognito/private-browser
  exclusion, lock-screen pause, and configurable retention during onboarding.
- [ ] Complete least-privilege Tauri capability and CSP work.
- [ ] Complete threat model, abuse-case review, and external security review.

### P0-F — distributable release

- [ ] Produce signed, hardened-runtime, notarized, and stapled macOS DMGs with
  Developer ID Application identity; development or ad-hoc signatures are not
  release fallbacks.
- [ ] Publish SHA-256 checksums, SBOM, third-party notices, build provenance,
  and a VirusTotal or equivalent transparency link where policy permits.
- [ ] Publish both Apple Silicon and Intel artifacts, or a tested universal
  artifact, with architecture labels that cannot be confused.
- [ ] Produce a timestamped Authenticode-signed Windows x86-64 installer;
  unsigned or self-signed packages and SmartScreen bypass instructions are not
  release fallbacks.
- [ ] Install, uninstall, and upgrade tests pass on clean supported macOS and
  Windows versions.
- [ ] The updater verifies signatures and cannot silently change channels or
  endpoints.
- [ ] GitHub Releases is a first-class download source; R2 may mirror it but is
  not the only source of truth.

## 3. Target consumer architecture

### 3.1 Product boundary

The public application is “personal work memory,” not an employee monitoring
or enterprise control product.

Core capabilities:

1. selectively capture the user’s own work context;
2. store raw and derived data locally;
3. turn that context into an evidence-linked personal knowledge graph;
4. search and ask questions over the graph;
5. expose explicitly selected local knowledge through a loopback MCP server;
6. suggest possible next actions with evidence and calibrated abstention;
7. preview and require approval before any external or destructive action;
8. export, inspect, redact, and delete all personal data.

Enterprise-only concerns must not leak into the default information
architecture: org RBAC, employee fleet posture, mandatory policy, team
heartbeat, entitlement, central sync, management dashboards, and background
remediation belong behind an optional compile-time feature or outside the
public repository.

### 3.2 Runtime modes

| Mode | Network | Inference | Data storage | Account |
| --- | --- | --- | --- | --- |
| Local only | Denied except optional update check | Local provider or bundled runtime | Local only | None |
| Direct BYOK | Only selected provider endpoint plus optional update check | User’s OpenAI, Anthropic, OpenRouter, or Bedrock account | Local; prompts sent directly to selected provider | Provider account only |
| Custom compatible | Explicit allowlisted URL | OpenAI-compatible local or remote endpoint | Local; prompts go to the chosen URL | Depends on endpoint |
| Optional Civitas services | Explicitly enabled | Civitas-hosted | As separately disclosed | Civitas account |

The selected mode is a stored non-secret preference. Changing modes requires a
boundary confirmation if it would send data to a new host.

### 3.3 Local service layout

```text
Tauri UI
  |
  | typed commands; no provider secrets returned
  v
Rust application service
  +-- capture policy and permission controller
  +-- local media / SQLite / FTS / vector index
  +-- knowledge graph and provenance store
  +-- provider router
  |     +-- Local adapter
  |     +-- OpenAI adapter
  |     +-- Anthropic adapter
  |     +-- OpenRouter adapter
  |     +-- Bedrock adapter
  |     `-- Custom compatible adapter
  +-- OS credential-vault adapter
  +-- egress policy / redaction / request preview
  `-- loopback API and MCP, authenticated per local client
```

Provider calls must originate in Rust, not the webview. This keeps credentials
out of browser storage and permits one auditable egress policy.

### 3.4 Provider interface

Introduce a provider-neutral interface with explicit capabilities rather than
assuming every provider implements OpenAI Chat Completions:

```rust
trait InferenceProvider {
    fn id(&self) -> ProviderId;
    fn capabilities(&self) -> ProviderCapabilities;
    async fn health_check(&self, request: HealthCheck) -> ProviderHealth;
    async fn list_models(&self) -> Result<Vec<ModelDescriptor>>;
    async fn generate(&self, request: GenerateRequest) -> Result<GenerateStream>;
    async fn embed(&self, request: EmbedRequest) -> Result<Vec<Embedding>>;
}
```

`ProviderCapabilities` must describe streaming, tool calls, structured output,
vision, audio, embeddings, model listing, maximum context, and endpoint
compatibility. Feature code asks for capabilities; it does not switch on
provider names.

Every request carries:

- purpose (`ask`, `scribe`, `embedding`, `next_action`, `title`, `test`);
- data classes included;
- source count and byte/token estimate;
- redaction result;
- provider profile ID and exact endpoint host;
- timeout, retry budget, and cancellation token;
- local audit ID.

The local audit log stores metadata, not prompt bodies, by default.

## 4. BYOK implementation

### 4.1 Provider profiles

Persist a non-secret profile:

```json
{
  "id": "uuid",
  "provider": "openai",
  "display_name": "My OpenAI project",
  "endpoint": "https://api.openai.com/v1",
  "region": null,
  "model": "user-selected-model-id",
  "embedding_model": "user-selected-embedding-model-id",
  "credential_ref": "credential-vault-id",
  "data_boundary_ack_version": 1,
  "created_at": "RFC3339",
  "last_tested_at": "RFC3339",
  "last_test_status": "ok"
}
```

Never persist `apiKey`, access key, secret key, session token, authorization
header, or a full credential in the profile.

### 4.2 OpenAI

- Default base URL: `https://api.openai.com/v1`.
- Use project-scoped/restricted keys where available and advise users to set a
  budget.
- Prefer the Responses API for new direct integration, with an isolated Chat
  Completions compatibility adapter only where existing model/provider behavior
  requires it.
- Do not hard-code a “latest” model in source indefinitely. Populate the picker
  from the Models API, then apply a versioned, tested recommendation registry.
- Support streaming, tool calls, structured JSON output, and request IDs.
- Never send the key through the Next.js webview or store it in the Tauri
  settings plugin.

Official references:

- [OpenAI API quickstart](https://developers.openai.com/api/docs/quickstart)
- [OpenAI API authentication](https://developers.openai.com/api/reference/overview#authentication)
- [OpenAI API-key safety](https://help.openai.com/en/articles/5112595-best-practices-for-api)

### 4.3 Anthropic Claude API

- Default base URL: `https://api.anthropic.com`.
- Use the Messages API and required API-version header.
- Store an Anthropic API key or future short-lived identity token as a distinct
  credential type.
- Normalize system messages, tool schemas, content blocks, streaming deltas,
  stop reasons, and usage without pretending the wire format is OpenAI.
- Show workspace/spend-limit guidance and a direct link to the Claude Console.

Official reference:

- [Claude API overview and authentication](https://platform.claude.com/docs/en/api/overview)

### 4.4 OpenRouter

- Default base URL: `https://openrouter.ai/api/v1`.
- Use bearer authentication and its OpenAI-compatible Chat Completions surface.
- Treat model slugs as provider-qualified values.
- Optional attribution headers must be visible in documentation and contain no
  user identity.
- Show OpenRouter’s routing/data-policy implications and provide a provider
  selection/privacy control where the API supports it.
- Validate the key with a fixed test request and distinguish invalid key,
  insufficient credit, rate limit, and upstream-provider failure.

Official reference:

- [OpenRouter quickstart](https://openrouter.ai/docs/quickstart)

### 4.5 Amazon Bedrock

Bedrock is not just an “API-key text box.” The UI must support:

1. short-term Bedrock API key, with region and expiry awareness;
2. AWS SDK credential chain for advanced users;
3. access key ID + secret + optional session token only when the OS credential
   vault is available;
4. named AWS profile where supported;
5. region and model/inference-profile selection.

Prefer short-term credentials or roles for stronger-security use. Mark long-term
Bedrock API keys as exploratory and display their expiry/rotation needs. Use
official AWS signing/SDK behavior rather than implementing SigV4 ad hoc.

Support Bedrock’s current open APIs where practical and use Converse/Invoke for
models not covered by a compatible endpoint. Test region, authorization, model
access, and invocation separately so the UI can explain the actual failure.

Official references:

- [Amazon Bedrock quickstart](https://docs.aws.amazon.com/bedrock/latest/userguide/getting-started.html)
- [Amazon Bedrock API keys](https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys-reference.html)
- [Amazon Bedrock supported APIs](https://docs.aws.amazon.com/bedrock/latest/userguide/apis.html)

### 4.6 Local provider

Local-only must be a first-class provider, not an “advanced custom URL”:

- detect a local Ollama-compatible endpoint without contacting the internet;
- list installed models;
- explain minimum memory and likely performance;
- let the user assign separate chat, extraction, and embedding models;
- ship a tested small-model recommendation matrix per architecture;
- never download a model without showing size, license, source, and disk impact;
- verify that loopback URLs cannot be rewritten to a remote host through
  redirects or DNS rebinding;
- provide an optional bundled/on-device path only after model redistribution
  rights and update security are cleared.

### 4.7 Setup interaction

The Settings → AI flow:

1. **Choose where AI runs.** Local only is first. Direct providers are listed
   with “your account pays provider charges.”
2. **Read the boundary.** Show the exact endpoint host and data categories a
   feature may send. The default is only the minimum selected evidence.
3. **Add credential.** Use a password field with paste, reveal-while-pressed,
   clear, and “store in OS keychain” label.
4. **Choose models.** Separate “Answer,” “Background extraction,” and
   “Embeddings,” with one-click recommended defaults and estimated tradeoffs.
5. **Run diagnostics.** DNS/TLS, authentication, model list/access, fixed
   inference, structured output/tool support, and streaming are separate rows.
6. **Preview costs and retention.** Link to the provider’s billing and data
   policy. Do not claim provider-side zero retention unless the account and
   endpoint prove it.
7. **Save.** The UI receives only `{credential_present: true, suffix: "…abcd"}`.
8. **Test with my data** is a separate action after the fixed diagnostic.

Error messages must be actionable:

- invalid/revoked credential;
- credential expired;
- wrong Bedrock region;
- model access not granted;
- insufficient credit;
- rate limited with retry time;
- endpoint certificate/TLS error;
- proxy/firewall denial;
- incompatible structured output/tool use;
- local model not running;
- context too long.

### 4.8 Migration from historic presets

The current migration converts all OpenAI, Anthropic, custom, local, and
ChatGPT presets to `civitas-cloud` and drops the key/URL fields. Replace it with
a versioned migration that:

- never deletes a provider selection without a user-visible migration report;
- detects historic plaintext secrets;
- moves recoverable credentials into the OS vault;
- removes the plaintext only after a verified vault write;
- asks the user to re-enter a key if secure migration is impossible;
- retains prompts, context limits, model choices, and default roles;
- produces a local migration receipt without secret values;
- is idempotent and covered by fixture tests for every historic schema.

Do not restore ChatGPT consumer-session/OAuth workarounds as a supported public
provider unless OpenAI explicitly documents that client flow for third-party
desktop apps. An OpenAI API key and a ChatGPT subscription are different.

## 5. Local data and privacy design

### 5.1 Data classes

| Class | Examples | Default | Cloud eligibility |
| --- | --- | --- | --- |
| Raw visual | screenshots, frames, video | local, encrypted where feasible | never without one-time explicit selection |
| Raw audio | microphone/system audio | off or narrowly scoped during onboarding | never without one-time explicit selection |
| Accessibility | window titles, UI text/tree | local | only minimum evidence after preview |
| Typed/clipboard | keystrokes, clipboard values | off | prohibited by default |
| Transcript/OCR | extracted raw text | local | selected excerpts only |
| Derived graph | entities, claims, decisions, tasks, evidence links | local | selected minimum for BYOK inference |
| Provider metadata | model, tokens, request ID, cost estimate | local audit | provider necessarily receives request metadata |
| Product telemetry | feature counters and coarse performance | off | only after explicit consent; no work content |

### 5.2 Capture consent

Onboarding must not offer a single vague “record everything” consent. It should
walk through:

- screen capture;
- accessibility;
- microphone;
- system audio;
- clipboard;
- typed text;
- meeting detection;
- local retention;
- selected AI boundary.

For each, state purpose, example data, risk, storage location, and how to pause
or delete it. The user must be able to finish onboarding with only manual
capture enabled.

### 5.3 Local storage

- Encrypt settings and secrets separately.
- Evaluate SQLCipher or application-layer encryption for the SQLite database;
  document the threat model if relying on full-disk encryption.
- Use per-install data-encryption keys sealed by the OS vault.
- Exclude the data directory from cloud backup by default where platform APIs
  allow; document the choice.
- Use atomic writes and corruption recovery.
- Keep media and derived data retention separately configurable.
- Provide “delete source after derivation,” “delete media only,” and “delete
  everything” with an exact preview.
- Secure deletion cannot be guaranteed on SSDs; documentation must say so.
- Provide a portable export containing schema version, JSON/JSONL graph data,
  selected media, provenance, and checksums.
- Provide an intelligible “What Civitas knows” inspector and node-level delete.

### 5.4 Egress enforcement

Add a single Rust egress client:

- endpoint allowlist derived from the active provider profile;
- HTTPS required except explicit loopback HTTP;
- redirects disabled or revalidated against the allowlist;
- DNS rebinding/loopback protections;
- body-size and timeout limits;
- secret-safe structured logs;
- per-purpose redaction;
- request cancellation;
- test-only deny-all transport;
- a runtime `CIVITAS_NETWORK_MODE=deny` gate used in CI.

No feature may instantiate a raw `reqwest::Client` for an external host without
an approved exception. Enforce this with a lint/semgrep rule.

## 6. Consumer product refinement

### 6.1 Information architecture

Recommended top-level navigation:

- **Today** — recent context, commitments, and manually requested next actions;
- **Ask** — evidence-grounded query with source inspection;
- **Memory** — entities, topics, decisions, procedures, and contradictions;
- **Timeline** — local captured history with privacy controls;
- **Connections** — optional personal services and MCP clients;
- **Settings** — capture, privacy, AI provider, storage, shortcuts, updates.

Remove enterprise terminology such as endpoint plane, fleet, org intelligence,
employee, policy enforcement, entitlement, and company graph from the consumer
build and documentation.

### 6.2 Knowledge graph quality

Every visible assertion must preserve:

- source/evidence pointer;
- captured time and event time;
- confidence;
- extraction model/version;
- whether it is observed, inferred, user-confirmed, or user-authored;
- contradiction and supersession relationships;
- a “wrong” correction flow;
- deletion lineage so a deleted source cannot remain as an unexplained fact.

Improve entity resolution with:

- local alias management;
- explicit merge/split UI;
- deterministic normalization before LLM matching;
- conflict-safe merges;
- rollback;
- evaluation sets containing synthetic ambiguity;
- no auto-merge above a risk threshold.

Ask answers must distinguish:

1. direct evidence;
2. synthesis;
3. uncertainty or missing evidence.

If no grounded answer exists, abstain. Never fill a personal knowledge gap with
general model memory while presenting it as the user’s history.

### 6.3 Search and query

- unified lexical, semantic, temporal, and graph filters;
- app, project, person, date, evidence type, and confidence facets;
- visible query scope and excluded privacy zones;
- fast local first result;
- keyboard-first command palette;
- saved local queries;
- source preview without opening a remote service;
- deterministic export/copy with citations;
- benchmark targets for cold start, p50/p95 query latency, and index size.

### 6.4 MCP

- bind loopback only by default;
- generate per-client credentials;
- display every authorized client and last access;
- scope tools and data classes per client;
- support revoke and rotate;
- never expose raw media by default;
- include provenance in every response;
- rate limit and bound result size;
- defend against prompt injection in captured content by treating content as
  data, not instructions;
- document Claude, Codex, and other clients without assuming one vendor.

## 7. Predictive/“next action” feature

### 7.1 Archaeology

The feature existed and was removed. Relevant history:

- initial anticipatory suggester: `d4fd50a` / `9846b8b`;
- grounding and feedback improvements: `aaa2840`;
- panel/UI refinements: `307276a` / `d459153`;
- shortcut and anchored fallback: `5da0b20`;
- last pre-removal state: `fe52882a56`;
- removal: `279e214`, merged by `1a8acc1`.

The removed implementation included proactive scheduling, candidate
generation, reward scoring, suggestion events, UI panels, and operator
coupling. It is useful design evidence, not code to reinsert wholesale.

### 7.2 Product contract

Rename the public feature **Next actions**. Its contract:

- suggestions are hypotheses, never facts;
- the default surface is pull-based (“Show next actions”);
- optional ambient delivery is separately enabled and quiet;
- every suggestion explains “why now” and links to evidence;
- uncertainty is visible;
- no suggestion executes automatically;
- external communication, file mutation, purchase, deletion, or credential use
  always requires a fresh preview and approval;
- user feedback and suggestion history remain local;
- no forced exploration is shown to users;
- the system prefers silence over a weak interruption.

### 7.3 Candidate sources

Generate candidates deterministically before asking an LLM to word or rank:

1. explicit incomplete commitments made by the user;
2. deadlines or scheduled events with missing preparation;
3. recurring graph transitions with adequate support;
4. unresolved blockers whose prerequisite changed;
5. open loops from a recent work session;
6. user-authored routines;
7. query follow-ups the user explicitly saved.

Exclude:

- inferred commitments attributed only to another person;
- sensitive apps/categories;
- stale or contradicted evidence;
- anything requiring an unknown account or permission;
- personal/high-impact domains such as health, finance, legal, employment, or
  intimate relationships unless the user explicitly requests that domain;
- candidates with fewer than the required independent signals.

### 7.4 Evidence contract

Each candidate:

```json
{
  "id": "uuid",
  "title": "Prepare notes for tomorrow's design review",
  "kind": "prepare",
  "why_now": "The review is tomorrow and two unresolved decisions were captured",
  "evidence_ids": ["episode:...", "decision:...", "calendar:..."],
  "signals": ["near_deadline", "open_decisions"],
  "confidence": 0.86,
  "fresh_until": "RFC3339",
  "affected_apps": ["Civitas only"],
  "data_to_share": [],
  "action_mode": "draft",
  "risk": "low"
}
```

The validator rejects a candidate when:

- an evidence ID cannot be resolved;
- evidence is outside the active privacy scope;
- all evidence comes from one low-confidence extraction;
- the subject/owner is ambiguous;
- timing is stale;
- a near-duplicate was dismissed;
- the proposed action exceeds the candidate’s permission;
- model wording introduces a claim absent from evidence.

### 7.5 Ranking and calibration

Score interpretable factors:

- evidence strength;
- explicitness of commitment;
- urgency;
- current-context relevance;
- expected user effort;
- reversibility;
- prior user feedback for the same class;
- interruption cost;
- sensitive-domain risk.

Use a small calibrated model or transparent weighted ranker before an LLM.
Record feature values locally for evaluation. The LLM may compose concise copy
and a draft, but it cannot fabricate evidence or lift a rejected candidate.

### 7.6 UX

Next-action card:

- title and one-sentence benefit;
- confidence label using calibrated language, not a fake precise percentage;
- “Why now” evidence chips;
- exact apps/data that would be touched;
- preview;
- `Open`, `Draft`, or `Start` primary action;
- `Not useful`, `Wrong`, `Already done`, `Later`, and `Never suggest this`
  feedback;
- no countdown or manipulative urgency.

Ambient mode:

- off by default;
- quiet hours and focus-session awareness;
- at most one surfaced card per work block and a strict daily cap;
- no OS notification for medium/low confidence;
- dismissal produces a meaningful cooldown;
- never steals focus.

### 7.7 Evaluation and launch gates

Build a synthetic and consented private evaluation corpus. Do not put real user
capture into the public repository.

Offline metrics:

- candidate precision by class;
- evidence-validity rate;
- owner/subject accuracy;
- deadline accuracy;
- duplicate rate;
- sensitive-surface violation rate;
- abstention calibration;
- draft factuality;
- latency and provider cost.

Shadow-mode metrics, stored locally:

- would-show count;
- user review label;
- time-to-action;
- completion;
- undo/correction;
- interruption complaint;
- false-positive taxonomy.

Release gates:

- 100% resolvable evidence pointers;
- zero known sensitive-surface policy violations in the red-team suite;
- at least 90% precision for ambient-eligible suggestions in the reviewed
  evaluation set;
- at least 80% user-rated helpfulness for pull-based suggestions;
- ambient feature remains off until a separate beta gate;
- deterministic safe fallback when the provider is unavailable.

## 8. Enterprise-code separation

Use compile-time Cargo features and frontend build flags:

- `consumer` — default public build;
- `hosted-ai` — optional Civitas service;
- `team-sync` — optional/private adapter;
- `fleet` — private;
- `enterprise-policy` — private;
- `operator` — optional, local, consent-gated;
- `dev-evals` — excludes private corpora from release artifacts.

Consumer build must exclude:

- app entitlement gate;
- mandatory sign-in;
- Supabase/Clerk organization boot path;
- fleet heartbeat and device posture;
- mandatory team filters/policy;
- central derived-note sync;
- admin UI;
- employee analytics;
- Railway service URLs;
- enterprise-only connectors or customer-specific logic;
- private strategy and deployment docs.

Keep useful generic connectors only when their OAuth/client-secret story is
appropriate for an open desktop app. Prefer local tokens or user-created OAuth
apps; do not ship Civitas production OAuth secrets.

CI must inspect the release binary and packaged web assets for forbidden
domains and feature symbols.

## 9. Desktop security hardening

### 9.1 Tauri

Replace the current broad capability file with per-window capabilities:

- main app;
- Ask overlay;
- settings;
- updater;
- optional browser/connection flow.

Each gets only needed commands, filesystem paths, and URL schemes. Remove
wildcard windows, broad home-directory access, unrelated developer-tool
directories, arbitrary HTTPS shell open, and general write/remove scopes.

Set a production CSP that:

- has no `unsafe-eval`;
- avoids broad `https:` where exact hosts are possible;
- disables remote framing by default;
- restricts images/media to local asset protocols and documented exceptions;
- restricts connections to loopback plus the selected provider through Rust;
- prevents the webview from making provider calls directly.

### 9.2 Loopback API

- bind `127.0.0.1`/`::1`, never all interfaces by default;
- random per-install authentication;
- origin validation;
- CSRF protection for state-changing HTTP routes;
- WebSocket authentication;
- request-size and rate limits;
- no secrets in query strings;
- no raw frame endpoint for unauthenticated clients;
- security headers even on loopback;
- clear port-conflict behavior;
- LAN mode as a separate dangerous setting with firewall guidance.

### 9.3 Capture abuse cases

Threat model:

- another local process reading the DB;
- malicious site causing loopback requests;
- prompt injection in captured webpages/messages;
- secrets appearing in OCR, clipboard, typed text, logs, or screenshots;
- untrusted MCP client extracting history;
- malicious provider endpoint exfiltrating data;
- update-channel compromise;
- symlink/path traversal in export and media;
- plugin/pipe code execution;
- shared-machine account boundaries;
- crash dumps containing content.

Add tests and mitigations for each. Commission an independent penetration test
before general availability.

### 9.4 Supply chain

- GitHub Actions pinned by immutable commit SHA;
- least-privilege workflow `permissions`;
- checkout credentials disabled after source retrieval;
- protected environments for signing and release;
- retained native/tool archives pinned by immutable URL, exact byte count, and
  digest, with atomic verified-download helpers;
- no implicit build-time package-manager or `curl | shell` bootstrap;
- licensed benchmark corpora kept outside Git, verified against publisher
  metadata, and excluded from uploaded artifacts except aggregate metrics;
- OIDC where services support it;
- no secrets on pull-request workflows;
- Dependabot/Renovate;
- CodeQL for Rust/TypeScript where supported;
- RustSec, `cargo deny`, npm/bun audit, license policy;
- secret scanning and push protection;
- artifact attestations;
- SBOM in SPDX or CycloneDX;
- reproducibility investigation and documented non-reproducible signing steps;
- release job isolated from untrusted build scripts.

## 10. Compliance and user rights

This is an engineering control plan, not a legal opinion. Counsel must map
actual distribution and provider practices to applicable law.

Engineering baseline:

- privacy by design/default;
- purpose limitation and data minimization;
- understandable consent before capture;
- local access and correction;
- portable export;
- deletion;
- documented retention;
- processor/provider disclosure;
- no sale or advertising use of work data;
- no dark patterns;
- age/household-use assessment;
- accessibility review;
- incident response and vulnerability disclosure;
- export-control review for bundled encryption;
- copyright/trademark and model-license review.

Publish:

- `PRIVACY.md` for product behavior;
- `SECURITY.md` for vulnerability reporting and supported versions;
- data-flow diagram;
- outbound network inventory;
- provider-specific disclosure;
- retention/deletion guide;
- release security and verification guide.

## 11. Desktop distribution and updater

### 11.1 Build

- build on a pinned supported macOS runner;
- universal or separately labeled arm64/x86_64;
- deterministic dependency resolution;
- no hard-coded personal development certificate;
- Developer ID Application signing;
- hardened runtime and reviewed minimal entitlements;
- timestamp;
- notarize with `notarytool`;
- staple;
- verify with `codesign --verify --deep --strict`,
  `spctl --assess --type execute`, `xcrun stapler validate`, and a clean-machine
  launch.

Apple’s current distribution guidance requires a valid Developer ID identity
and hardened runtime for notarized software distributed outside the Mac App
Store. The release workflow must fail closed if signing/notarization inputs are
absent.

### 11.2 Windows installer

- build on pinned `windows-2022` using the reviewed x86-64 MSVC target;
- verify every downloaded native dependency by exact digest and byte count;
- require timestamped Authenticode signatures on the application and NSIS
  installer using the expected publisher;
- fail before building when any release-signing credential is absent;
- scan the bundle for credential-shaped files, high-confidence secret bytes,
  and model weights that belong behind explicit download consent;
- perform an isolated clean install, verify the installed signature, and run
  the uninstaller;
- publish the installer, checksum, SBOM, and GitHub provenance from the same
  immutable tag.

Official releases must never instruct a user to override SmartScreen for an
unsigned binary. A source build may be documented separately but is not the
official Windows download.

### 11.3 Release contents

Each GitHub Release:

- release notes with privacy/network changes highlighted;
- DMG artifact(s);
- Windows x86-64 installer;
- checksum file;
- SBOM;
- third-party notices;
- source archive generated by GitHub plus an explicit commit ID;
- provenance/attestation;
- updater signature and manifest;
- minimum OS/architecture;
- known issues and rollback instructions.

### 11.4 Updates

- opt-in or explicit onboarding choice;
- stable/beta channels;
- signed manifests and artifacts;
- no downgrade without confirmation;
- staged rollout and kill switch that does not collect device identity;
- show version, size, checksum/signature status, and release notes;
- preserve local data and provider profiles;
- rollback-tested schema migrations;
- no update telemetry when analytics is off.

## 12. README, brand, and documentation

### 12.1 README structure

The public README should answer, in this order:

1. What does Civitas do for one person?
2. What stays local?
3. What leaves the device in each AI mode?
4. Show a 30–60 second visual demo.
5. Download the verified macOS DMG or Windows installer.
6. Three concrete use cases.
7. How the knowledge graph and evidence work.
8. How to configure local AI or BYOK.
9. How to pause/delete/export.
10. Build from source.
11. Roadmap, contributing, security, license, provenance.

Avoid unprovable superlatives and enterprise comparisons. Trust and a crisp
demo will be more persuasive than a long feature inventory.

### 12.2 Brand

Add a repository-local SVG header to each related README:

- the canonical **circular interlocking Civitas mark** used by
  `apps/civitas-app-tauri/public/civitas.svg` — not a “C” monogram, pillar
  symbol, or rounded-square app-icon treatment;
- repository name (`Civitas Desktop`, `Civitas Cloud`, or
  `Civitas Platform`);
- accessible title/description;
- dark/light-safe palette;
- an artistic editorial serif wordmark stack or reviewed outlined lettering so
  GitHub does not depend on a remote font;
- a composed visual system—orbital lines, evidence/graph nodes, subtle texture,
  and repository-specific accents—rather than a logo placed beside plain text;
- no tracking pixel, remote font, or external image dependency.

The private cloud/platform README headers can be branded while clearly saying
the repositories remain private operational components. The public desktop
README must not link users into inaccessible repos as required setup.

### 12.3 Documentation set

- quickstart for DMG;
- build-from-source;
- local-only setup;
- OpenAI setup;
- Anthropic setup;
- OpenRouter setup;
- Bedrock setup;
- provider privacy/cost comparison;
- knowledge graph concepts;
- Ask/query examples;
- Next actions safety contract;
- MCP setup;
- capture/privacy guide;
- data export/delete;
- architecture;
- threat model;
- network inventory;
- troubleshooting;
- contributing;
- release verification;
- provenance/license.

Every command is tested in CI or by a documented release smoke test.

## 13. GitHub public-repository setup

Before visibility changes:

- create the sanitized public root;
- complete secret/PII review;
- delete or sanitize historic Actions logs/artifacts as appropriate;
- configure organization base permissions;
- enable 2FA requirements;
- enable issues and discussions;
- add `LICENSE.md`, `NOTICE.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`,
  `CONTRIBUTING.md`, support policy, and governance;
- add issue forms and pull-request template;
- enable dependency graph, Dependabot alerts/updates, secret scanning, push
  protection, code scanning, and private vulnerability reporting;
- add branch ruleset with required review/status/signatures as decided;
- protect release tags;
- restrict GitHub Actions to approved actions and SHA pins;
- set topics, social preview, description, homepage, and funding only when
  accurate;
- configure a public roadmap with no private customer content.

GitHub makes all repository content and Actions history visible when a private
repository becomes public. Treat the final visibility change as a deployment,
with a written go/no-go and rollback limitation.

## 14. Quality strategy

### 14.1 Automated test matrix

| Area | Unit | Integration | E2E | Release gate |
| --- | --- | --- | --- | --- |
| Capture permissions | policy and state machine | OS adapters | clean-user onboarding | no capture before consent |
| Storage | migrations, encryption, retention | corruption/recovery | export/delete | no orphaned source/derived data |
| Provider router | normalization, errors, redaction | recorded provider contracts | live opt-in smoke | no secret persistence/logging |
| Local-only | provider and network deny | full pipeline | offline machine | zero outbound sockets |
| Knowledge graph | extraction schema, resolver | provenance/deletion | Ask examples | groundedness threshold |
| Next actions | validator/ranker | shadow corpus | approval UX | precision/safety thresholds |
| MCP | auth/scopes/injection | client contracts | common clients | no unauthorized raw access |
| Telemetry | versioned consent migration | fail-closed web-event sanitizer; no native crash uploader | packet capture | no analytics event before consent; no crash upload |
| Updater | manifest/signature | staged server | upgrade/rollback | invalid signature rejected |
| Packaging | entitlements/CSP | notarization | clean Macs | Gatekeeper accepted |

### 14.2 Performance budgets

Set budgets after measuring representative hardware:

- idle CPU and memory;
- capture CPU/GPU;
- battery drain;
- media disk growth per hour;
- cold startup;
- first search result;
- p50/p95 Ask latency excluding provider time;
- graph extraction backlog;
- local model memory;
- update size.

Publish the methodology and hardware. Do not cherry-pick only Apple Silicon
high-end results.

### 14.3 Accessibility

- complete keyboard navigation;
- VoiceOver labels and focus order;
- visible focus;
- color contrast;
- reduced motion;
- text scaling;
- no status encoded by color alone;
- accessible capture indicator and emergency pause;
- automated checks plus manual VoiceOver audit.

## 15. Implementation phases and issue breakdown

Durations are estimates for sequencing, not release promises. Security and
evaluation gates determine progress.

### Phase 0 — freeze, archive, and inventory

Status: archive complete; audit in progress.

Deliverables:

- exact private archives;
- clean working branches;
- repository/file/dependency inventory;
- network endpoint map;
- history secret scan;
- PII/corpus inventory;
- fork/provenance map;
- current feature and release workflow map;
- predictive-feature archaeology.

Exit gate: owner acknowledges the publication matrix and clean-history
strategy.

### Phase 1 — legal, history, and repository sanitation

Work packages:

- PUB-001 restore license and notice;
- PUB-002 third-party source attribution audit;
- PUB-003 model/binary/media asset license audit;
- PUB-004 PII corpus classification;
- PUB-005 synthetic fixture generator;
- PUB-006 replace real benchmark/capture data;
- PUB-007 full-history secret scan and credential rotation;
- PUB-008 create sanitized public root;
- PUB-009 independent history review;
- PUB-010 counsel approval.

Exit gate: two-person sign-off that public history contains no known secrets,
personal capture, customer data, or unlicensed assets.

### Phase 2 — consumer product boundary

Work packages:

- PUB-020 default `consumer` build feature;
- PUB-021 remove mandatory entitlement/sign-in;
- PUB-022 isolate hosted AI;
- PUB-023 isolate team sync;
- PUB-024 isolate fleet/policy;
- PUB-025 remove private repo/runtime dependency;
- PUB-026 consumer navigation and copy;
- PUB-027 consumer configuration schema;
- PUB-028 release-binary forbidden-domain check;
- PUB-029 account-free onboarding tests.

Exit gate: a fresh user can capture manually, search, inspect, export, and
delete without a Civitas account or Civitas host.

### Phase 3 — local inference and BYOK

Work packages:

- PUB-030 provider-neutral Rust interface;
- PUB-031 OS credential-vault abstraction;
- PUB-032 no-plaintext-fallback enforcement;
- PUB-033 egress policy client;
- PUB-034 local provider;
- PUB-035 OpenAI adapter;
- PUB-036 Anthropic adapter;
- PUB-037 OpenRouter adapter;
- PUB-038 Bedrock adapter;
- PUB-039 custom-compatible adapter;
- PUB-040 settings/setup UX;
- PUB-041 model/capability registry;
- PUB-042 safe historic preset migration;
- PUB-043 provider contract tests;
- PUB-044 deny-network E2E;
- PUB-045 provider docs and troubleshooting.

Exit gate: local-only full pipeline passes with zero egress, and every BYOK
provider passes credential, capability, cancellation, redaction, and error
tests.

### Phase 4 — privacy and security

Work packages:

- PUB-050 versioned telemetry consent;
- PUB-051 audit every PostHog/Sentry call;
- PUB-052 capture consent redesign;
- PUB-053 capture indicator/emergency pause;
- PUB-054 privacy zones and sensitive-app policy;
- PUB-055 retention/export/delete;
- PUB-056 Tauri per-window capabilities;
- PUB-057 production CSP;
- PUB-058 loopback auth/scopes;
- PUB-059 MCP client management;
- PUB-060 threat model;
- PUB-061 static security rules;
- PUB-062 fuzzing/property tests;
- PUB-063 independent security review and remediation.

Exit gate: privacy packet-capture suite and threat-model acceptance pass.

### Phase 5 — knowledge graph and Ask quality

Work packages:

- PUB-070 provenance state model;
- PUB-071 deletion propagation;
- PUB-072 contradiction/supersession UI;
- PUB-073 entity merge/split/rollback;
- PUB-074 grounded answer contract;
- PUB-075 abstention;
- PUB-076 search facets and saved queries;
- PUB-077 synthetic quality benchmark;
- PUB-078 latency/storage budgets;
- PUB-079 user correction flow.

Exit gate: quality, groundedness, deletion, and performance thresholds pass.

### Phase 6 — Next actions

Work packages:

- PUB-080 extract reusable concepts from `fe52882a56`;
- PUB-081 candidate schema and local tables;
- PUB-082 deterministic candidate generators;
- PUB-083 evidence validator;
- PUB-084 risk/sensitivity policy;
- PUB-085 transparent ranker;
- PUB-086 provider composition adapter;
- PUB-087 pull-based cards and preview;
- PUB-088 local feedback/cooldowns;
- PUB-089 shadow mode;
- PUB-090 evaluation harness;
- PUB-091 approval-bound draft/action handoff;
- PUB-092 optional ambient beta behind explicit toggle.

Exit gate: evidence, precision, sensitive-domain, and user-helpfulness gates
pass. Ambient remains disabled by default.

### Phase 7 — release engineering

Work packages:

- PUB-100 minimal release workflow permissions;
- PUB-101 pinned actions and dependencies;
- PUB-102 Developer ID/hardened runtime;
- PUB-103 notarization/stapling verification;
- PUB-104 architecture matrix;
- PUB-105 SBOM/licenses/checksums/provenance;
- PUB-106 GitHub Release publication;
- PUB-107 updater signature/channel;
- PUB-108 clean-machine install;
- PUB-109 upgrade/rollback/data migration;
- PUB-110 emergency release runbook.

Exit gate: release candidate installs, runs, upgrades, rolls back, and verifies
on clean supported systems.

### Phase 8 — documentation and public launch

Work packages:

- PUB-120 SVG wordmarks and social preview;
- PUB-121 public README;
- PUB-122 60-second demo and screenshots using synthetic data;
- PUB-123 provider guides;
- PUB-124 privacy/network/security docs;
- PUB-125 contribution/governance templates;
- PUB-126 public roadmap;
- PUB-127 GitHub security/ruleset configuration;
- PUB-128 launch checklist;
- PUB-129 visibility change;
- PUB-130 launch monitoring and incident coverage.

Exit gate: all P0 items complete, release signed, owner/counsel/security go, and
support coverage scheduled.

### Phase 9 — post-launch quality and growth

- publish a predictable release cadence;
- label good first issues that are truly bounded;
- respond to security reports and regressions quickly;
- maintain public benchmarks;
- write technical deep dives on provenance, local privacy, graph correction,
  and calibrated next actions;
- publish integrations that solve real workflows;
- run community demos and office hours;
- track activation, retention, successful queries, correction rate, and
  uninstall reasons only through opt-in and privacy-preserving mechanisms;
- never purchase stars, spam communities, or game GitHub ranking.

## 16. Path to a high-star repository

Ten thousand stars cannot be guaranteed or engineered through polish alone.
The controllable strategy is:

1. **Immediate value:** install and get a useful, private result in under ten
   minutes.
2. **Trust:** local-only works, privacy claims are testable, and source
   provenance is visible.
3. **Memorable demo:** “What did I decide, why, and what should I do next?” over
   a synthetic but realistic week of work.
4. **Differentiation:** evidence-linked temporal graph and correction, not a
   generic chat wrapper.
5. **Excellent packaging:** signed DMG, one-command source build, honest
   compatibility.
6. **Contributor experience:** clear architecture, fast tests, bounded issues,
   respectful reviews.
7. **Technical credibility:** public evals, threat model, benchmarks, and
   incident transparency.
8. **Sustained usefulness:** integrations and workflows chosen from repeated
   user needs, not launch-day breadth.

Leading indicators:

- README-to-download conversion;
- successful first capture and first grounded answer;
- local-only activation;
- week-one return rate;
- correction/false-answer rate;
- next-action helpfulness;
- crash-free sessions;
- issue response time;
- contributor first-PR success;
- release adoption and rollback rate.

Stars are a lagging signal. Never weaken privacy, add covert telemetry, or
overstate functionality to optimize it.

## 17. Risk register

| Risk | Severity | Mitigation | Release owner |
| --- | --- | --- | --- |
| Historic PII becomes forkable | Critical | clean root, two-person review, private archive | repository owner |
| Leaked production credential | Critical | full scan, rotate, GitHub push protection | security |
| Misleading “local” claim | Critical | deny-network E2E and generated inventory | desktop lead |
| BYOK secret exposed in webview/settings/log | Critical | Rust vault, secret-taint tests, no fallback | security |
| Screen capture begins without informed consent | Critical | permission state machine and clean-user E2E | product/privacy |
| Prompt injection causes data/action abuse | Critical | content/data separation, tool scopes, preview | AI/security |
| Invalid fork licensing | Critical | provenance audit and counsel | legal |
| Update compromise | Critical | signatures, protected environment, provenance | release |
| Next action is wrong or intrusive | High | pull default, evidence validator, abstention, caps | AI/product |
| Enterprise code leaks private operations | High | build features, forbidden-domain/symbol check | architecture |
| Data deletion leaves derived facts | High | deletion lineage and integrity tests | data |
| Provider behavior/privacy changes | High | versioned registry, docs review, visible boundary | integrations |
| DMG fails Gatekeeper | High | notarized clean-machine release gate | release |
| Local model performs poorly | Medium | hardware matrix and honest recommendations | AI |
| Large repo deters contributors | Medium | modular docs, fast focused test targets | maintainers |
| Support load after launch | Medium | staged beta, templates, triage rotation | community |

## 18. Final go/no-go checklist

### Repository

- [ ] Only approved public repository is visible.
- [ ] Private archives remain private and archived.
- [ ] Sanitized history object IDs recorded.
- [ ] No private sibling is required.
- [ ] License, notice, security, privacy, conduct, contributing present.
- [ ] Branch/tag rules and security features enabled.

### Product

- [ ] No account required.
- [ ] Manual/local-only onboarding works.
- [ ] Capture is visibly active and immediately pausable.
- [ ] Search, graph, Ask, export, delete work.
- [ ] Local-only mode has zero egress.
- [ ] BYOK providers pass diagnostics.
- [ ] Next actions meet evaluation gates and do not auto-execute.

### Privacy/security

- [ ] Optional analytics is off before versioned consent and no automatic
  crash-upload path exists.
- [ ] No work content in telemetry.
- [ ] Credential vault has no plaintext fallback.
- [ ] Network inventory accurate.
- [ ] Tauri/CSP/loopback scopes reviewed.
- [ ] Threat model and penetration-test critical findings closed.
- [ ] Incident and vulnerability-response plan staffed.

### Release

- [ ] Developer ID signed.
- [ ] Hardened runtime.
- [ ] Notarized and stapled.
- [ ] Clean-machine Gatekeeper pass.
- [ ] Checksums/SBOM/notices/provenance published.
- [ ] Update signature, upgrade, rollback pass.
- [ ] Release notes disclose data-boundary changes.

### Communication

- [ ] README claims verified against release binary.
- [ ] Synthetic demo contains no real person/customer data.
- [ ] Provider cost/data disclosures current.
- [ ] Known limitations explicit.
- [ ] Launch support coverage confirmed.

No single stakeholder may waive a critical privacy, licensing, credential, or
release-signing gate. Any exception requires a written, time-bounded risk
acceptance by the repository owner, security owner, and counsel where
applicable.
