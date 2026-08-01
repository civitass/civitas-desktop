# Consumer publication cutover runbook

> Applies to `civitass/civitas-desktop` only.
> `civitas-cloud`, `civitas-platform`, and all three archive repositories must
> remain private.
> No visibility, history, tag, or release mutation may occur without explicit
> repository-owner approval.

This runbook turns the implementation candidate into an auditable public
release. Execute it in order. Stop on uncertainty; do not convert a failed gate
into a documentation exception.

## Roles and separation of duties

Assign named people before the freeze:

| Role                      | Required responsibility                                                                         |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| Release lead              | Owns the candidate commit, evidence index, tag, and cutover sequence                            |
| Security/privacy reviewer | Independently checks history, runtime boundaries, capture safety, secrets, and network behavior |
| License/privacy approver  | Approves source/model/media/mark rights, notices, privacy terms, and distribution obligations   |
| macOS verifier            | Verifies signatures, notarization, architectures, clean installs, upgrades, and rollback        |
| Repository owner          | Explicitly approves the sanitized root, visibility change, and release publication              |

At least two independent people must approve the final file allowlist, root
commit, and go/no-go record. One person may hold multiple operational roles,
but may not provide both required independent approvals.

## Evidence directory

Create a private access-controlled evidence location outside the repository.
Record:

- candidate and archive object IDs;
- tool versions and command lines;
- redacted scan summaries;
- finding IDs and disposition;
- service-side rotation/revocation confirmations;
- SBOM and license decisions;
- CI run URLs and immutable artifact IDs;
- artifact hashes, signatures, notarization output, and provenance;
- clean-machine OS/build matrix;
- approver names, timestamps, and final decision.

Do not store raw credentials, personal capture content, unredacted scanner
output, signing secrets, `keys.md`, provider responses, or user databases in
the repository or ordinary CI logs.

## Gate 0 — freeze and recovery verification

1. Announce a publication freeze for all three source repositories.
2. Confirm the candidate repository is still private.
3. Confirm each archive is private and GitHub-archived:
   - `civitass/Civitas-desktop-archive`
   - `civitass/Civitas-cloud-archive`
   - `civitass/Civitas-platform-archive`
4. Compare the documented source refs and archive refs by exact Git object ID.
5. Confirm no automation, mirror, fork, package registry, release, Pages site,
   or artifact store has exposed a private archive.
6. Back up GitHub configuration metadata, branch rules, environments, Actions
   secrets names, release metadata, and issue/security settings without
   exporting secret values.

**Stop condition:** any archive is incomplete, public, mutable, or
unrecoverable.

## Gate 1 — history, secret, and personal-data investigation

Use a current checksum-verified secret scanner in redacted mode. Scan:

- all reachable commits, branches, and tags;
- the proposed sanitized tree;
- GitHub Actions logs and uploaded artifacts;
- old releases and updater manifests;
- issue/PR attachments and repository wikis;
- package/container registries and public mirrors;
- Git LFS object inventory, even when the current tree has no pointer.

For each finding, record only a stable finding ID, repository/path/commit,
secret class, owner, disposition, and verification date. Never paste the
matched value.

Every credential that reached Git history or a shared artifact is considered
compromised. Rotate or revoke it at the issuing service even when expired,
test-only, or apparently unreachable. Use the local untracked `keys.md` only
as an operator inventory when needed; never print, stage, attach, or commit it.
Obtain service-side evidence that the old value no longer works.

For personal data, review source and derivatives: screenshots, OCR, audio,
transcripts, embeddings, graph exports, HTML visualizations, fixtures, test
snapshots, logs, filenames, metadata, and model/evaluation artifacts. Replace
with generated fixtures carrying an explicit synthetic marker and documented
license.

**Required output:** zero unclassified findings, complete rotations, and two
independent approvals of the publication allowlist.

**Stop condition:** a value cannot be classified or revoked, a real-person
derivative remains, or an LFS object lacks provenance.

## Gate 2 — sanitized-root approval

The existing private repository is not a publication container: every remote
branch, tag, pull-request ref, Actions artifact, release object, and cached Git
object can become discoverable when visibility changes. Prepare a sanitized
snapshot from the reviewed candidate tree in an isolated temporary clone and
publish it into a **new, empty, private staging repository**:

