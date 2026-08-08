# Consumer publication implementation status

> Updated: 2026-08-08
> Working repository: `civitass/civitas-desktop`
> Publication state: **public source; no binary release published**
> Verified clean-history checkpoint:
> `civitass/civitas-desktop` at
> `ece9f6912e2bf994325f820ffe673e84e32422e9`
> Source of truth: [PUBLICATION_PLAN.md](PUBLICATION_PLAN.md)

This ledger distinguishes implemented product controls, public-source evidence,
binary-release evidence, and external approvals. The repository owner explicitly
authorized single-review source publication on 2026-08-08 after the clean-root
cutover. Independent security review, two-person review, and counsel approval
were not obtained and are not claimed. Binary releases remain fail-closed on
signing, notarization, exact-commit CI, and installation evidence.

## Publication decision

| Repository         | Decision                                           | Current safeguard                                                                         |
| ------------------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `civitas-desktop`  | Publish the sanitized consumer source                     | Public from the clean 17-commit root; binary downloads remain separately gated            |
| `civitas-cloud`    | Do not publish                                     | Private, archived recovery repository exists                                              |
| `civitas-platform` | Do not publish                                     | Private, archived recovery repository exists                                              |

Private, read-only recovery archives were created before publication edits:

- `civitass/Civitas-desktop-archive`
- `civitass/Civitas-cloud-archive`
- `civitass/Civitas-platform-archive`

Live GitHub metadata was rechecked on 2026-08-08: the consumer repository is
public; the three recovery archives and the unsafe-history legacy repository
remain private and archived, each with `main` as its default branch.

