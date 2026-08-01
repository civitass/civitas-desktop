# ADR 0008 — Local API authentication fails closed

## Status

Accepted

## Context

Loopback is not an authorization boundary. Other local processes and hostile
web content can attempt requests to services on the user’s machine. The Civitas
API exposes sensitive timeline and knowledge-graph data.

## Decision

- The engine binds to loopback by default and requires a high-entropy bearer
  credential for every data-bearing route.
- The credential is generated per install and stored in the encrypted Civitas
  secret store backed by the OS credential vault. New generated credentials
  contain 244 random bits.
- On upgrade, only the exact historical first-party shape (`sp-` followed by
  eight hexadecimal characters) is recognized as a legacy 32-bit credential.
  It is replaced and durably encrypted before the server starts. Arbitrary
  custom values and explicit `CIVITAS_LOCAL_API_KEY` overrides are not silently
  reclassified or rewritten.
- Credentials in query strings are rejected. HTTP uses the `Authorization`
  header; WebSockets use the authenticated subprotocol.
- Only content-free readiness and tightly validated OAuth/pairing callbacks are
  exempt. Frame/media routes are authenticated.
- CORS is an allowlist, origin checks reject hostile browser origins, and
  state-changing routes remain protected even on loopback.
- The consumer build has no LAN binding and cannot disable authentication.
- The MCP bridge receives the local key only through the explicit
  `CIVITAS_LOCAL_API_KEY` environment variable. It does not inspect files,
  databases, generic account variables, or command output.
- Knowledge-graph agent grants store only a token hash, can be narrowed or
  revoked, and are audited. The owner key is not a substitute for a scoped
  grant when a client can operate with graph-only access.

## Consequences

A credential-store failure produces a visible startup or authorization failure
rather than an open server. An unreadable local-only owner row and the exact
legacy 32-bit generated shape can be narrowly replaced before startup; provider
and integration secrets remain untouched. Rotating the owner key invalidates
configured clients and requires reconnection. Local clients must be treated as
privileged because a process that can read their configuration may also read
any credential stored there.