1. obtain explicit owner approval for a new public root;
2. copy only files on the two-person allowlist;
3. exclude Git metadata, ignored files, local databases/caches, build output,
   credentials, scanner reports, signing material, and private archives;
4. preserve upstream/fork provenance in `LICENSE.md`, `NOTICE.md`, and commit
   metadata without copying the private history;
5. run the publication audit and secret scan against the exact snapshot;
6. have both reviewers compare the root tree hash to the approved allowlist;
7. sign and record the approved root commit ID;
8. push the single approved root only to the new private staging repository;
9. run `git ls-remote` against staging and require that it lists only the
   approved default branch and explicitly allowlisted release tags;
10. inspect repository PRs, releases, Actions artifacts, caches, Pages,
    packages, forks, and hidden/pull refs as separate publication surfaces.

Do not use a branch inside the existing repository as staging: deleting visible
branches later does not remove pull-request refs or guarantee that historic
objects are purged. Do not delete, rewrite, force-push, or make public the
private source repository. If the public project must retain the
`civitass/civitas-desktop` name, the owner must first rename the private source
repository to a private archival name, verify the archive and redirects remain
private, then create the new empty repository under the public name. A
GitHub-Support-assisted purge/recreate is an alternative only with recorded
evidence that every ref and artifact was removed.

**Stop condition:** the snapshot contains an unapproved file, differs from the
tested tree, staging exposes any unexpected ref/object/artifact, the target is
not a new empty repository, or either reviewer rejects it.

## Gate 3 — deterministic validation

From a clean clone of the exact candidate/root commit, with locked
dependencies and no developer caches:

```bash
node scripts/audit-publication.mjs
node scripts/audit-js-security.mjs
node scripts/audit-rust-security.mjs
node scripts/validate-tauri-production-security.mjs
cargo fmt --all -- --check
cargo check --workspace --locked
cd apps/civitas-app-tauri
bun install --frozen-lockfile
bun run typecheck
bun run test
bun run build
bun run bindings:check
cargo test --manifest-path src-tauri/Cargo.toml --locked
cd ../../packages/civitas-mcp
bun install --frozen-lockfile
bun audit --audit-level=low
bun run test
bun run build
cd ../browser-extension
bun install --frozen-lockfile
bun audit --audit-level=low
bun run check
```

Run the repository’s full frontend, Rust, MCP, generated-binding, synthetic
and reviewed licensed-public-corpus evaluation, and platform test matrices documented in `TESTING.md`,
`CONTRIBUTING.md`, and `docs/BUILDING.md`. Build once with
`CIVITAS_NETWORK_MODE=deny` and pre-staged verified models. Treat skipped or
flaky release-blocking tests as failures until they have an owner-approved
disposition.

Record exact toolchain versions, commit ID, lockfile hashes, test totals,
duration, and CI URLs.

**Stop condition:** any required check fails, generated output is dirty,
dependencies resolve outside lockfiles, or the clean clone differs afterward.

## Gate 4 — security and privacy verification

An independent reviewer must verify with synthetic content:

- screen/accessibility/audio permissions are independently understandable;
- pause/private mode, lock-screen behavior, exclusions, and retention work
  across restart;
- clipboard and raw typed-text capture remain off by default;
- local APIs and MCP bind only to loopback and reject missing, wrong, expired,
  origin-invalid, or out-of-scope requests;
- Tauri capabilities and CSP do not expose shell, broad filesystem, secret,
  window, or network authority to untrusted views;
- provider credentials never enter settings JSON, logs, exports, crash
  payloads, Tauri responses, or webview persistence;
- vault-unavailable behavior is fail-closed except for the clearly chosen
  process-memory-only session;
- remote inference transmits only the disclosed request to the selected host;
- local-only mode, telemetry off, updates off, integrations off, and
  `CIVITAS_NETWORK_MODE=deny` match packet-capture evidence;
- prompt injection cannot trigger silent external/destructive actions;
- browser pairing requires a matching-code approval; page reads require an
  active-tab invocation; snapshots omit form values and secret URL data; the
  protocol has no arbitrary code/cookie/click/submit operation; and exact HTTPS
  navigation remains blocked until a fresh **Allow once** decision;
