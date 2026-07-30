# ADR 0006 — Content-addressed external assets

## Status

Accepted

## Context

Civitas downloads optional speech, speaker, and Smart PII models. Mutable
branch URLs or unchecked binaries would let an upstream change executable model
behavior after a Civitas release.

## Decision

- Every runtime model URL is pinned to an immutable upstream revision.
- Every downloaded binary is verified against a hard-coded SHA-256 digest
  before it is used.
- A mismatch deletes the partial/untrusted file and fails closed.
- Downloads occur only after the feature requiring that model is selected.
- The UI displays the approximate size, purpose, source, and material license
  restriction before optional models are fetched.
- Smart PII model weights are not bundled. The current upstream weights are
  CC BY-NC 4.0; use requires explicit, versioned non-commercial-license
  acknowledgement. Commercial users must supply weights for which they hold
  suitable rights.
- Git dependencies remain pinned by commit in `Cargo.lock`. Publication CI
  checks licenses and known vulnerabilities; provenance is recorded in
  [`docs/MODEL_CATALOG.md`](../MODEL_CATALOG.md) and
  [`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md).

## Consequences

Updating a model is a reviewed source change: revision, digest, license record,
size, tests, and notices all change together. An upstream deletion can prevent
a new download but cannot silently substitute different bytes.
