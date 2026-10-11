# Code scanning triage

CodeQL runs on every push and pull request to `main` and on a weekly schedule
(`.github/workflows/codeql.yml`), across three languages — `actions`,
`javascript-typescript`, and `rust` — with the `security-extended` query suite.
Results land in
[Security → Code scanning](https://github.com/civitass/civitas-desktop/security/code-scanning).

`Analyze actions`, `Analyze javascript-typescript`, and `Analyze rust` are
required analysis checks on `main`. A successful analysis run does not by
itself establish that every finding has been resolved; findings still need
source review and remediation.

This document records how the first full-repository scan was triaged. It exists
so a contributor who opens the code scanning tab can tell a dismissed alert from
an ignored one, and so a future reviewer can re-check the reasoning rather than
re-derive it.

The classifications below describe source review, not the current alert state
in GitHub. A follow-up review for 2.8.1 found that MCP's initial URL guard did
not cover redirects. The shared MCP client now rejects redirects for JSON-RPC,
notifications, OAuth discovery, registration, and token requests, with tests
that assert a redirect destination receives no requests or credentials.

## How alerts are handled

1. **Fix it** when the finding is reachable and the code should change.
2. **Dismiss as a false positive** when the query's assumption does not hold for
   this codebase — a sanitizer CodeQL does not model, or a value the query has
   mis-typed.
3. **Dismiss as used in tests** when the pattern only exists inside a
   `#[cfg(test)]` module or a test harness.

Never dismiss an alert to make a check pass. If a dismissal is not obviously
correct from the linked source, it belongs in this file first.

## Fixed

| Query | Location | Fix |
| --- | --- | --- |
| `js/xss` | `packages/civitas-mcp/ui/search.html` | Result `type` was interpolated into markup unescaped, and the copy/ask buttons encoded captured text into inline `onclick` handlers where it had to survive both HTML-attribute and JavaScript-string parsing. The type is now escaped and narrowed to a class-safe slug, and the buttons carry an index into a payload array read by a delegated listener. |
| `js/missing-origin-check` | `packages/civitas-mcp/ui/search.html` | The `message` handler accepted frames from any window. It now pins to the embedding host captured at load (`ancestorOrigins`, then `document.referrer`) and checks both `event.source` and `event.origin`. Outbound `postMessage` calls target that origin instead of `*`. |
| `js/incomplete-multi-character-sanitization` | `apps/civitas-app-tauri/lib/utils.ts` | `convertHtmlToMarkdown` stripped tags in a single pass, so `<scr<script>ipt>` reassembled into a live tag. It now strips until the text stops changing. |
| `js/remote-property-injection` | `apps/civitas-app-tauri/lib/hooks/use-overlay-data.ts` | Per-device audio levels were stored in a plain object keyed by device names arriving over the metrics socket, so a `__proto__` key would have mutated `Object.prototype` for the whole renderer. Rejecting the dangerous key names was not enough — an outside-controlled name should not become an object property at all — so `deviceLevels` is now a `Map`. |
| `js/incomplete-url-substring-sanitization` | `packages/browser-extension/src/worker.ts` | The Web Store check was a substring test over the whole URL. It now parses the URL and compares the hostname against an explicit list. |
| `js/insecure-randomness` (×3) | `standalone-chat.tsx`, `lib/stores/pi-event-router.ts`, `lib/utils/generate-title-with-preset.ts` | Correlation ids that decide which optimistic bubble a streamed turn resolves against came from `Math.random()`. They now use `randomIdSuffix()` in `lib/utils.ts`, backed by `crypto.randomUUID()`. |
| `js/stack-trace-exposure` (×4) | `crates/civitas-connect/src/whatsapp/gateway.mjs` | The loopback HTTP surface returned `err.message` to callers. Errors now go to stderr and callers get a fixed label. |
| `js/log-injection` (×3) | `apps/civitas-app-tauri/e2e/tests/websocket-performance.js` | Server-supplied values were logged unescaped. Each value is now flattened and truncated where it enters the socket handler rather than at each `console.log`, which also covered two reporting paths a per-call-site fix had missed — the end-of-run error summary and the JSON parse handler. Frame counters are coerced with `Number()`. Note that the newline must be replaced with the empty string: CodeQL models `replace("\n", "")` as a sanitizer and does not recognise replacing it with a space. |
| `js/clear-text-logging` | `apps/civitas-app-tauri/e2e/mock-updates/updater-harness.ts` | The harness printed the value of `TAURI_SIGNING_PRIVATE_KEY_PATH` on failure. It now names the variable only. |
| `js/file-system-race` | `apps/civitas-app-tauri/scripts/pre_build.js` | An exists-then-write pair on an empty placeholder became an unconditional write. |
| `js/redos` | `scripts/validate-public-docs.mjs` | The Markdown link pattern let both branches of an alternation consume a backslash, so a link body of many `\!` backtracked exponentially. The second branch now excludes the backslash. |
| `js/regex/missing-regexp-anchor` (×3) | `scripts/audit-publication.mjs` | These scan file contents for forbidden hosts, so anchoring them to the start of a URL would have been wrong. Two now bound the host label on both sides — matching the host but not `not-example.com` or `example.com.evil.net` — and the favicon rule, which already carried a path, became a case-insensitive substring check. |
| `js/incomplete-url-substring-sanitization` | `scripts/audit-consumer-design.mjs` | The pinned interaction-review reference was matched as one URL string. Repository and commit are now checked independently, so a reference that drifts to another revision is reported. |
| `rust/cleartext-transmission` | `crates/civitas-connect/src/connections/pipedrive.rs` | The connection test put `api_token` in the query string, where every proxy and server access log records it verbatim. It is now sent as a header, matching the `proxy_config` this integration already declares. |
| `js/insecure-temporary-file` (×4), `js/file-system-race` (×2) | `apps/civitas-app-tauri/e2e/specs/windows-core-recording.spec.ts` | The Windows marker hosts wrote a PowerShell script and an HTA straight into the shared temp directory and then executed it, so another account on the machine could pre-create or symlink the path. Both now use a per-call `mkdtemp` directory removed wholesale on cleanup. The readiness sentinels are claimed with an exclusive create instead of an exists-then-write pair that could overwrite a file the detached child wrote in between. |

## Reviewed source classifications

### Hard-coded cryptographic value, production code (3)

`crates/civitas-vault/src/crypto.rs:296` and `:809`, and
`crates/civitas-secrets/src/keychain.rs:158` are zero-initialised buffers —
`[0u8; NONCE_SIZE]`, `[0u8; SALT_SIZE]`, `[0u8; 32]` — that are overwritten on
the next statement by `read_exact`, `fill_bytes`, or `copy_from_slice`. The
query reads the array literal as the key material. Nonces and salts are
generated by `generate_salt` / `rand::thread_rng().fill_bytes`.

### Path injection: allowed local sources and managed destinations

An owner may deliberately select a local workflow source outside the Civitas
data directory. That does not authorize arbitrary installation destinations
or make scoped workflow clients equivalent to the owner. The 2.8.1 review
found missing destination checks in the pipe manager and corrected them:

- validate workflow identifiers before every managed-path mutation;
- reject symlinks and Windows reparse points in managed ancestors and files;
- preflight package destinations before copying;
- replace files atomically rather than truncating an existing hard link;
- apply the same guards to discovery, builtins, scheduled runs, PID files,
  logs, and history.

Regression tests cover traversal identifiers, linked roots/directories/files,
external hard links, binary updates, and preservation of executable modes.
This is application-level path confinement, not a defense against a malicious
same-account process racing filesystem renames.

Database paths still pass through their explicit data-root containment guard.
Connection configuration files use fixed names under the configured data root.
The WhatsApp executable resolver accepts only empty, `bun`, or `bun.exe` hints
at its HTTP entry point; startup passes no caller-selected executable. These
source-level controls must be reviewed individually when CodeQL does not
model them. Open findings have not been dismissed merely to clear the scan.

### Server-side request forgery (2)

`crates/civitas-connect/src/mcp_servers.rs:1683` and `:1872` are both preceded
by `authorize_mcp_url(url)?` on the immediately prior line, and `send_jsonrpc`
re-checks at the last in-process boundary before the socket opens.
`authorize_mcp_url` runs the URL through the egress policy in
`crates/civitas-core/src/network.rs`, which rejects credentials in the URL,
rejects any scheme other than `https`/`wss` (or `http`/`ws` on loopback), and
denies non-loopback destinations entirely in local-only mode. CodeQL does not
model that guard as a sanitizer. The URL is the MCP server the user configured.
The shared client now disables redirects, including for OAuth requests;
previously an allowed endpoint could redirect past the initial guard.

### Cleartext transmission (3)

`crates/civitas-connect/src/mcp_servers.rs:931` (OAuth refresh) is gated by the
same `authorize_mcp_url` guard, which enforces TLS off loopback.
`connections/whatsapp.rs:64` and `connections/bitrix24.rs:85` build `https://`
URLs from a literal prefix. Bitrix24's webhook secret is in the path because
that is the shape of a Bitrix24 inbound webhook. Both connector modules are
absent from the consumer registry, and the connection manager's HTTP client
disables redirects. The personal WhatsApp gateway is a separate, reachable
feature; 2.8.1 adds policy checks before startup/install/restart and stops it
when Local-only is observed.

### Cleartext logging, production code (2)

`crates/civitas-engine/src/cli/auth.rs:20` is `civitas auth token`, whose entire
purpose is to print the local API token to stdout for the calling shell — the
same contract as `gh auth token`. `crates/civitas-engine/src/cli/connection.rs:243`
prints `stored_secret_fields`, which is a list of *field names*; the values are
never read (the human-readable branch prints `<stored securely>`).

### File data in outbound network request (1)

`crates/civitas-core/assets/extensions/civitas-permissions.ts:555` sends the
workflow token, read from the local permissions file, to `API_ORIGIN` —
`http://127.0.0.1:3030`. The request cannot leave loopback: the URL is rebuilt
against `API_ORIGIN` and rejected unless `url.origin === API_ORIGIN` and the
path round-trips unchanged.

### Unsafe checkout of untrusted pull request (1)

`.github/workflows/release-app.yml:207` checks out
`needs.validate.outputs.commit`. The workflow has no `pull_request` or
`pull_request_target` trigger — it runs only on `push` of a `v*` tag or on
`workflow_dispatch` — and the `validate` job refuses to proceed unless the tag
already exists and points at the checked-out commit. Pinning every downstream
job to that one commit is what stops a tag from being moved mid-release; it is
the control, not the gap.

## Historical test-only classifications

Fifty-two `rust/hard-coded-cryptographic-value` alerts and three
`rust/cleartext-logging` alerts are inside `#[cfg(test)]` modules:

| File | `#[cfg(test)]` begins | Alert lines |
| --- | --- | --- |
| `crates/civitas-vault/src/manager.rs` | 597 | 616–950 |
| `crates/civitas-vault/src/crypto.rs` | 828 | 919, 920, 923 |
| `crates/civitas-core/src/pii_removal.rs` | 345 | 941, 1048, 1078–1296 |
| `apps/civitas-app-tauri/src-tauri/src/store.rs` | 2293 | 2528, 2574–2738 |
| `crates/civitas-engine/src/cli/store_file.rs` | 172 | 177 |
| `crates/civitas-core/src/pipes/mod.rs` | 5546 | 6292 |
| `crates/civitas-connect/src/ics_calendar.rs` | 746 | 756 |

These are fixed test vectors and fixture passwords. None is compiled into a
release build; `--features official-build` does not build test modules.