- Next Actions cites local evidence, abstains when weak, expires stale items,
  and never executes;
- export, deletion, retention, derived-graph cleanup, and uninstall behavior
  match documentation;
- update manifests, signatures, channels, redirects, and tampered artifacts
  fail closed.

Record residual risks and owner decisions. Do not claim “zero egress” from code
inspection alone; use an OS firewall and packet capture.

**Stop condition:** any unauthorized capture, data disclosure, credential
leak, unauthenticated local access, silent action, or update bypass occurs.

## Gate 5 — legal, license, and provenance approval

Generate an SPDX SBOM from the exact candidate commit and reconcile it with all
Cargo/Bun lockfiles and bundled native assets. The approver must review:

- upstream MIT provenance and all modified/fork notices;
- the repository’s source-license metadata;
- every model publisher, immutable source, hash, size, and license;
- CC BY attribution and CC BY-NC distribution/use implications;
- icons, logos, screenshots, fonts, examples, datasets, and third-party marks;
- FFmpeg configuration and native-library obligations;
- privacy notice, telemetry provider terms, BYOK data flow, retention/deletion,
  minors/workplace/recording-consent considerations, and user-rights wording;
- encryption/export controls and distribution territories;
- “Civitas,” upstream Screenpipe, and third-party trademark wording.

Record written approval and any territory/use restrictions in the release
decision. Technical metadata is not a substitute for legal approval.

**Stop condition:** an asset has unknown rights, notices are incomplete, or
the approver has not signed off.

## Gate 6 — GitHub repository controls

While the repository is still private:

1. configure the intended public default branch;
2. require the publication/security/test checks and at least one independent
   review;
3. block force pushes and branch deletion;
4. restrict Actions and release permissions;
5. enable dependency/security scanning and private vulnerability reporting;
6. configure issue/PR templates, labels, discussions/support policy, and
   maintainer ownership;
7. verify workflow permissions are least privilege and every third-party
   Action is commit-SHA pinned;
8. confirm Pages, environments, webhooks, deploy keys, Apps, secrets, variables,
   caches, and artifacts expose nothing private;
9. confirm archive repositories remain private and are not linked as public
   source dependencies.
10. Confirm the npm owner has 2FA, the package name is available, and the
    protected `consumer-release` environment—not a developer shell—owns the
    one-time bootstrap publication.
