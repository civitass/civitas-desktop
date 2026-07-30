# Consumer publication implementation status

> Updated: 2026-07-29
> Working repository: `civitass/civitas-desktop`
> Publication state: **private; not approved for public visibility**
> Private `main`: publication PR #48 and dependency-security PR #59 merged
> Source of truth: [PUBLICATION_PLAN.md](PUBLICATION_PLAN.md)

This ledger distinguishes implemented product controls from release evidence
and external approvals. “Implemented” means the control exists in the
publication candidate. It does not mean the repository or a release is safe to
publish until every blocking gate below is independently closed.

## Publication decision

| Repository         | Decision                                           | Current safeguard                                                                         |
| ------------------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `civitas-desktop`  | Sanitized consumer implementation merged to private `main` | Keep private until the clean-root, security, legal, release, and two-reviewer gates close |
| `civitas-cloud`    | Do not publish                                     | Private, archived recovery repository exists                                              |
| `civitas-platform` | Do not publish                                     | Private, archived recovery repository exists                                              |

Private, read-only recovery archives were created before publication edits:

- `civitass/Civitas-desktop-archive`
- `civitass/Civitas-cloud-archive`
- `civitass/Civitas-platform-archive`

Live GitHub metadata was rechecked on 2026-07-29: the working repository and
all three archives are private, every archive is read-only/archived, and each
uses `main` as its default branch.

Archive visibility, archived state, default branch, and copied refs must be
reverified immediately before cutover. The archives must never inherit the
consumer repository’s public visibility.

## Implemented product and repository controls