The archives must never inherit the consumer repository’s public visibility.

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
| Assistant handoff    | The managed assistant resolves its authenticated loopback credential from the child environment, never a literal config placeholder; local gateway authentication failures are classified separately from remote provider refusal and give a bounded restart/diagnostics recovery path | Pi configuration regression test, assistant diagnostics, authenticated loopback gateway        |
| Local models         | The UI discloses publisher, exact revision, license, approximate size, cache location, and network behavior before local transcription model activation                                                                                                                                                             | Local model disclosure dialog and catalog tests                                                |
| Model supply chain   | Runtime model sources are immutable-revision pinned and SHA-256 checked; incomplete downloads are atomic; mutable Audiopipe loaders and the unverified `mlx.metallib` build fetch were removed; `CIVITAS_NETWORK_MODE=deny` blocks reviewed remote model fetches                                                    | Verified model registry, Whisper/Silero/speaker/Smart PII downloaders, model publication audit |
| Capture trust        | Screen, accessibility, and audio permissions are explained; clipboard and raw typed-text capture default off; visible pause/private controls and local retention controls remain available. Fresh or incomplete onboarding cannot start the capture backend, engine, or apply a persisted capture intent before the explicit engine consent step | Onboarding trust contract, startup gates, recording/privacy/storage settings, native launch QA |
| Ask and graph        | Search, graph retrieval, source citations, grounding, and local query surfaces remain in the consumer product without an entitlement gate. Knowledge-graph grants, revocation, scope updates, and access audit writes use durable serialized transactions rather than a read-pool cursor; the consumer migration removes dormant non-agent principals and SQLite guards constrain new grants to local AI agents | Ask/graph tests, local engine routes, migration guards, and durable KG access tests             |
| Timeline resilience  | Timeline remains a local, reconnecting view of the active data library. Its persistent renderer cache is committed only after complete writes and is scoped to both the validated data root and a per-library opaque identity, so a wipe, move, custom-directory change, or fresh profile cannot resurrect frame paths from another library | Native data-identity tests, renderer cache tests, packaged publication E2E                     |
| Next Actions         | Restored as a pull-only, evidence-linked suggestion surface with deterministic ranking, calibrated abstention, duplicate suppression, expiry, dismissal, local feedback, quality counters, and explicit safety reasons. Feedback now accepts every supported deterministic candidate source, and suggestions never auto-execute | Engine route, UI, API and migration tests, synthetic evaluation                                |
| MCP                  | Loopback-only transport, token authentication, explicit scopes, request-origin controls, bounded responses, and no LAN mode                                                                                                                                                                                         | MCP server, scope tests, publication audit                                                     |
| Browser bridge       | Replaced cookie extraction and arbitrary remote-code evaluation with a Manifest V3 extension exposing only a bounded active-tab snapshot and one-shot approved HTTPS navigation; removed broad tab/debugger/cookie permissions; moved local WebSocket authentication out of URLs; added complete Apple-quality popup/options assets and truthful store/privacy copy | Rust bridge tests, extension tests/build, manifest audit, browser approval UI, network/privacy docs |
| Telemetry            | Optional web analytics default off; versioned consent migrates historic implicit opt-ins to off; SDK is not initialized before consent; no person profiles, autocapture, page views, performance, replay, surveys, feature flags, persistence, or remote dependency loading; final egress filtering is fail-closed and strips work content; native analytics and automatic crash upload paths are absent; crash records stay local | Telemetry consent tests and publication audit                                                  |
| Tauri/webview        | Reduced window capabilities, separate onboarding/assistant capabilities, hardened CSP and loopback exposure, production-security validation                                                                                                                                                                         | Capability manifests and Tauri security audit                                                  |
| Fixtures and media   | Removed tracked recordings, videos, model weights, named-person fixtures, obsolete screenshots, and LFS pointers; evaluation inputs must be generated synthetic data or an external, reviewed, licensed public corpus. Public-corpus audio and derived WAV files remain outside Git, and artifacts contain metrics only                                                               | Fixture contracts, licensed-corpus attribution, tracked-media and workflow-artifact audits      |
| Release supply chain | Added a pinned license-safe macOS FFmpeg build and a Windows x86-64 NSIS lane; exact digest and byte verification for retained Bun, FFmpeg, OpenBLAS, ONNX Runtime, signing-tool, and test-driver downloads; fail-closed Developer ID/notarization and timestamped Authenticode requirements; isolated Windows install/uninstall verification; immutable commit pins for every third-party GitHub Action; explicit workflow permissions and non-persisted checkout credentials; protected draft-release gates; checksums, SBOM, and provenance attestations | Build helpers, release workflows, repository-wide workflow audit, `docs/RELEASE_VERIFICATION.md` |
| Public project files | Added license, provenance and third-party notices, privacy/security/support policies, code of conduct, contribution guide, structured privacy-safe issue forms and PR checklist, CODEOWNERS, Dependabot for Cargo/Bun/Actions, public-or-opted-in-private CodeQL scanning, and build/BYOK/privacy/network/model/threat documentation                                               | Root, `.github/`, and `docs/` publication set                                                   |
| Design system        | Refined public-facing and high-frequency product surfaces to the original native Mac design language: restrained hierarchy, system typography, consistent native radii, pointer-down feedback, custom ease-out/ease-in-out timing, no blanket property transitions, and explicit reduced-motion/transparency/contrast behavior | `DESIGN.md`, design tokens, component tests, and recursive consumer design audit                |
| Brand and README     | Added a restrained Apple-style README composition with the correct transparent monochrome circular Civitas mark, an optically centered serif/sans Civitas Desktop wordmark, direct macOS and Windows release paths, and reproducible real-app screenshots using an isolated privacy-safe native-app session; rejected small decorative text and generated interface mockups are absent | `README.md`, brand assets, publication-demo E2E journey, cutover privacy review                  |

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

## 2026-08-07 publication delta

- A checksum-verified Gitleaks `8.30.1` scan of every tracked candidate file
  and all 14 retained commits reports zero findings without path exclusions,
  baselines, or allow comments. Secret-detector regression fixtures construct
  their fake values at runtime.
- The rewritten candidate was pushed to a fresh empty private repository.
  Remote inventory resolves only `HEAD` and `refs/heads/main` to
  `ece9f6912`; there are no tags or pull requests. The earlier staging attempt,
  whose Dependabot pull-request refs made it unsuitable for cutover, is private,
  renamed, and archived as
  `civitas-desktop-publication-staging-contaminated-20260807`.
- After the remediated candidate reached `00979543`, the unsafe-history
  repository was renamed `civitas-desktop-private-legacy-20260807` and archived
  privately. The verified clean repository then took the canonical
  `civitass/civitas-desktop` name without changing its private visibility.
