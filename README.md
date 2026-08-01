<p align="center">
  <img src="docs/assets/civitas-desktop-wordmark.svg" width="820" alt="Civitas Desktop">
</p>

<p align="center">
  <a href="https://github.com/civitass/civitas-desktop/releases"><img alt="GitHub release" src="https://img.shields.io/github/v/release/civitass/civitas-desktop?style=flat-square&color=8b2327"></a>
  <a href="LICENSE.md"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-1d1d1f?style=flat-square"></a>
  <a href="https://github.com/civitass/civitas-desktop/actions/workflows/release-app.yml"><img alt="Release verification" src="https://img.shields.io/github/actions/workflow/status/civitass/civitas-desktop/release-app.yml?style=flat-square&label=release%20gates"></a>
  <img alt="Local first" src="https://img.shields.io/badge/data-local--first-675d58?style=flat-square">
  <img alt="No account required" src="https://img.shields.io/badge/account-not%20required-675d58?style=flat-square">
</p>

<p align="center">
  <strong>Your private, evidence-linked memory for everyday work.</strong><br>
  Find what happened, understand why it happened, and decide what to do next—
  without sending your entire history to a hosted Civitas service.
</p>

<p align="center">
  <a href="https://github.com/civitass/civitas-desktop/releases"><strong>Download for macOS</strong></a>
  &nbsp;·&nbsp;
  <a href="docs/BUILDING.md">Build from source</a>
  &nbsp;·&nbsp;
  <a href="docs/BYOK.md">Connect your AI</a>
  &nbsp;·&nbsp;
  <a href="docs/PRIVACY_AND_DATA_BOUNDARY.md">Privacy boundary</a>
</p>

---

## Your work has a memory. Make it useful.

Civitas turns the work context you choose into a personal knowledge graph of
people, projects, decisions, reasons, blockers, procedures, and commitments.
Every answer and suggestion can lead back to local evidence, so you can inspect
what Civitas used instead of trusting a fluent guess.

It is built for one person recovering context across apps—not for employee
monitoring, fleet administration, or a company control plane. Capture, search,
the timeline, the graph, feedback, and profile metadata stay on your Mac by
default. AI is either loopback-local or a provider you explicitly connect.

## See the day. Act on what matters.

Civitas keeps the original moment close. Move through your private Timeline to
recover what was on screen, then use evidence-backed action prediction in Next
Actions to surface grounded commitments and open loops—with the reason,
evidence age, risk, and control still visible.

<p align="center">
  <a href="docs/assets/demo/timeline.png">
    <img src="docs/assets/demo/timeline.png" width="1200" alt="The actual Civitas Desktop Timeline showing a synthetic Northstar launch brief and local time scrubber">
  </a>
</p>

<p align="center"><em>Timeline — return to a captured moment without sending the history off the Mac.</em></p>

<p align="center">
  <a href="docs/assets/demo/next-actions.png">
    <img src="docs/assets/demo/next-actions.png" width="1200" alt="The actual Civitas Desktop Next Actions view showing a ranked synthetic commitment with its evidence and safety state">
  </a>
</p>

<p align="center"><em>Next Actions — evidence-backed continuations that remain drafts until you choose otherwise.</em></p>

> These are captures of the real desktop application using an isolated,
> synthetic local profile. They contain no founder, contributor, or customer
> data. The same privacy-safe capture is exercised by the publication E2E suite.

## Three everyday wins

| When you need to… | Civitas helps you… | Without hiding… |
| --- | --- | --- |
| Recover a decision | Search across apps and time, then open the supporting local moment | the source, evidence age, or uncertainty |
| Re-enter a project | Reconstruct people, state changes, blockers, procedures, and reasons | where the graph inferred a relationship |
| Close open loops | Review ranked commitments and follow-ups in Next Actions | confidence, safety state, or your feedback controls |

## Start in three steps

