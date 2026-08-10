# Code scanning triage

CodeQL runs on every push and pull request to `main` and on a weekly schedule
(`.github/workflows/codeql.yml`), across three languages — `actions`,
`javascript-typescript`, and `rust` — with the `security-extended` query suite.
Results land in
[Security → Code scanning](https://github.com/civitass/civitas-desktop/security/code-scanning).

`Analyze actions`, `Analyze javascript-typescript`, and `Analyze rust` are
required status checks on `main`, so a pull request that introduces a new alert
cannot merge.

This document records how the first full-repository scan was triaged. It exists
so a contributor who opens the code scanning tab can tell a dismissed alert from
an ignored one, and so a future reviewer can re-check the reasoning rather than
re-derive it.

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
| `js/remote-property-injection` | `apps/civitas-app-tauri/lib/hooks/use-overlay-data.ts` | Per-device audio levels were keyed by names arriving over the metrics socket. `__proto__`, `constructor`, and `prototype` are now rejected. |
| `js/incomplete-url-substring-sanitization` | `packages/browser-extension/src/worker.ts` | The Web Store check was a substring test over the whole URL. It now parses the URL and compares the hostname against an explicit list. |
| `js/insecure-randomness` (×3) | `standalone-chat.tsx`, `lib/stores/pi-event-router.ts`, `lib/utils/generate-title-with-preset.ts` | Correlation ids that decide which optimistic bubble a streamed turn resolves against came from `Math.random()`. They now use `randomIdSuffix()` in `lib/utils.ts`, backed by `crypto.randomUUID()`. |
| `js/stack-trace-exposure` (×4) | `crates/civitas-connect/src/whatsapp/gateway.mjs` | The loopback HTTP surface returned `err.message` to callers. Errors now go to stderr and callers get a fixed label. |
| `js/log-injection` (×3) | `apps/civitas-app-tauri/e2e/tests/websocket-performance.js` | Server-supplied values were logged unescaped. They are flattened to one line and truncated first. |
| `js/clear-text-logging` | `apps/civitas-app-tauri/e2e/mock-updates/updater-harness.ts` | The harness printed the value of `TAURI_SIGNING_PRIVATE_KEY_PATH` on failure. It now names the variable only. |
| `js/file-system-race` | `apps/civitas-app-tauri/scripts/pre_build.js` | An exists-then-write pair on an empty placeholder became an unconditional write. |
| `js/redos` | `scripts/validate-public-docs.mjs` | The Markdown link pattern let both branches of an alternation consume a backslash, so a link body of many `\!` backtracked exponentially. The second branch now excludes the backslash. |
| `js/regex/missing-regexp-anchor` (×3) | `scripts/audit-publication.mjs` | Two deny-list host scans became case-insensitive substring checks — they scan file contents, not URLs, and the regexes only invited the URL reading. The third now bounds the host label on both sides. |
| `js/incomplete-url-substring-sanitization` | `scripts/audit-consumer-design.mjs` | The pinned interaction-review reference was matched as one URL string. Repository and commit are now checked independently, so a reference that drifts to another revision is reported. |
| `rust/cleartext-transmission` | `crates/civitas-connect/src/connections/pipedrive.rs` | The connection test put `api_token` in the query string, where every proxy and server access log records it verbatim. It is now sent as a header, matching the `proxy_config` this integration already declares. |

## Dismissed — false positive

### Hard-coded cryptographic value, production code (3)

`crates/civitas-vault/src/crypto.rs:296` and `:809`, and
`crates/civitas-secrets/src/keychain.rs:158` are zero-initialised buffers —
`[0u8; NONCE_SIZE]`, `[0u8; SALT_SIZE]`, `[0u8; 32]` — that are overwritten on
the next statement by `read_exact`, `fill_bytes`, or `copy_from_slice`. The
query reads the array literal as the key material. Nonces and salts are
generated by `generate_salt` / `rand::thread_rng().fill_bytes`.

### Path injection (20)

Civitas is a single-user local-first desktop app: the "user-provided value" in
each of these paths is the operator's own CLI argument, their own configuration
file, or their own data directory. There is no second principal to escalate
against. The individual sites also fall into three groups:

- **The containment check itself.** `crates/civitas-db/src/db.rs:386`, `:398`,
  `:406` are inside the function that canonicalises a candidate path and
  rejects anything resolving outside the Civitas data root. `:7729` and `:7731`
  operate on a path that already passed it — the failing branch records
  `path is outside the Civitas data directory`.
- **Already validated.** `crates/civitas-core/src/pipes/mod.rs:3625`, `:3632`,
  `:3678`, `:3685` are `install_pipe`, guarded by `reject_symlink`,
  `validate_pipe_file` / `validate_pipe_package`, and `validate_pipe_name`.
- **Constant filename under the app data directory, or an operator-supplied
  executable path.** `crates/civitas-connect/src/mcp_servers.rs:268`, `:288`
  (`civitas_dir.join("mcp_servers.json")`),
  `crates/civitas-connect/src/ics_calendar.rs:130`, `:141` (the local
  `store.bin`), and `crates/civitas-connect/src/whatsapp/mod.rs:545`
  (`resolve_bun_path`, an existence probe on a path the user pointed at).

The remaining sites in `pipes/mod.rs` (`:5583`–`:5692`) are inside a
`#[cfg(test)]` module.

### Server-side request forgery (2)

`crates/civitas-connect/src/mcp_servers.rs:1683` and `:1872` are both preceded
by `authorize_mcp_url(url)?` on the immediately prior line, and `send_jsonrpc`
re-checks at the last in-process boundary before the socket opens.
`authorize_mcp_url` runs the URL through the egress policy in
`crates/civitas-core/src/network.rs`, which rejects credentials in the URL,
rejects any scheme other than `https`/`wss` (or `http`/`ws` on loopback), and
denies non-loopback destinations entirely in local-only mode. CodeQL does not
model that guard as a sanitizer. The URL is the MCP server the user configured.

### Cleartext transmission (3)

`crates/civitas-connect/src/mcp_servers.rs:931` (OAuth refresh) is gated by the
same `authorize_mcp_url` guard, which enforces TLS off loopback.
`connections/whatsapp.rs:64` and `connections/bitrix24.rs:85` build `https://`
URLs from a literal prefix. Bitrix24's webhook secret is in the path because
that is the shape of a Bitrix24 inbound webhook; there is no header form.

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

## Dismissed — used in tests

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
