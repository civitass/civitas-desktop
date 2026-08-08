# Release verification

Official Civitas Desktop artifacts are built by the pinned GitHub Actions
workflow from an immutable commit. The workflow is fail-closed: it cannot
complete the draft unless both macOS DMGs are Developer ID signed, notarized,
and stapled and the Windows application and installer have valid timestamped
Authenticode signatures. Automation creates a **draft** GitHub Release; it
cannot publish the release.

## Expected release files

For each version, the draft should contain:

- macOS DMGs for Apple Silicon and Intel, or the architecture matrix stated in
  the release notes;
- one signed Windows x86-64 NSIS installer named
  `Civitas-Desktop_<version>_x64-setup.exe`;
- Tauri updater archives and signatures for both macOS architectures and
  Windows x86-64, plus one canonical `latest.json`;
- `SHA256SUMS`;
- SPDX JSON SBOM named for the version;
- Civitas license, notice, and third-party notices;
- GitHub build-provenance attestations;
- release notes describing privacy/network/schema changes and known limits.

Do not substitute an unverified file from another host. R2 or another mirror
may mirror the exact bytes, but GitHub Releases is the primary public source.

## Maintainer gate before publication

1. Confirm the release tag is exactly `v<version>` from the Tauri Cargo
   metadata and resolves to the reviewed commit.
2. Confirm the publication audit, secret scan, Tauri production security
   audit, JavaScript and Rust advisory gates, locked dependency install,
   bindings check, frontend tests, Rust checks, and platform tests passed for
   that commit.
3. Confirm the release workflow used only full-SHA Actions and minimal
   permissions.
4. Inspect the SBOM and notices for unexpected packages/licenses.
5. Download every draft artifact into a clean verification directory.
6. Verify checksums, provenance, code signature, notarization ticket,
   Gatekeeper assessment, architecture, updater signature, and bundled
   contents.
7. Install on clean supported macOS and Windows versions and complete the smoke
   matrix. The automated Windows job also performs an isolated silent install,
   verifies every installed executable and library against the reviewed,
   timestamped publisher certificate, and exercises the uninstaller.
8. Test upgrade from the prior supported version with a backed-up synthetic
   data directory.
9. Confirm rollback/recovery instructions for any data migration.
10. Record every review that actually occurred. Never substitute an automated
    scan or one person's review for a claimed second-maintainer, external
    security, or legal approval.

## User checksum verification

Download the DMG and `SHA256SUMS` from the same GitHub Release. On macOS:

```bash
shasum -a 256 Civitas-Desktop_*.dmg
grep 'Civitas-Desktop_.*\\.dmg' SHA256SUMS
```

The digest printed for the DMG must exactly match its `SHA256SUMS` entry. A
checksum proves byte equality with the manifest, not authorship; also verify
the GitHub provenance and Apple signature.

## Apple signature and notarization

Before opening the DMG:

```bash
xcrun stapler validate Civitas-Desktop_*.dmg
spctl --assess --type open --context context:primary-signature --verbose=4 \
  Civitas-Desktop_*.dmg
```

Mount it and verify the application:

```bash
hdiutil attach Civitas-Desktop_*.dmg -nobrowse
codesign --verify --deep --strict --verbose=4 \
  "/Volumes/Civitas Desktop/Civitas Desktop.app"
codesign -dv --verbose=4 \
  "/Volumes/Civitas Desktop/Civitas Desktop.app" 2>&1
xcrun stapler validate "/Volumes/Civitas Desktop/Civitas Desktop.app"
spctl --assess --type execute --verbose=4 \
  "/Volumes/Civitas Desktop/Civitas Desktop.app"
```

Inspect the reported identifier, Team ID, hardened runtime flags, designated
requirement, and signing authority against the release notes. Stop if macOS
reports an ad-hoc signature, missing/not accepted notarization, altered nested
code, or an unexpected signer.

## Architecture

```bash
file "/Volumes/Civitas Desktop/Civitas Desktop.app/Contents/MacOS/"*
```