| Plan area            | Implemented state                                                                                                                                                                                                                                                                                                   | Principal evidence                                                                             |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Consumer boundary    | Removed the checked-in Civitas control plane, hosted AI gateway, enterprise release configuration, team/fleet/sync/operator/account gates, owned-browser automation, internal plans, private reports, and enterprise-only generated skills from the candidate tree                                                  | Publication audit forbids the retired roots and hosted runtime endpoints                       |
| Local-first runtime  | Capture, SQLite/FTS, local knowledge graph, query, retention, export/deletion, MCP, and Next Actions run on the user’s computer; no Railway, Supabase account, Civitas credits, or `api.civitas.team` dependency remains in the default path                                                                        | `docs/NETWORK_BOUNDARY.md`, `docs/PRIVACY_AND_DATA_BOUNDARY.md`, runtime endpoint audit        |
| BYOK                 | Added provider profiles and direct adapters for OpenAI, Anthropic Claude API, OpenRouter, Amazon Bedrock, local loopback, and an advanced compatible endpoint                                                                                                                                                       | `docs/BYOK.md`, provider settings UI, Rust inference gateway                                   |
| Credential safety    | Provider secrets use OS credential storage; no plaintext fallback; vault failure offers an explicit process-memory-only session choice; credential values are not returned to the webview; delete/replace/test controls exist; session values are zeroized on drop; source and ad-hoc optimized builds use an isolated Keychain service namespace and cannot read release credentials; only protected official app/CLI workflows opt into the release vault identity | Provider profile commands, `civitas-secrets`, credential boundary tests and audit              |
| Pre-send clarity     | Remote setup and diagnostics disclose destination, model, billing owner, content boundary, and the fixed non-sensitive diagnostic prompt before sending                                                                                                                                                             | Provider settings UI and tests                                                                 |
| AI choice            | Onboarding presents local-only and direct-provider boundaries without requiring a Civitas account                                                                                                                                                                                                                   | AI boundary onboarding and provider setup                                                      |
| Assistant runtime    | The optional Pi assistant runtime is never fetched or bootstrapped during launch. Installation is an explicit Settings action using a reviewed frozen lockfile, bundled Bun, production-only dependencies, disabled lifecycle scripts, and managed-runtime integrity checks; removal is symlink-safe and limited to the managed runtime directory | Runtime lock assets, Tauri commands, runtime tests, and publication audit                       |
| Local models         | The UI discloses publisher, exact revision, license, approximate size, cache location, and network behavior before local transcription model activation                                                                                                                                                             | Local model disclosure dialog and catalog tests                                                |
| Model supply chain   | Runtime model sources are immutable-revision pinned and SHA-256 checked; incomplete downloads are atomic; mutable Audiopipe loaders and the unverified `mlx.metallib` build fetch were removed; `CIVITAS_NETWORK_MODE=deny` blocks reviewed remote model fetches                                                    | Verified model registry, Whisper/Silero/speaker/Smart PII downloaders, model publication audit |
| Capture trust        | Screen, accessibility, and audio permissions are explained; clipboard and raw typed-text capture default off; visible pause/private controls and local retention controls remain available. Fresh or incomplete onboarding cannot start the capture backend, engine, or apply a persisted capture intent before the explicit engine consent step | Onboarding trust contract, startup gates, recording/privacy/storage settings, native launch QA |
| Ask and graph        | Search, graph retrieval, source citations, grounding, and local query surfaces remain in the consumer product without an entitlement gate. Knowledge-graph grants, revocation, scope updates, and access audit writes use durable serialized transactions rather than a read-pool cursor; the consumer migration removes dormant non-agent principals and SQLite guards constrain new grants to local AI agents | Ask/graph tests, local engine routes, migration guards, and durable KG access tests             |
| Next Actions         | Restored as a pull-only, evidence-linked suggestion surface with deterministic ranking, calibrated abstention, duplicate suppression, expiry, dismissal, local feedback, and explicit safety reasons; it never auto-executes                                                                                        | Engine route, UI, API tests, synthetic evaluation                                              |
| MCP                  | Loopback-only transport, token authentication, explicit scopes, request-origin controls, bounded responses, and no LAN mode                                                                                                                                                                                         | MCP server, scope tests, publication audit                                                     |
| Browser bridge       | Replaced cookie extraction and arbitrary remote-code evaluation with a Manifest V3 extension exposing only a bounded active-tab snapshot and one-shot approved HTTPS navigation; removed broad tab/debugger/cookie permissions; moved local WebSocket authentication out of URLs; added complete Apple-quality popup/options assets and truthful store/privacy copy | Rust bridge tests, extension tests/build, manifest audit, browser approval UI, network/privacy docs |
| Telemetry            | Optional web analytics default off; versioned consent migrates historic implicit opt-ins to off; SDK is not initialized before consent; no person profiles, autocapture, page views, performance, replay, surveys, feature flags, persistence, or remote dependency loading; final egress filtering is fail-closed and strips work content; native analytics and automatic crash upload paths are absent; crash records stay local | Telemetry consent tests and publication audit                                                  |
| Tauri/webview        | Reduced window capabilities, separate onboarding/assistant capabilities, hardened CSP and loopback exposure, production-security validation                                                                                                                                                                         | Capability manifests and Tauri security audit                                                  |
| Fixtures and media   | Removed tracked recordings, videos, model weights, named-person fixtures, obsolete screenshots, and LFS pointers; evaluation inputs must be generated synthetic data or an external, reviewed, licensed public corpus. Public-corpus audio and derived WAV files remain outside Git, and artifacts contain metrics only                                                               | Fixture contracts, licensed-corpus attribution, tracked-media and workflow-artifact audits      |
| Release supply chain | Added a pinned license-safe macOS FFmpeg build; exact digest and byte verification for retained Bun, FFmpeg, OpenBLAS, ONNX Runtime, signing-tool, and test-driver downloads; no build-time tool bootstrap; immutable commit pins for every third-party GitHub Action; explicit workflow permissions and non-persisted checkout credentials; protected draft-release gates; checksums, SBOM, and provenance attestations | Build helpers, release workflows, repository-wide workflow audit, `docs/RELEASE_VERIFICATION.md` |
| Public project files | Added license, provenance and third-party notices, privacy/security/support policies, code of conduct, contribution guide, structured privacy-safe issue forms and PR checklist, CODEOWNERS, Dependabot for Cargo/Bun/Actions, public-or-opted-in-private CodeQL scanning, and build/BYOK/privacy/network/model/threat documentation                                               | Root, `.github/`, and `docs/` publication set                                                   |
| Design system        | Refined public-facing and high-frequency product surfaces to the original native Mac design language: restrained hierarchy, system typography, consistent native radii, pointer-down feedback, custom ease-out/ease-in-out timing, no blanket property transitions, and explicit reduced-motion/transparency/contrast behavior | `DESIGN.md`, design tokens, component tests, and recursive consumer design audit                |
| Brand and README     | Added a restrained Apple-style README composition with the correct circular Civitas mark and custom Civitas Desktop wordmark at the approved larger scale; rejected small decorative text is absent                                                                                                                 | `README.md`, `docs/assets/civitas-desktop-wordmark.svg`                                        |

