# ADR 0004 — Consent before telemetry

## Status

Accepted

## Context

Civitas processes unusually sensitive personal work context. A conventional
default-on analytics or crash-reporting setup would create an unexpected
network path and could place window titles, provider errors, or capture-derived
text in a third-party system.

## Decision

- Product analytics are off by default.
- The user must make a versioned, explicit choice before analytics starts.
- The native app and engine have no automatic remote crash-reporting path;
  panic records and application logs remain local unless explicitly shared.
- Declining or skipping the choice is equivalent to disabled.
- A build without the corresponding build-time endpoint/key remains a no-op
  even if a local preference is enabled.
- Event payloads must pass the central sanitizer. Credentials, capture text,
  prompts, transcripts, file paths, window titles, URLs, and local identifiers
  are not allowed.
- The preference and its version stay local. Changing the event schema or data
  classes requires a new consent version.
- The public network inventory is
  [`docs/NETWORK_BOUNDARY.md`](../NETWORK_BOUNDARY.md); it must change in the
  same commit as any new outbound destination.
- `CIVITAS_NETWORK_MODE=deny` disables optional egress, including analytics,
  regardless of the stored preference.

## Consequences

Source builds have no product analytics unless a contributor deliberately
supplies the build configuration and then opts in. Release verification
includes a pre-consent packet-capture check and confirms that native crash
diagnostics remain local. Diagnostics shown in the UI stay on-device unless
the user separately chooses to export them.