1. Download the verified macOS DMG from
   [GitHub Releases](https://github.com/civitass/civitas-desktop/releases), or
   [build from source](docs/BUILDING.md).
2. Choose exactly what Civitas may capture. Screen and microphone permissions
   remain separate, and capture can be paused immediately from the tray.
3. Search locally first. If you want AI answers, add a local model or one of
   your own provider credentials under **Settings → AI**.

## What you can do

- **Remember the day.** Search screen text, accessibility context, and local
  transcripts across time, apps, projects, and people, with local multilingual
  OCR including explicit Simplified and Traditional Chinese support.
- **Ask with evidence.** Get an answer that separates direct evidence,
  synthesis, and uncertainty, with links back to the source.
- **See relationships.** Explore decisions and reasons, changing project state,
  recurring procedures, blockers, and contradictions in the knowledge graph.
- **Review Next Actions.** Pull a ranked set of evidence-backed suggestions,
  see why each one appeared, and choose Done, Not now, or Dismiss. Suggestions
  never execute by themselves.
- **Keep meeting context.** Detect meetings, create local notes, inspect
  transcripts, and export only what you choose.
- **Use your memory elsewhere.** Give a permissioned MCP client bounded,
  authenticated access to search and provenance-aware graph tools.

## The trust contract

| Promise | What the consumer build does |
| --- | --- |
| Local first | Capture, media, SQLite/FTS indexes, graph data, feedback, and provider profile metadata live under your local Civitas data directory. |
| Account-free | Capture, search, graph, export, deletion, local AI, and MCP do not require a Civitas login or subscription. |
| No hidden cloud | Railway, Supabase auth, Civitas-hosted AI credits, fleet, team sync, and enterprise policy are not part of the consumer runtime. |
| Bring your own model | Use loopback Ollama-compatible inference or connect OpenAI, Anthropic, OpenRouter, Bedrock, or a compatible endpoint. |
| Credentials stay protected | Persistent keys are encrypted with an OS-vault-backed key; an explicit session-only mode stays in process memory until quit. No plaintext fallback exists. |
| Capture is controllable | The tray shows capturing/paused/private state and provides immediate, timed, and indefinite pause controls. Clipboard and raw typed-text persistence are off by default. |
| Suggestions are drafts | Next Actions exposes evidence, confidence, safety state, and feedback controls. It cannot auto-execute. |

> [!IMPORTANT]
> A remote AI provider receives the prompt and selected evidence for requests
> made with that profile. Civitas shows the exact destination and requires a
> data-boundary acknowledgement before activation. Provider terms, retention,
> routing, and charges apply. See [Bring your own AI](docs/BYOK.md).

## How it works

```text
the apps and meetings you choose
              │
              ▼
  local screen · accessibility · audio capture
              │
              ▼
       SQLite + FTS5 + local media
              │
      ┌───────┴────────┐
      ▼                ▼
 timeline/search   evidence-linked graph
      │                │
      └───────┬────────┘
              ▼
       Ask · Next Actions · MCP
              │
              ▼
 local model, or a remote provider you explicitly configure
```

The desktop app and engine run on the user's computer. The engine binds its
authenticated API to `127.0.0.1:3030`; there is no LAN setting or service
discovery. Local capture and lexical query work without an AI provider.

When an AI feature runs, the loopback inference gateway loads the active
profile and credential in Rust. Official provider profiles pin the provider
host, reject redirects and URL credentials, and record only bounded technical
request metadata—not prompt content—in the local audit table.

## Next Actions, rebuilt for trust

The earlier predictive-action concept was recovered from repository history and
adapted to the current local architecture as a pull-based feature.

Candidates come from grounded local signals such as explicit commitments,
unresolved blockers, owner-enabled saved-search follow-ups, decision
follow-ups, recent task-like evidence, and stale open loops. Saved-search
follow-ups are opt-in, interval-bounded, and reopen the exact local query and
filters. The ranker considers evidence strength, recency, confidence,
duplication, feedback, cooldowns, and ambiguity. It suppresses expired,
unsupported, sensitive, or high-risk candidates.

Every visible card can show:

- the proposed action and why it matters;
- the local evidence and its age;
- confidence and uncertainty;
- safety/approval state;
- Done, Not now, and Dismiss feedback.

No suggestion sends a message, edits a file, opens a browser, or invokes an
integration automatically.

## Choose where AI runs

| Choice | Credential | Destination | Useful when |
| --- | --- | --- | --- |
| Local loopback | None | `127.0.0.1` / `localhost` | You want prompts and evidence to remain on the computer |
| OpenAI API | Project API key | `api.openai.com` | Your OpenAI API project provides the models/capabilities you need |
| Anthropic | Anthropic API key | `api.anthropic.com` | You want direct Claude Messages API access |
| OpenRouter | OpenRouter API key | `openrouter.ai` and the chosen upstream route | You want a routed model catalog |
| Amazon Bedrock | Short-term key, AWS profile, or temporary access keys | Region-pinned Bedrock Runtime | You manage models and access in AWS |
| Compatible endpoint | Optional API key | Exact HTTPS or loopback host shown in Settings | You operate a trusted OpenAI-compatible server |

<p align="center">
  <a href="docs/assets/demo/ai-providers.png">
    <img src="docs/assets/demo/ai-providers.png" width="920" alt="The actual Civitas Desktop AI settings showing local inference and supported bring-your-own-provider choices">
  </a>
</p>

<p align="center"><em>Choose the boundary first. Add a credential only when a remote provider is intentional.</em></p>

The app provides save, replace, test, activate, and delete flows. Diagnostics
use the fixed prompt `Reply with OK.` and never return the credential.
[Provider setup](docs/BYOK.md) and the
[capability catalog](docs/MODEL_CATALOG.md) document the exact contract.

Conversational Ask and Chat additionally use an optional local assistant
runtime. It is absent on first launch: opening the app or Chat never downloads
it. **Settings → AI** shows its exact package/version, registry destination,
data boundary, and storage location before an explicit **Install runtime**
action. Civitas installs from its reviewed frozen lockfile with the bundled Bun
sidecar and disabled lifecycle scripts; it never falls back to system npm or a
global agent. Core capture, search, graph, export, and MCP features do not need
this runtime. The same card can stop active assistant sessions and remove the
managed packages without deleting work data, provider profiles, or credentials.

## Install on macOS

1. Open [GitHub Releases](https://github.com/civitass/civitas-desktop/releases).
2. Download the DMG for Apple Silicon or Intel and its checksum manifest.
3. Verify the checksum, Developer ID signature, notarization ticket, and GitHub
   provenance using [Release verification](docs/RELEASE_VERIFICATION.md).
4. Drag Civitas Desktop to Applications.
5. Grant only the capture permissions you intend to use.
6. Start with Local only, or add a provider in **Settings → AI**.

Official automation builds, signs, notarizes, staples, and attaches artifacts
to a draft release. A maintainer must verify and publish the draft; automation
cannot silently publish it.

## Build from source

The repository pins Rust `1.93.1` and Bun `1.3.10`.

```bash
git clone https://github.com/civitass/civitas-desktop.git
cd civitas-desktop

cargo build --locked

cd apps/civitas-app-tauri
bun install --frozen-lockfile
bun run tauri dev
```

An optimized local bundle:

```bash
cd apps/civitas-app-tauri
bun run tauri build
```

Platform prerequisites, feature flags, generated bindings, and release-vs-source
differences are in [Building](docs/BUILDING.md).

## Connect an MCP client

The safest setup is **Settings → Connections**, where Civitas can write a
client configuration with the exact package version and a dedicated,
server-enforced read-only credential. The device-owner API key is never copied
to an MCP client.

The configuration copied by Civitas has this shape:

```json
{
  "mcpServers": {
    "civitas": {
      "command": "npx",
      "args": ["-y", "civitas-mcp@0.18.10"],
      "env": {
        "CIVITAS_MCP_CREDENTIAL": "<issued-by-civitas>",
        "CIVITAS_MCP_SCOPES": "read"
      }
    }
  }
}
```

Use the in-app copy action rather than substituting the device-owner key
manually. Client credentials expire after 90 days by default and can be
inspected, rotated, or revoked under **AI client access**. Do not commit the
credential. MCP results enter the connected client and may be sent to that
client's model provider. The full scope and transport model is in [Civitas
MCP](packages/civitas-mcp/README.md).

## Architecture

| Layer | Main code | Responsibility |
| --- | --- | --- |
| Desktop | `apps/civitas-app-tauri` | Tauri v2, Next.js, onboarding, capture controls, Ask, graph, timeline, provider and connection settings |
| Engine/API | `crates/civitas-engine` | Loopback Axum API, capture orchestration, retrieval, inference gateway, graph workers, Next Actions |
| Screen/accessibility | `crates/civitas-screen`, `crates/civitas-a11y`, `crates/civitas-capture` | Event-driven local context capture |
| Audio | `crates/civitas-audio` | Local devices, VAD, transcription adapters, speaker/meeting pipeline |
| Storage | `crates/civitas-db`, `crates/civitas-vault`, `crates/civitas-secrets` | SQLite/FTS, media vault, encrypted credentials |
| Knowledge | `crates/civitas-mining` and engine graph workers | Episodes, entities, claims, decisions, procedures, provenance, resolution |
| Connections | `crates/civitas-connect` | Optional vault-backed local/personal integrations and safe local proxies |
| MCP | `packages/civitas-mcp` | Scoped bridge from trusted MCP clients to the authenticated loopback API |

Key local endpoints include:

```text
GET  /search
GET  /activity-summary
GET  /kg/entities/:name
GET  /kg/decisions
GET  /kg/procedures
GET  /kg/blockers
POST /kg/precedents
GET  /next-actions
POST /next-actions/feedback
GET  /next-actions/quality
POST /v1/chat/completions
GET  /health
```

Use the reviewed [checked-in OpenAPI snapshot](docs/openapi.yaml) when building
an integration. A running engine also serves its generated description at
`http://127.0.0.1:3030/openapi.yaml`. Live requests require the local bearer
credential. Authentication cannot be disabled in the consumer build.

## Privacy and security

- [Privacy policy](PRIVACY.md)
- [Privacy and data boundary](docs/PRIVACY_AND_DATA_BOUNDARY.md)
- [Portable data ownership](docs/PORTABLE_DATA.md)
- [Network boundary](docs/NETWORK_BOUNDARY.md)
- [Threat model](docs/THREAT_MODEL.md)
- [Security policy](SECURITY.md)
- [Release verification](docs/RELEASE_VERIFICATION.md)

For a stricter local session, pre-stage local models and launch with
`CIVITAS_NETWORK_MODE=deny`. This blocks reviewed remote inference, optional
product analytics, model downloads, and update paths. Crash diagnostics are
local files and are never uploaded automatically. Network-deny mode is not a
substitute for an OS firewall; the network document explains the remaining
explicit integration boundaries.

## Documentation

- [Building from source](docs/BUILDING.md)
- [Bring your own AI provider](docs/BYOK.md)
- [Model and capability catalog](docs/MODEL_CATALOG.md)
- [Local multilingual OCR](docs/OCR.md)
- [Local search and saved queries](docs/SEARCH.md)
- [Knowledge quality and performance evaluation](docs/QUALITY_EVALUATION.md)
- [Roadmap](ROADMAP.md)
- [Governance](GOVERNANCE.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Testing](TESTING.md)
- [Consumer publication and release gates](docs/publication/PUBLICATION_PLAN.md)
- [Architecture decisions](docs/adr/)

## Project principles

1. Evidence before fluency.
2. Abstain when personal history does not support an answer.
3. Local and visible before remote and ambient.
4. Permission is specific, revocable, and never inferred from captured text.
5. A suggestion is a draft until the user acts.
6. Privacy/security regressions block release.

## Fork provenance and license

Civitas is an MIT-licensed fork of
[Screenpipe](https://github.com/screenpipe/screenpipe) at upstream commit
`892199f7`, the last upstream commit released under MIT. Later proprietary
Screenpipe code and the upstream `ee/` directory are not included.

See [LICENSE.md](LICENSE.md), [NOTICE.md](NOTICE.md),
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), and the
[provenance ADR](docs/adr/0001-fork-provenance-and-licensing.md).

## Contributing

Privacy bugs, groundedness failures, accessible interaction improvements, local
model support, retrieval quality, and careful platform testing are especially
welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before opening a change.

For vulnerabilities, do not open a public issue; follow [SECURITY.md](SECURITY.md).