## Automated release invariants

`scripts/audit-publication.mjs` fails closed when the candidate contains:

- a private/enterprise/control-plane root or credential filename;
- a Railway or private Civitas API endpoint in runtime source;
- a tracked audio/video/model payload or any Git LFS pointer;
- a mutable or unverified model loader;
- the retired MLX metallib fetch or bundle reference;
- incomplete BYOK credential controls;
- a release/debug Keychain namespace collision, automatic assistant-runtime
  bootstrap, unmanaged assistant launcher, or unsafe managed-cache deletion;
- capture startup or engine health polling before onboarding reaches its
  explicit engine consent step;
- a non-agent knowledge-graph grant principal, or a non-transactional grant or
  access-audit mutation;
- a telemetry identity/content bypass;
- a non-loopback MCP boundary;
- an unpinned GitHub Action, persisted checkout credential, implicit tool
  installer, mutable/unverified native download, or missing release-signing
  control;
- an automatic unverified real-voice corpus download or audio-bearing
  evaluation artifact;
- missing public safety, legal, build, model, privacy, or cutover documents.

`scripts/audit-consumer-design.mjs` separately fails on consumer interaction
regressions such as blanket `transition-all`, scale-from-zero entrances,
unsupported timing/easing, or missing reduced-motion handling on strict
surfaces.

This is a tip-of-tree control. It does not scan deleted history, GitHub logs,
old releases, service-side secrets, or legal rights.

## Validation evidence

The complete local matrix passed on 2026-07-28 and the final Keychain and
dependency-security deltas were revalidated on 2026-07-29. Publication PR #48
merged as `4fb41fc`; the `serde_with` security update in PR #59 merged as
`6d4d2fe`. CI must rerun every automated gate against the final immutable
release commit; these local results do not close any independent, legal,
history, signing, or two-person release gate.