Install only the architecture advertised by the release. The workflow builds
Apple Silicon (`aarch64-apple-darwin`) and Intel
(`x86_64-apple-darwin`) artifacts separately.

## Windows checksum and Authenticode

Download the installer and `SHA256SUMS` from the same release, then run in
PowerShell:

```powershell
$installer = Get-Item .\Civitas-Desktop_*_x64-setup.exe
Get-FileHash $installer -Algorithm SHA256
Get-Content .\SHA256SUMS | Select-String $installer.Name

$signature = Get-AuthenticodeSignature $installer
$signature | Format-List Status, StatusMessage, SignerCertificate, TimeStamperCertificate
if ($signature.Status -ne 'Valid' -or -not $signature.TimeStamperCertificate) {
    throw 'Do not install: the Civitas installer signature is not valid and timestamped.'
}
```

The checksum must match exactly. The signature must report `Valid`, include the
expected Civitas publisher from the release notes, and include a timestamping
certificate. Stop if Windows reports `NotSigned`, `HashMismatch`, `UnknownError`,
or an unexpected publisher. Official Civitas releases never ask users to bypass
SmartScreen for an unsigned binary.

## GitHub provenance

Use GitHub's artifact attestation verification against the repository:

```bash
gh attestation verify Civitas-Desktop_*.dmg \
  --repo civitass/civitas-desktop
gh attestation verify Civitas-Desktop_*_x64-setup.exe \
  --repo civitass/civitas-desktop
```

Verify the attested source repository, workflow, commit SHA, and expected tag.
An attestation for a different commit is not acceptable even if the filename
matches.

## Updater verification

The production configuration pins the Tauri updater public key and the GitHub
Releases manifest endpoint. Test:

- `latest.json` contains signed `darwin-aarch64`, `darwin-x86_64`, and
  `windows-x86_64` entries that point only to the immutable release tag;

- valid signed update from the stable channel;
- tampered bundle rejection;
- invalid/missing signature rejection;
- a manifest pointing to a different channel/host rejection;
- version downgrade behavior;
- interrupted download and retry;
- update while recording, ensuring capture shuts down cleanly;
- schema migration and preserved local data;
- manual updates when Auto-update is off.

Background update checks are off on a fresh install. Enabling Auto-update is
consent to periodic GitHub metadata requests, download, verification, and
automatic restart. The manual Check for updates button is the one-shot path.

## Dependency advisory gates

The exact release commit must pass both repository-owned, blocking gates:

```bash
node scripts/audit-js-security.mjs
node scripts/audit-rust-security.mjs
```

The JavaScript gate requires exact Bun `1.3.10`, reproduces every tracked
`bun.lock` with frozen resolution and disabled lifecycle scripts, and audits
at the low threshold. The Rust gate requires `cargo-audit 0.22.2`, audits both
Rust lockfiles, and fails if its reviewed advisory set, parent edges, or
Apple-Silicon reachability changes. Do not replace either gate with a
non-blocking Dependabot snapshot, suppress a finding without reachability
evidence, or publish while a new advisory is unclassified.

## Clean-machine smoke matrix

Using only synthetic content:

- first launch has no account gate;
- capture permissions are explained separately;
- denied permissions do not crash the app;
- local API binds only to `127.0.0.1` and requires auth;
- clipboard and raw typed-text persistence are off;
- product analytics and automatic updates are off;
- a synthetic native panic produces a local diagnostic with no network upload;
- pause/private state is visible and persists across restart;
- local capture, search, timeline, graph, export, and delete work;
- local-provider onboarding works with models pre-staged;
- remote BYOK shows destination/cost boundary and vault failure is fail-closed;
- provider diagnostic uses the fixed non-sensitive prompt;
- Next Actions cites evidence and never executes;
- uninstall/reinstall and data-preservation behavior match the documentation.

Run the equivalent smoke set on each supported OS/architecture. Record OS build
numbers and artifact SHA-256 values.