- Apple signing/notarization and Tauri updater secrets were transferred as
  encrypted GitHub Actions secrets into the fresh candidate. Only their names
  and update timestamps were inspected. The one-time workflow and migration
  token were removed immediately after its successful run.
- The first clean-staging push passed the complete-history Secret Scan. Its
  quality run then detected newly published advisories in the desktop,
  optional assistant runtime, and MCP lockfiles; all affected transitive
  versions were raised to their patched compatible lines, and the exact Bun
  `1.3.10` four-lockfile audit now reports zero vulnerabilities. No advisory
  exception or baseline was added.
- The same staging run exposed a Windows MSVC `MAX_PATH` failure in the nightly
  integration workflow. The job now creates and verifies a short `C:\t` Cargo
  target junction before compilation, matching the already-hardened release
  lane, and the publication audit prevents that guard from being removed.
- The Windows release lane is implemented but cannot run successfully until
  the repository has all four SSL.com `ESIGNER_*` secret values. The current
  repository secret-name inventory and local operator credential inventory do
  not contain them. An unsigned installer is intentionally not accepted as an
  official artifact.
- The macOS and Windows download URLs intentionally target GitHub Releases.
  They must not be described as available until a verified non-draft release
  actually contains both dual-architecture DMGs and the signed Windows
  installer.
- A single technical reviewer can execute and record every automated and local
  verification in this repository, but that evidence is not truthfully an
  independent second-person, external security, or qualified legal review.
  Those attestations remain “not obtained” unless distinct qualified reviewers
  actually provide them.

## Validation evidence

The complete local matrix was rerun on 2026-07-31 after the Timeline,
assistant, provider, retention, and Next Actions remediations. Publication PR
#48 merged as `4fb41fc`; the `serde_with` security update in PR #59 merged as
`6d4d2fe`. CI must rerun every automated gate against the final immutable
release commit; these local results do not close any independent, legal,
history, signing, or two-person release gate.