| Evidence                                      | Required result            | Candidate result                                                                                                                                                                                                                 |
| --------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Publication boundary audit                    | Pass                       | **Pass (merged private `main`):** 1,656 candidate files checked                                                                                                                                                                  |
| Consumer design audit                         | Pass                       | **Pass (merged private `main`):** 319 production UI files, including 11 strict and 2 supporting surfaces                                                                                                                         |
| JavaScript dependency advisory gate           | Zero blocking findings     | **Pass (local worktree):** all 4 tracked Bun lockfiles reproduced with exact Bun `1.3.10`; low-threshold audits returned zero vulnerabilities                                                                                     |
| Rust dependency advisory/reachability gate    | Zero unreviewed findings   | **Pass (merged private `main`):** both Rust lockfiles passed exact `cargo-audit 0.22.2`; `serde_with` was patched to `3.21.0`; residual `rand` and `glib` alerts were dispositioned with feature/target evidence and explicit reopen conditions |
| Frontend typecheck + full Vitest + Bun tests  | Pass                       | **Pass (local candidate):** TypeScript clean; 794 Vitest and 166 Bun tests passed; optimized Next.js build generated 17 static pages                                                                                              |
| Rust format + locked workspace check/tests    | Pass                       | **Pass (local worktree):** both Rust workspaces format-clean; full locked root workspace and doc tests passed, including 157 database and 782 engine unit tests                                                                    |
| Tauri locked check + bindings/security audit  | Pass                       | **Pass (merged private `main`):** normal and protected official-build graphs compiled; 193 tests passed, 4 process-backed tests ignored by contract; generated bindings current; 5-file production-security audit passed             |
| MCP build/tests and package boundary          | Pass                       | **Pass (local worktree):** 51 tests and TypeScript build passed; npm allowlist produced 15 files / 47,496 bytes and the production-only MCPB produced 2,143 files / 3,178,564 bytes with a verified checksum                         |
| Browser extension tests/build/package audit   | Pass                       | **Pass (local worktree):** 2 configuration-boundary tests, production build, and publication manifest audit passed                                                                                                               |
| Fresh-profile native privacy launch           | Pass                       | **Pass (local candidate):** pre-consent QA returned authenticated `200`, unauthenticated `401`, and hostile-Host `403` with no engine/capture start; post-consent no-recording QA reached ready on a fresh encrypted profile and persisted zero frames, audio transcriptions, or UI events |
| Public documentation and generated API        | Pass                       | **Pass (local worktree):** 22-document local-link validation passed; generated bindings and the committed 106-path OpenAPI surface are current                                                                                    |
| Tip-of-tree secret scan                       | Zero findings              | **Pass (local candidate):** pinned TruffleHog scanned the final #48 and #59 ranges offline with zero verified or unverified findings                                                                                              |
| Exact-candidate GitHub Actions                 | All required jobs pass     | **Blocked: B6 external control:** #48, #59, and post-merge jobs were rejected before their first step because an Actions budget prevents further use; each inspected job had zero steps and the budget-rejection annotation          |
| Full history/service-side secret review       | Zero unclassified findings | **Blocked: B1:** secondary native history detectors covered 319 reachable commits/51 refs and confirmed historic detector-shaped material and absolute user paths; checksum-verified scanning, 207 active Actions artifacts, rotations, PII classification, service evidence, and two reviewers remain required |
| Signed/notarized dual-architecture DMGs       | Pass                       | **Blocked: B5:** the installed matching Developer ID identity passed a disposable hardened-runtime/timestamp signing probe, but Apple reports an outstanding developer agreement; updater/notarization repository secrets and the dual-architecture workflow remain unverified |
| Clean-machine install/upgrade/rollback matrix | Pass                       | **Blocked: release artifacts and independent devices required**                                                                                                                                                                  |
| Independent security review                   | Approved                   | **Blocked: external reviewer required**                                                                                                                                                                                          |
| Legal/privacy/license/trademark review        | Approved                   | **Blocked: qualified reviewer required**                                                                                                                                                                                         |
| Two-person file allowlist and go/no-go        | Approved                   | **Blocked: two independent owners required**                                                                                                                                                                                     |

## Publication blockers that must not be marked complete in code review

### B1 — historic secrets and personal data

Prior audit evidence found unclassified secret-pattern candidates and a
historic commit described as containing a live reasoning-memory graph from a
real laptop. Deleted tip files remain recoverable from Git history. Before any
public visibility change:

1. scan all reachable history, tags, GitHub Actions logs, old artifacts, and
   releases with a current scanner;
2. classify every finding without copying secret values into tickets or logs;
3. rotate/revoke every credential that ever reached a shared service;
4. obtain service-side evidence of revocation;
5. replace or remove every real-person fixture and derivative;
6. have two reviewers approve the final publication allowlist.

### B2 — clean public root

The existing private Git repository and its historic remote refs are not
approved for publication. A live remote inventory found 51 reachable refs,
including feature/session/audit branches and pull-request history. Replacing
only `main` or deleting visible branches would not prove that pull refs,
artifacts, cached objects, releases, or PR attachments are gone.

The required cutover is therefore a two-person allowlisted snapshot pushed as
the sole root of a **new empty repository**, while the current repository is
renamed and retained privately as an archive. Before visibility changes,
signed-out `git ls-remote` must list only the approved default branch and
explicitly allowlisted release tags. GitHub-Support-assisted purge/recreate is
acceptable only with equivalent evidence. No automation in this branch
renames, deletes, force-pushes, creates, or changes visibility for a repository;
each remains a consequential owner-approved action.

### B3 — third-party and legal approval

Counsel or another qualified owner must approve fork attribution, the source
license policy, model licenses (including CC BY, CC BY-NC, and model-specific
terms), third-party marks/icons, privacy wording, encryption/export
obligations, and distribution territories. An SBOM must be reviewed from the
exact release commit.

### B4 — independent security and privacy verification