11. After the initial package exists, configure npm trusted publishing for
    `civitass/civitas-desktop`, workflow `release-mcp.yml`, environment
    `consumer-release`, and stage-only permission. The default workflow must
    use staged publishing; download and inspect its tarball, approve it with
    interactive 2FA, and publish the separate GitHub Release draft only after
    both artifacts match the reviewed evidence. After verification, disallow
    token publishing and revoke the bootstrap token. Follow the
    [npm trusted-publisher contract](https://docs.npmjs.com/trusted-publishers/)
    and leave the workflow's authentication mode at its
    `trusted-publisher` default after bootstrap.

Export a settings/evidence summary without secret values.

**Stop condition:** required checks can be bypassed, release permission is
ambiguous, or security reporting is unavailable.

## Gate 7 — signed macOS release candidate

Use repository/environment secrets for Apple Developer ID, notarization, and
Tauri updater signing. Do not use local untracked credentials in ordinary
build logs. Trigger the pinned release workflow from the reviewed immutable
tag; automation must create a **draft** release only.

For Apple Silicon and Intel artifacts:

1. confirm the tag version equals Cargo/Tauri metadata;
2. verify build provenance and workflow/commit identity;
3. verify SHA-256 manifests and SBOM;
4. verify Developer ID signature, hardened runtime, entitlements, nested code,
   Team ID, notarization, stapling, and Gatekeeper acceptance;
5. verify advertised architecture and bundled contents;
6. confirm model weights and secrets are absent from the DMG;
7. verify updater signatures and the stable manifest;
8. scan artifacts with the approved malware/transparency service;
9. ensure release notes disclose network/privacy/schema/model changes and known
   limits.

Follow every command and failure rule in
[`docs/RELEASE_VERIFICATION.md`](../RELEASE_VERIFICATION.md).

**Stop condition:** an artifact is ad-hoc signed, unnotarized, unstapled,
mislabelled, unverifiable, unexpectedly networked, or different from the
attested bytes.

## Gate 8 — clean-machine product matrix

Use fresh supported macOS installations for both architectures and only
synthetic content. Record OS build and artifact hash. Test:

- download, checksum/provenance verification, mount, install, first launch;
- denial and later granting of each permission;
- no account/entitlement gate;
- local-only onboarding and pre-staged model operation;
- every BYOK provider setup screen and diagnostic using dedicated test
  accounts with strict spend limits;
- local capture, pause, search, graph, Ask, citations, Next Actions, MCP,
  export, retention, deletion, and uninstall;
- telemetry/update default-off behavior;
- update from the prior supported release;
- interrupted update, invalid signature, schema migration, backed-up restore,
  and rollback/recovery procedure.

Repeat critical flows with the network denied. Verify no private Civitas or
Railway dependency appears.

**Stop condition:** data is lost, a privacy default differs, rollback is
unworkable, an architecture fails, or documentation cannot be followed by a
new user.

## Gate 9 — final two-person go/no-go

The release lead assembles an index linking each gate’s immutable evidence.
Both approvers independently confirm:

- all B1–B7 blockers in `IMPLEMENTATION_STATUS.md` are closed;
- the public-root tree hash equals the tested root;
- the release tag resolves to that reviewed commit;
- all artifacts match checksums and attestations;
- no open critical/high security or privacy finding remains;
- legal and operational owners signed off;
- archives are private;
- support, incident, revocation, and rollback owners are available.

The repository owner then gives explicit approval for each separate action:

1. rename and retain the existing source repository as a private archive;
2. create the new empty `civitass/civitas-desktop`, install only the sanitized
   root as its intended default branch, and verify the remote ref allowlist;
3. change only that new sanitized repository’s visibility to public;
4. publish the approved draft GitHub Release;
5. bootstrap the reviewed MCP package, migrate it to stage-only npm trusted
   publishing, then separately approve the staged package and GitHub draft;
6. submit or publish the independently reviewed Chrome Web Store candidate.

Approval of one action does not imply approval of the others.

## Gate 10 — cutover and immediate verification

Perform the approved actions in a staffed release window. Immediately verify
from a signed-out browser and a clean machine:

- only the intended root/history is visible;
- signed-out `git ls-remote` lists only the approved default branch and
  allowlisted tags—no historic feature, automation/session, audit, pull-request,
  or private release refs;
- cloud/platform/archive repositories remain private;
- README circular logo, transparent wordmark, links, license, notices,
  security route, and DMG downloads render correctly;
- every README product image comes from the release-candidate desktop UI under
  the isolated synthetic publication profile; no reconstructed mockup,
  credential, personal path, real conversation, capture, OCR, transcript,
  calendar item, contact, or device identifier is present;
- screenshot dimensions, light/dark rendering, alt text, and mobile GitHub
  layout were reviewed against the exact committed image bytes;
- branch protections and required checks still apply;
- source archives and release assets match approved hashes;
- vulnerability reporting works privately;
- the MCP npm tarball and `.mcpb` match the reviewed version, source commit,
  file allowlist, checksum, and runtime-only dependency boundary;
- installation and updater endpoints serve the attested bytes.

Record the visibility event, release event, public commit/tag IDs, asset
hashes, and verifier identities.

## Post-launch watch and rollback

For the first 72 hours, staff security reports, install failures, updater
health, provider-setup regressions, privacy questions, and dependency alerts.
Do not enable telemetry for users who did not consent.

If source history or personal data is exposed, making the repository private
again does not retract forks or caches. Activate incident response:

1. stop release/update distribution when safe;
2. preserve evidence;
3. revoke affected credentials and signing/update material;
4. request platform cache/fork assistance where applicable;
5. notify affected people and regulators when required;
6. publish a corrected new version—never replace bytes under an existing
   release filename.

For a bad binary without source disclosure, keep the repository available when
safe, withdraw the affected release/update manifest, publish clear guidance,
and issue a newly tagged, signed, notarized replacement after full gates.
