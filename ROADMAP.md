# Civitas roadmap

Civitas is building a trustworthy personal memory for work: local capture,
evidence-linked retrieval, a knowledge graph that can be corrected, and useful
next steps that never act without the user.

This roadmap is a direction, not a promise of dates. Privacy, security,
groundedness, accessibility, and release integrity can delay any item.

## Now — publication candidate

- Make **Local only** a durable, fail-closed runtime boundary with visible
  blocked-request explanations.
- Complete provider capability discovery and phase-by-phase BYOK diagnostics
  for OpenAI, Anthropic, OpenRouter, Bedrock, and compatible endpoints.
- Finish atomic settings encryption, independent source/derived retention, and
  portable-data inspection.
- Replace UI-authored SQL with typed search contracts, saved local searches,
  and useful person/project/evidence facets.
- Validate Simplified and Traditional Chinese OCR on macOS, Windows, and Linux
  with synthetic, reproducible quality thresholds.
- Close graph groundedness, Next Actions usefulness, accessibility, performance,
  fuzz/property, clean-install, and clean-upgrade gates.
- Complete independent security/privacy review, legal review, history
  sanitation, signing, notarization, and clean-device verification.

The repositories remain private until the non-negotiable gates in the
[publication plan](docs/publication/PUBLICATION_PLAN.md) are complete.

## Next — public beta

- Improve correction-aware entity resolution and show extractor/model
  provenance throughout Ask and the graph.
- Add reproducible retrieval and groundedness benchmarks with public synthetic
  corpora.
- Expand local model support without turning first launch into a download.
- Improve cross-app project views, meeting continuity, and user-owned workflow
  templates.
- Publish extension-store and MCP-client setup guides with least-privilege
  presets.
- Build contributor fixtures and platform test kits that contain no personal
  capture data.

## Later — earned automation

Ambient or executing behavior is deliberately not part of the initial public
release. It can be considered only after pull-based Next Actions meets the
documented usefulness and safety thresholds.

Any future automation must be:

1. previewed with exact evidence and destination;
2. separately permissioned for the specific action;
3. reversible where the target system permits;
4. locally auditable;
5. disabled by default;
6. unable to interpret captured text as authorization.

## Explicit non-goals

- employee surveillance, productivity scoring, or manager dashboards;
- a required Civitas account, subscription, hosted credit pool, or cloud sync;
- silently uploading screen, audio, transcript, graph, prompt, or diagnostic
  content;
- automatic sending, editing, purchasing, deleting, or browser navigation;
- hiding uncertainty behind a fluent answer;
- promising a platform or provider before it passes its release gate.

## How priorities are chosen

Maintainers use this order:

1. privacy and security regressions;
2. data loss, corruption, or misleading success;
3. evidence quality and factuality;
4. accessibility and core consumer journeys;
5. reliability and performance;
6. compatible integrations;
7. polish and growth.

Feature proposals should describe the user journey, local/remote data boundary,
failure states, accessibility behavior, test strategy, and the smallest
permission set. See [CONTRIBUTING.md](CONTRIBUTING.md).