| Evidence                                      | Required result            | Candidate result                                                                                                                                                                                                                 |
| --------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Publication boundary audit                    | Pass                       | **Pass (local candidate):** 1,778 candidate files checked                                                                                                                                                                        |
| Consumer design audit                         | Pass                       | **Pass (local candidate):** 342 production UI files, including 11 strict and 2 supporting surfaces                                                                                                                               |
| JavaScript dependency advisory gate           | Zero blocking findings     | **Pass (prior exact audit; lockfiles unchanged):** all 4 tracked Bun lockfiles reproduced with exact Bun `1.3.10`; low-threshold audits returned zero vulnerabilities                                                            |
| Rust dependency advisory/reachability gate    | Zero unreviewed findings   | **Pass (merged private `main`):** both Rust lockfiles passed exact `cargo-audit 0.22.2`; `serde_with` was patched to `3.21.0`; residual `rand` and `glib` alerts were dispositioned with feature/target evidence and explicit reopen conditions |
| Frontend typecheck + full Vitest + Bun tests  | Pass                       | **Pass (local candidate):** TypeScript clean; 963 Vitest tests across 108 files and 171 Bun tests across 17 files passed under exact Bun `1.3.10`; optimized Next.js build generated 17 static pages                              |
| Rust format + locked workspace check/tests    | Pass                       | **Pass (local candidate):** format-clean; the complete locked root workspace and doc tests passed, including the 886/892 database suite (6 contract ignores), 324/324 workflow suite, 205/205 audio suite, and 3/3 redaction-worker integration suite |
| Tauri locked check + bindings/security audit  | Pass                       | **Pass (local candidate):** normal and E2E app graphs compiled; generated TypeScript bindings exactly match the Rust command registry; 18-file production-security audit passed                                                   |
| MCP build/tests and package boundary          | Pass                       | **Pass (local worktree):** 51 tests and TypeScript build passed; npm allowlist produced 15 files / 47,496 bytes and the production-only MCPB produced 2,143 files / 3,178,564 bytes with a verified checksum                         |
| Browser extension tests/build/package audit   | Pass                       | **Pass (local worktree):** 2 configuration-boundary tests, production build, and publication manifest audit passed                                                                                                               |
| Fresh-profile native privacy launch           | Pass                       | **Pass (local candidate):** pre-consent QA returned authenticated `200`, unauthenticated `401`, and hostile-Host `403` with no engine/capture start; post-consent no-recording QA reached ready on a fresh encrypted profile and persisted zero frames, audio transcriptions, or UI events |
| Packaged publication product journey          | Pass                       | **Pass (local candidate):** 3/3 real Tauri UI journeys passed from a fresh synthetic profile: Timeline rendered its local evidence image, Next Actions rendered a grounded commitment, and Settings rendered the supported AI boundaries |
| Live Amazon Bedrock diagnostic                | Pass                       | **Pass (local candidate):** the authenticated Civitas loopback gateway invoked configured inference profile `us.anthropic.claude-sonnet-4-6` with the fixed non-sensitive diagnostic and returned `OK`; no credential or prompt body was persisted in audit metadata |
| Public documentation and generated API        | Pass                       | **Pass (local candidate):** 22-document local-link validation passed; generated bindings and the committed 155-path OpenAPI surface are current                                                                                   |
| Tip-of-tree secret scan                       | Zero findings              | **Pass (local candidate):** digest-pinned TruffleHog `3.96.0` scanned the exact `origin/main..47a3247` Git range offline with zero verified or unverified findings. The amended publication commit is rescanned before push and must run again in CI                                                |
| Exact-candidate GitHub Actions                 | All required jobs pass     | **In progress:** private-repository runs were rejected before step one by the Actions budget; public-source cutover removes the private-minute constraint, and every required workflow is being rerun on the public clean history       |
| Full retained-history secret review           | Zero findings              | **Pass:** checksum-verified Gitleaks `8.30.1` scanned all 17 retained commits with zero findings; GitHub exposes only the allowlisted clean root and `main`; unsafe historic objects remain in private archived repositories only          |
| Signed/notarized dual-architecture DMGs       | Pass                       | **Blocked: B5:** the installed matching Developer ID identity passed a disposable hardened-runtime/timestamp signing probe, but Apple reports an outstanding developer agreement; updater/notarization repository secrets and the dual-architecture workflow remain unverified |
| Clean-machine install/upgrade/rollback matrix | Pass                       | **Blocked: release artifacts and independent devices required**                                                                                                                                                                  |
| Independent security review                   | Disclosure                 | **Not obtained and not claimed:** the owner accepted single-review source-publication risk                                                                                                                                       |
| Legal/privacy/license/trademark review        | Disclosure                 | **Not obtained and not claimed:** technical provenance and license checks are not legal advice                                                                                                                                   |
| Two-person file allowlist and go/no-go        | Disclosure                 | **Not obtained and not claimed:** the owner explicitly authorized publication without a second reviewer                                                                                                                          |

## Publication and release disposition

### B1 — historic secrets and personal data

Prior audit evidence found secret-pattern candidates and personal paths in the
former private history. That history was not rewritten in place or exposed.
Instead, publication used an allowlisted clean repository. Before cutover:

1. scan all reachable history, tags, GitHub Actions logs, old artifacts, and
   releases with a current scanner;
2. classify every finding without copying secret values into tickets or logs;
3. rotate/revoke every credential that ever reached a shared service;
4. obtain service-side evidence of revocation;
5. replace or remove every real-person fixture and derivative;
6. record that the owner accepted single-review source-publication risk because
   no second reviewer would be provided.

### B2 — clean public root

The former private Git repository and its historic remote refs are not approved
for publication. The 2026-08-07 live remote inventory initially found 54 branch
heads, 86 hidden pull-request refs, and no tags. All 53 non-`main` branch heads
were removed, but deleting visible branches cannot prove that pull refs,
artifacts, cached objects, releases, or PR attachments are gone. That repository
is now private and archived as
`civitas-desktop-private-legacy-20260807`; it must never be made public.

The required cutover therefore used an allowlisted snapshot pushed as the sole
history of a **new empty repository**, while the former repository was retained
privately as legacy evidence. The fresh private publication repository was
created as `civitass/civitas-desktop-publication-staging` on
2026-08-07. Its initial verified clean-history checkpoint is
`ece9f6912e2bf994325f820ffe673e84e32422e9`. All 14 retained commits passed
checksum-verified Gitleaks `8.30.1` with zero findings and `git fsck --strict`.
Live remote inventory then listed only `HEAD` and `refs/heads/main` at that
object, with zero tags and zero pull requests.

