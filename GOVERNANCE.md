# Civitas governance

This document describes how the public Civitas project intends to make and
review decisions. It does not replace the repository owners' legal,
security-response, or release-signing responsibilities.

## Decision principles

- User ownership and safety outrank roadmap speed.
- Evidence outranks confidence or popularity.
- Local, visible, and reversible behavior precedes remote or ambient behavior.
- A privacy, security, licensing, or release-integrity gate cannot be waived by
  one person.
- Compatibility claims require a maintained test or an explicit limitation.
- The project records meaningful technical decisions in an ADR, pull request,
  or release note rather than in private chat alone.

## Roles

### Contributors

Anyone following the [Code of Conduct](CODE_OF_CONDUCT.md) can report bugs,
propose changes, improve documentation, add synthetic tests, or review a pull
request.

### Maintainers

Maintainers triage issues, review code and design, protect repository settings,
and decide whether a change satisfies the product and engineering contract.
Maintainer status is earned through sustained, careful contribution and can be
removed for inactivity, security risk, or Code of Conduct violations.

### Domain reviewers

Changes in sensitive areas require an appropriate reviewer:

| Area | Required review |
| --- | --- |
| credentials, auth, sandboxing, updater, browser/MCP permissions | security owner |
| capture, retention, export, deletion, telemetry, provider egress | privacy/security owner |
| license, trademark, bundled models/assets, public privacy terms | legal/provenance owner |
| signing, notarization, release manifests, provenance | release owner |
| keyboard, VoiceOver, contrast, motion, text scaling | accessibility reviewer |

One person may hold multiple roles, but a public-release go/no-go still requires
the independent approvals stated in the
[publication plan](docs/publication/PUBLICATION_PLAN.md).

## Change process

Small fixes use a focused pull request with a regression test. Material changes
to data boundaries, persisted schemas, public APIs, permissions, updater
behavior, automation, or compatibility require:

1. a written problem and user journey;
2. threat, privacy, migration, and rollback analysis;
3. UI loading/empty/error/permission states where relevant;
4. contract and end-to-end tests;
5. documentation and release-note changes;
6. the domain reviews above.

The pull request author must not fabricate review, test evidence, or
attribution. Generated code or assistance does not replace accountable human
review.

## Releases

Releases are built from a protected tag through the documented pipeline.
Automation may prepare a draft; a maintainer verifies checksums, provenance,
signatures, notarization, stapling, updater behavior, notices, and clean-device
installation before publication.

Security, privacy, licensing, history-sanitation, and signing blockers are
release blockers. See [Release verification](docs/RELEASE_VERIFICATION.md) and
the [cutover runbook](docs/publication/CUTOVER_RUNBOOK.md).

## Security and private reports

Do not disclose a suspected vulnerability in a public issue. Follow
[SECURITY.md](SECURITY.md). Maintainers limit access to the report, acknowledge
it, coordinate a fix and release, and publish an advisory when doing so no
longer increases user risk.

## Conflicts and appeals

Reviewers should state concrete evidence and the governing product or
engineering contract. A contributor may request a second maintainer review.
For security, privacy, licensing, or conduct disputes, the relevant domain
owner makes the final repository decision after documenting the rationale
privately or publicly as appropriate.

## Amendments

Governance changes use the same pull-request process. A material reduction in
privacy, security, review, or release requirements must be called out
explicitly and cannot be smuggled into an unrelated change.