An independent reviewer must test loopback authentication, MCP scopes, Tauri
capabilities/CSP, capture pause/exclusions, local deletion/retention, credential
vault failure, prompt-injection boundaries, provider egress, update
verification, and network-deny behavior. Packet capture is required for any
strong zero-egress claim.

### B5 — official macOS artifacts

The matching Developer ID certificate is currently valid and its private key
passed a disposable hardened-runtime/timestamp signing probe. Apple nevertheless
blocks notarization until an outstanding developer agreement is accepted. The
release workflow still needs a successful credential preflight, verification of
the repository-held updater signing key, two architecture builds, clean-machine
Gatekeeper/signature/notarization checks, upgrade/migration/rollback tests, and
a second maintainer’s approval. Source builds are not substitutes for official
DMGs.

### B6 — GitHub public-project controls

Before visibility changes, configure protected default branch rules, required
checks/reviews, signed tags or equivalent release policy, private
vulnerability reporting, Dependabot/security scanning, least-privilege Actions,
issue/PR templates, support ownership, and release permissions. Verify archive
repositories remain private.

On 2026-07-28, repository administration enabled Dependabot vulnerability
alerts and automated security fixes. The old default branch initially reported
77 open alerts. After the sanitized candidate reached private `main`, GitHub
reduced that set to three current Rust alerts. PR #59 patched the reachable
`serde_with` advisory to `3.21.0`. The remaining alerts were individually
classified on 2026-07-29: `rand 0.7.3` is build-only and its resolved graph
does not enable the advisory-required `log` feature; `glib 0.18.5` is absent
from the Apple Silicon graph and no Linux artifact is authorized. GitHub now
reports zero open alerts. The recorded dispositions require reopening if the
dependency kind/features change, a Linux artifact is proposed, or the macOS
graph gains either package.

Actions is now restricted to GitHub-owned actions plus the reviewed
third-party action allowlist, and repository policy requires full commit-SHA
pinning. The committed workflows have zero uncovered or unpinned remote
actions.

The current private-repository plan does not expose branch
protection/rulesets, code scanning, or secret scanning. A protected
`consumer-release` environment and named independent reviewer are also still
required. The `civitas-mcp` npm name is not yet registered, `keys.md` contains
no npm credential, the local npm CLI is unauthenticated, and the repository
has no `NPM_TOKEN` secret. Its one-time, 2FA-backed bootstrap and subsequent
migration to workflow-bound, stage-only trusted publishing remain
owner-controlled release gates. The protected workflow leaves both the staged
npm package and GitHub Release draft awaiting separate human approvals. There
are 232 historical Actions artifacts (207 active, approximately 6.59 GiB) that
must be reviewed and dispositioned before visibility changes.

PRs #48 and #59, plus the resulting `main` pushes, have no usable server-side
validation yet. On 2026-07-29, GitHub rejected every inspected hosted-runner
job before step one with the check-run
annotation `The job was not started because an Actions budget is preventing
further use.` No runner was assigned and no workflow log exists. An
organization owner must restore or raise the Actions budget, then rerun all
required checks against the exact release commit. Local passes cannot
substitute for that rerun.

### B7 — browser-extension store review

The source package and a protected workflow can produce a checksummed review
artifact, but Chrome Web Store submission is an external publication action.
Before advertising an install link, a human owner must:

1. reproduce and inspect the exact extension ZIP and SHA-256 checksum;
2. confirm the dashboard privacy/data-use declarations match
   `packages/browser-extension/PRIVACY.md` and `store-listing.md`;
3. test active-tab expiry, snapshot redaction, navigation Allow once/deny, and
   removal/revocation with synthetic pages;
4. submit the candidate for independent Chrome review with deferred
   publishing;
5. publish only after review passes and the repository/desktop release gates
   are approved.

No workflow in this repository uploads or publishes a store listing.

## Go/no-go rule

The repository remains **NO-GO** while any B1–B7 item is open. Passing local
tests or pushing this preparation branch is not permission to:

- expose the existing history;
- create or force-push a sanitized public root;
- change repository visibility;
- publish a GitHub Release or DMG;
- claim independent security, legal, notarization, or clean-machine approval.

Follow [CUTOVER_RUNBOOK.md](CUTOVER_RUNBOOK.md) for the ordered, two-person
publication procedure.
