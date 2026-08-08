# ADR 0005 — Signed GitHub Releases update channel

## Status

Accepted

## Context

The consumer app needs downloadable macOS DMGs, a Windows installer, and a safe
update path without depending on the retired Civitas control plane.

## Decision

- Public binaries and updater manifests are distributed from the
  `civitass/civitas-desktop` GitHub Releases page.
- The production app accepts only manifests signed by the public Tauri updater
  key embedded in `tauri.prod.conf.json`.
- Release automation uses a draft as a private staging boundary while artifacts
  are assembled. It publishes only after exact-commit tests, notarization,
  platform signatures, checksums, SBOM, provenance, updater verification, and
  isolated installation checks pass; any missing evidence leaves the draft
  unpublished.
- macOS artifacts use Developer ID signing, hardened runtime, notarization, and
  stapling. Release jobs fail if `codesign`, `spctl`, or `stapler` validation
  fails.
- Windows artifacts use timestamped Authenticode and a signed NSIS installer.
  The release fails when SSL.com credentials are incomplete, a signature or
  timestamp is invalid, the payload boundary scan fails, or the isolated
  install/uninstall check fails.
- All third-party workflow actions are pinned to immutable commits and release
  permissions are least-privilege.
- Source builds have the updater disabled. Beta and stable use separate,
  explicit GitHub Release manifest locations.
- The updater private key, Apple credentials, and Windows signing credentials
  exist only in the protected release environment. They are never printed,
  archived, or made available to pull-request jobs.

## Consequences

Core functionality has no Railway or Civitas-hosted runtime dependency. Update
checks are still optional outbound requests to GitHub; they are disabled by
network-deny mode. Key compromise requires revocation, incident disclosure, and
a manual reinstall path because existing clients trust the embedded public key.
See [`docs/RELEASE_VERIFICATION.md`](../RELEASE_VERIFICATION.md).