An earlier staging attempt generated Dependabot pull-request refs before its
single-ref policy landed. It was therefore rejected for publication, renamed
`civitas-desktop-publication-staging-contaminated-20260807`, kept private, and
archived. It is not a cutover source. The fresh candidate has Dependabot version
pull requests disabled until after public cutover, while vulnerability alerts
remain a publication control.

Apple signing/notarization plus the rotated Tauri updater private key and
password are installed in the fresh repository as encrypted Actions secrets.
The one-time transfer completed in workflow run `31234392267`; no secret value
was printed or read back, and the workflow and temporary migration token were
removed immediately afterward. After the remediated source reached `00979543`,
the private clean repository took the canonical `civitass/civitas-desktop`
name, and the unsafe-history repository was renamed and archived. On 2026-08-08
the canonical clean repository became public after signed-out `git ls-remote`
again listed only `HEAD` and `refs/heads/main`, with zero tags and zero pull
requests. GitHub secret scanning with push protection, Dependabot vulnerability
alerts and automated fixes, private vulnerability reporting, issues, and
discussions were enabled immediately after cutover.

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

### B5 — official desktop artifacts

The matching Developer ID certificate is currently valid and its private key
passed a disposable hardened-runtime/timestamp signing probe. Apple nevertheless
blocks notarization until an outstanding developer agreement is accepted. The
release workflow still needs a successful credential preflight, verification of
the repository-held updater signing key, two architecture builds, clean-machine
Gatekeeper/signature/notarization checks, upgrade/migration/rollback tests, and
a second maintainer’s approval. Source builds are not substitutes for official
DMGs.

The protected Windows job now builds an x86-64 NSIS installer, requires the
release signing mode to remain fail-closed, verifies timestamped Authenticode
on the built and installed application, scans the bundle boundary, and performs
an isolated install/uninstall cycle. It remains blocked because the required
SSL.com `ESIGNER_USERNAME`, `ESIGNER_PASSWORD`, `ESIGNER_TOTP_SECRET`, and
`ESIGNER_CREDENTIAL_ID` secrets are not configured. A source build, ad-hoc
signature, or SmartScreen bypass is not a release substitute.

### B6 — GitHub public-project controls

The public repository has secret scanning with push protection, Dependabot
alerts and automated security fixes, private vulnerability reporting,
least-privilege Actions, issue/PR templates, support ownership, and release
permissions. Protected-default-branch rules and exact required checks are set
after the first successful public exact-commit workflow set establishes their
check names. Archive repositories were reverified private.

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

The `consumer-release` environment exists without reviewer protection because
the owner supplied no independent reviewer. The `civitas-mcp` npm name is not
yet registered, `keys.md` contains
no npm credential, the local npm CLI is unauthenticated, and the repository
has no `NPM_TOKEN` secret. Its one-time, 2FA-backed bootstrap and subsequent
migration to workflow-bound, stage-only trusted publishing remain
owner-controlled release gates. The protected workflow leaves both the staged
npm package and GitHub Release draft awaiting separate human approvals. There
are 232 historical Actions artifacts (207 active, approximately 6.59 GiB) that
remain confined to the archived private legacy repository and were not copied
into the public clean root.

The earlier Actions-budget rejection was historical and recent hosted jobs now
start normally. Every required workflow must still rerun successfully against
the final clean-root commit; success on an earlier private-history object does
not transfer to the rewritten object ID.

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

The sanitized consumer source is **GO and public**. The former history remains
private and archived. Desktop binaries remain **NO-GO** until the exact public
commit passes required CI and the artifact itself passes the platform-specific
signing, notarization, updater, checksum, provenance, and clean-install gates.
No release may claim independent security, legal, notarization, or clean-machine
approval without the corresponding evidence.

Follow [CUTOVER_RUNBOOK.md](CUTOVER_RUNBOOK.md) for binary release and rollback
operations; its multi-person procedure remains the recommended policy even
though the owner explicitly accepted single-review source publication.