## SBOM and licenses

The SPDX file is generated from the exact release commit. Compare it against
the lockfiles and investigate new direct, native, binary, model, or copyleft
components. Confirm the bundled FFmpeg was built by the pinned script with GPL,
nonfree, network, and auto-detected external components disabled.

Confirm the optional assistant inventory is present in the SBOM, matches
`crates/civitas-core/assets/pi-runtime/bun.lock`, and contains the
reviewed Pi `0.82.1` package family. Reproduce a clean
`bun install --frozen-lockfile --production --ignore-scripts` with Bun `1.3.10`
and verify the lockfile remains byte-for-byte unchanged.

Model weights are not part of the DMG. Their own publisher/license/source
disclosure is required before first download.

## Browser-extension candidate

The browser extension has a separate manual package workflow and Chrome review
boundary. `Package Browser Extension` produces a ZIP, SHA-256 checksum,
privacy policy, and store-copy artifact; it never uploads or publishes them.

Before store submission:

1. reproduce `bun install --frozen-lockfile && bun run check` from the exact
   reviewed commit;
2. compare the ZIP checksum with the protected workflow artifact;
3. inspect `manifest.json` for only `activeTab`, `scripting`, `storage`,
   `alarms`, `notifications`, and HTTP loopback host permissions;
4. search both source and bundle for arbitrary evaluation, debugger/cookie
   APIs, `<all_urls>`, remote scripts, and URL credentials;
5. test matching-code pairing, active-tab expiry, snapshot redaction,
   navigation Allow once/deny/timeout, reconnect, and uninstall with synthetic
   pages;
6. compare every Chrome dashboard declaration with
   `packages/browser-extension/PRIVACY.md` and `store-listing.md`;
7. submit with deferred publishing and publish only after independent review
   and the repository/desktop go-live approvals.

The store listing is not an official download until its review and publication
are independently recorded.

## MCP package candidate

The protected MCP workflow must audit and test before authentication or any
public write. It builds two separately reviewed artifacts:

- an npm tarball allowlisted to runtime output, UI, manifest, README, and
  license, with npm provenance enabled;
- a production-only `.mcpb` built in a clean staging directory with lifecycle
  scripts disabled.

The workflow rejects source tests, build tools, development dependencies,
unexpected native libraries/executables, and compressed MCP bundles over the
reviewed 5 MiB ceiling. Verify the `.mcpb` ZIP, its SHA-256 sidecar, package
version, manifest version, runtime entry points, and loopback-only behavior
before allowing the protected environment to publish. An existing GitHub
Release is immutable to the workflow; publish a new package version instead
of replacing an artifact.

The workflow defaults to npm trusted-publisher authentication with pinned
Node `24.18.0`. That path uses `npm stage publish`: it does not make the
package public until a maintainer downloads or otherwise inspects the staged
tarball and approves it with 2FA. The workflow also leaves the matching GitHub
Release as a draft, so npm approval and GitHub Release publication remain
separate human decisions.

The explicit `bootstrap-token` mode is only for the initial publication
because npm cannot stage a brand-new package or attach a trusted publisher
before the package exists. After bootstrap, configure
`civitass/civitas-desktop`, `release-mcp.yml`, and `consumer-release` as the
package's stage-only
[trusted publisher](https://docs.npmjs.com/trusted-publishers/), verify an
OIDC staging and 2FA approval cycle, revoke the bootstrap token, and disallow
ordinary token publishing.

## Source builds

A source build is useful and supported by the community, but it is not signed
by the Civitas Developer ID and intentionally does not auto-update. Verify the
commit and dependencies yourself. Do not represent a source build as an
official DMG.

## Failure handling

Do not publish when any artifact, signature, checksum, provenance statement,
scan, install, upgrade, or privacy claim is uncertain. Preserve the draft and
logs, revoke or rotate any exposed credential, open a private security
advisory, and issue a new version/tag after remediation. Never replace bytes
under an already published release filename.
