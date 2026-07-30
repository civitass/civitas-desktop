# Vision

> “Civilization advances by extending the number of important operations which we can perform without thinking about them.” — Alfred North Whitehead

## What Civitas is

Civitas is a private, local-first memory for everyday work. It captures the
work context a person deliberately enables, turns that context into an
evidence-backed knowledge graph, and helps them understand what happened, why
it happened, and what is likely to need attention next.

Most personal operating knowledge never becomes a document. It is spread
across applications, meetings, repeated sequences, partial decisions, and the
small transitions that connect one task to another. Civitas makes that history
queryable without requiring a hosted Civitas account or a remote control plane.

The central promise is simple:

> Your work stays on your computer. You choose whether an AI model receives
> selected context, which provider receives it, and which workflows may act.

## Why we exist

People lose time reconstructing work they have already done:

- What did I decide in that meeting?
- Which document was I using before I was interrupted?
- Why did I choose this implementation?
- What should I follow up on today?
- How do I repeat a process that worked last time?

Ordinary search finds files and text fragments. Civitas reconstructs the
relationships between activity, entities, decisions, procedures, and evidence.
It should answer with citations, surface uncertainty, and make it easy to return
to the original local source.

## The product

1. **Capture locally.** Screen, accessibility, and audio capture are explicit,
   visible, pausable, and independently configurable. Capture is stored in the
   user-selected local data directory.
2. **Understand locally.** Civitas builds a local graph of entities, decisions,
   procedures, habits, and transitions. Derived records keep provenance back to
   the local evidence that produced them.
3. **Query with control.** Retrieval runs locally. A local model keeps the full
   query path on-device. If the user selects OpenAI, Anthropic, OpenRouter,
   Amazon Bedrock, or another compatible endpoint, Civitas sends only the
   bounded evidence needed for that request directly to that provider.
4. **Suggest carefully.** Next Actions rank useful continuations from recent,
   repeated, evidence-backed patterns. They distinguish observation from
   prediction, show why a suggestion exists, expose confidence, and remain easy
   to dismiss.
5. **Automate with least privilege.** Workflows are installed locally, disclose
   their schedules and data access, start disabled when they run in the
   background or call a remote model, and receive only declared API,
   connection, application, window, and content scopes.
6. **Interoperate locally.** The loopback API and MCP surface let user-controlled
   tools query Civitas with bearer authentication and provenance. They are not
   an invitation to expose the service to a network.

## Product principles

### Local is the default boundary

Capture, databases, embeddings, exports, logs, workflow packages, and derived
knowledge live on the user’s machine. Civitas does not require Railway,
Supabase, a Civitas login, or a Civitas-hosted inference service.

Remote model use is optional. When enabled, it is a direct relationship between
the user and their selected provider. The interface must identify the boundary
before a credential is saved and before a remote profile becomes active.

### Consent must be legible

Privacy is not a one-time onboarding paragraph. Every meaningful boundary has a
clear control:

- capture can be paused;
- applications and windows can be excluded;
- telemetry is off by default;
- remote AI profiles are opt-in;
- credentials are replace-only and stored in the OS-protected vault;
- background workflows are opt-in;
- destructive cleanup requires confirmation;
- data can be exported and deleted locally.

### Evidence before confidence

Every answer, learned relation, and suggested action should preserve its
evidence, time range, and confidence. The product must say when the graph is
empty, contested, stale, inferred, or incomplete. A useful fallback is better
than an invented answer.

### Suggestions must earn attention

Next Actions exist to reduce resumption cost, not to create another inbox. A
suggestion should be timely, concrete, non-duplicative, and supported by a
recognizable local pattern. Low-confidence candidates stay out of the primary
surface. Dismissal is feedback, not failure.

### Automation is capability-scoped

A workflow’s natural-language prompt is not a security boundary. Enforcement
belongs in the runtime:

- scoped local bearer tokens;
- exact route and method permissions;
- explicit connection declarations;
- application, window, and content filters;
- restricted subprocess environment;
- constrained filesystem and network access;
- bounded export ranges;
- audit-friendly results and failure messages.

Unknown, absent, or malformed permissions fail closed.

### No hidden dependency

The downloadable app and source build must work without a Civitas-operated
backend. Optional providers, update checks, telemetry, and external integrations
must fail independently without blocking capture, local history, graph search,
or export.

### Respect the machine

Civitas is a long-running desktop process. It should remain quiet, efficient,
and recoverable:

- no focus stealing;
- no hidden browser automation;
- no unexplained background network use;
- bounded CPU, memory, disk, and retry behavior;
- explicit storage retention controls;
- useful degraded modes when models or providers are unavailable.

## Engineering principles

- **Secure defaults.** Loopback binding, bearer authentication, restrictive
  content security policy, encrypted credentials, safe URL opening, and
  least-privilege workflow tokens are release requirements.
- **No secrets in source or artifacts.** Example configuration uses
  placeholders. Builds, logs, fixtures, and release archives are scanned before
  publication.
- **Reproducible releases.** Public releases carry checksums, an SBOM,
  provenance, signing/notarization evidence where applicable, and verification
  instructions.
- **Migration without revival.** Legacy hosted selections may be recognized only
  long enough to migrate them to safe local or BYOK settings. They must never
  reactivate removed services.
- **Platform honesty.** macOS is the polished primary distribution. Windows and
  Linux code paths are maintained only to the level documented and tested; the
  README must not imply parity that does not exist.
- **Small, reviewable boundaries.** Features should be separable, testable, and
  removable. Security checks live close to the resource they protect.
- **Public code is user documentation.** Comments, examples, tests, and error
  messages must describe the consumer product that actually ships.

## Design voice

- State facts. Avoid inflated promises.
- Brand text is `Civitas`; never all-caps branding.
- Use the correct circular Civitas mark.
- Prefer Apple-like restraint: system typography, calm hierarchy, generous
  space, grouped surfaces, precise alignment, subtle depth, and motion that
  explains state.
- Avoid decorative gradients, ornamental microcopy, novelty controls, emoji,
  and exclamation marks.
- Keep advanced detail available without making it the first thing a person
  must understand.
- When in doubt, remove.

## Measures that matter

- Time from installation to the first useful, cited answer.
- Retrieval and answer accuracy on a personal ground-truth evaluation set.
- Next Actions precision, dismissal rate, and time saved on task resumption.
- Entity false-merge and false-split rates.
- Percentage of important claims with inspectable provenance.
- Capture reliability and resource use over a full workday.
- D7 and D30 retention among people who completed local setup.
- Percentage of core use cases that work with networking disabled.
- Security and privacy regressions caught before release.

Repository stars are a signal of reach, not a product property. The path to a
widely adopted repository is a trustworthy app, an excellent first run,
credible documentation, reproducible releases, responsive maintenance, and a
clear reason to return.

## What we believe

- The best record of how work happens is the work itself.
- Personal context becomes useful when relationships and provenance are
  preserved.
- The person using Civitas owns the data, the credentials, and the decision to
  cross a network boundary.
- AI should make evidence easier to understand, not make uncertainty disappear.
- Useful software is calm, inspectable, and respectful.
