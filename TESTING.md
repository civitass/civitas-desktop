# Civitas Desktop test and release checklist

This checklist covers the consumer, local-first build. Use only synthetic data.
Never run publication tests against personal capture, customer material, live
credentials, or another person's account.

Automated checks catch regressions; they do not replace clean-machine,
permission, network, accessibility, signing, or destructive-data testing.

## 1. Required automated checks

```bash
cargo fmt --all -- --check
cargo check --locked --workspace
cargo test --locked --workspace

cd apps/civitas-app-tauri
bun install --frozen-lockfile
bun run typecheck
bun run test
bun run bindings:check
bun run e2e:coverage:check

cd ../..
node scripts/audit-consumer-design.mjs
node scripts/validate-tauri-production-security.mjs .
node scripts/audit-publication.mjs .
```

- [ ] No ignored failure is introduced without a tracked reason and owner.
- [ ] Generated Tauri bindings and embedded skills match source.
- [ ] Consumer-critical surfaces pass the native-radius, tokenized-type,
  restrained-motion, and accessibility design gate.
- [ ] Release-tree secret scan reports no unclassified credential.
- [ ] Consumer runtime/assets contain no Railway, private Civitas API, account
  gate, enterprise policy, fleet, or team-sync symbol.
- [ ] Dependency/SBOM diff is reviewed for new native code, licenses, binaries,
  and network clients.

FFmpeg frame-extraction integration tests use runtime-generated synthetic
media and are excluded from the default suite because FFmpeg is an external
binary. A media/release owner runs them against the exact reviewed release
binary:

```bash
CIVITAS_TEST_FFMPEG=/absolute/path/to/ffmpeg \
  cargo test --locked -p civitas-engine --test frame_extraction_test \
  -- --ignored --test-threads=1
```

## 2. First launch and account-free core

Test with a new OS user or empty `CIVITAS_DATA_DIR`.

- [ ] App launches without a Civitas login, entitlement, subscription, or
  network connection.
- [ ] Onboarding begins with the local-only choice.
- [ ] Screen, accessibility, microphone/system-audio, and notification
  permissions are explained separately.
- [ ] Denying any permission gives a clear degraded state without a crash or
  retry loop.
- [ ] Capture/search/graph/export/delete surfaces are not hidden behind an
  account.
- [ ] No background Railway/Supabase/Civitas-cloud request occurs.
- [ ] Telemetry and automatic updates are off.
- [ ] Local API auth is on and a random key is protected by the OS vault.
- [ ] Keychain/Credential Manager denial fails closed without overwriting
  existing settings or credentials.

## 3. Capture visibility and consent

- [ ] Tray/menu-bar icon appears and accurately distinguishes capturing,
  paused, private, stopped, and degraded.
- [ ] One-click pause stops all selected capture modalities.
- [ ] Pause 15 minutes, one hour, until tomorrow, and until manual resume
  behave exactly as labeled.
- [ ] Timed pause survives restart and resumes once, at the expected time.
- [ ] Indefinite pause/Private mode survives restart and never auto-resumes.
- [ ] Resume is explicit and the tray updates immediately.
- [ ] Screen lock stops screen capture and audio unless the user explicitly
  enabled record-while-locked.
- [ ] Sleep/wake and fast user switching do not create hidden capture tasks.
- [ ] Plug/unplug monitors and audio devices does not duplicate or orphan
  capture workers.
- [ ] App quit closes capture streams, database writers, and local listeners.

## 4. Privacy defaults and exclusions

On a new profile:

- [ ] Clipboard rows/content are not persisted.
- [ ] Raw keyboard/typed-text rows are not persisted.
- [ ] Incognito/private browser windows are excluded.
- [ ] Known DRM and remote-desktop surfaces pause screen capture.
- [ ] Audio is not recorded while the screen is locked.
- [ ] Telemetry consent is absent/off.
- [ ] Auto-update is off.

Exclusion tests:

- [ ] Ignored application matches stop OCR, accessibility, frames, and
  downstream derivation for that surface.
- [ ] Included-app allowlist excludes everything else.
- [ ] Window-title and URL patterns apply before persistence where supported.
- [ ] Multiple monitors respect the selected monitor set.
- [ ] Per-device audio selection excludes unselected devices.
- [ ] Work-hour schedules handle midnight, DST, timezone changes, missed wake,
  and invalid ranges.
- [ ] Changing exclusions while capturing takes effect as documented.
- [ ] A deleted source cannot remain as an unexplained graph fact or Next
  Action.

## 5. Local API security

- [ ] Engine listens on `127.0.0.1` only; no `0.0.0.0`, LAN, IPv6 wildcard, or
  mDNS listener/advertisement exists.
- [ ] Unauthenticated HTTP and websocket requests fail when auth is enabled.
- [ ] Exact localhost/127.0.0.1/`::1` origins work; lookalike, null, file,
  arbitrary extension, and remote origins fail.
- [ ] Invalid Host headers fail.
- [ ] Websocket authentication does not put the key in a query string/log.
- [ ] Regenerating the key invalidates old clients and updates authorized local
  app flows.
- [ ] Oversized JSON, media, websocket, and concurrency requests are bounded.
- [ ] Pipe tokens cannot call routes outside their method/path scope.
- [ ] Error responses to workflows do not disclose filesystem paths, secrets,
  or raw provider messages.

## 6. AI provider profiles

Run each remote test with a dedicated low-privilege test credential and
synthetic prompt.

For every profile:

- [ ] Destination host and data-boundary sentence are visible before save.
- [ ] A remote profile cannot activate without acknowledgement.
- [ ] Credential is present only during submit; list/edit never returns it.
- [ ] UI displays only kind/presence/four-character suffix.
- [ ] Vault unavailable/denied causes save to fail with no plaintext fallback.
- [ ] Save, replace/rotate, test, activate, and delete work.
- [ ] Provider type change requires credential re-entry.
- [ ] Diagnostic uses only `Reply with OK.` and bounded output.
- [ ] Diagnostic messages do not echo credential, prompt, account IDs, or
  unbounded provider bodies.
- [ ] Redirects are rejected.
- [ ] Request audit stores purpose/profile/host/byte count/status/time, not
  prompt/evidence.

Endpoint policy:

- [ ] Local provider accepts only `localhost`, `127.0.0.1`, or `::1`.
- [ ] OpenAI accepts only HTTPS `api.openai.com`.
- [ ] Anthropic accepts only HTTPS `api.anthropic.com`.
- [ ] OpenRouter accepts only HTTPS `openrouter.ai`.
- [ ] Bedrock accepts only the selected region's runtime host and valid region
  syntax.
- [ ] Compatible remote endpoint requires HTTPS; loopback may use HTTP.
- [ ] URL username/password, query, fragment, malformed/punycode lookalike, and
  official-host suffix attacks fail.

Contract tests:

- [ ] OpenAI/OpenRouter/compatible/local streaming preserves status/content
  type and strips unsafe upstream headers.
- [ ] Anthropic and Bedrock buffered responses normalize usage and content.
- [ ] Unsupported tools/embedding/model-list capability fails clearly rather
  than silently changing provider.
- [ ] Cancellation/timeouts stop local work and do not leave a stuck request.
- [ ] Rate limit, insufficient quota, invalid model, auth, region, and transport
  errors produce actionable provider-neutral copy.

## 7. Network boundary

Capture packets for a fresh install and a strict local session.

- [ ] Fresh launch makes no analytics, crash-upload, update, remote-provider,
  remote-sync, or third-party connection request.
- [ ] Required model downloads are user-visible and match documented
  source/license/hash behavior.
- [ ] Enabling product analytics sends only the fail-closed allowlisted schema.
- [ ] Disabling product analytics stops PostHog on restart.
- [ ] A synthetic native panic writes a local diagnostic and makes no network
  request.
- [ ] Enabling Auto-update contacts only the configured GitHub endpoint and
  disabling it stops background checks.
- [ ] Manual update check is one-shot.
- [ ] `CIVITAS_NETWORK_MODE=deny` blocks remote inference, product analytics,
  model downloads, and updater checks while loopback inference works; native
  crash diagnostics remain local.
- [ ] Remote provider request goes only to its displayed/pinned host.
- [ ] Every enabled connection contacts only its declared destination.
- [ ] Documentation matches packet-capture observations.

For high-assurance no-egress claims, also enforce an OS firewall rule. The
application environment flag alone is not an OS sandbox.

## 8. Search, timeline, meetings, and graph

- [ ] Recent local frame appears promptly with correct app/window/time/monitor.
- [ ] OCR and accessibility-only text are searchable.
- [ ] Audio transcript search distinguishes input/system devices.
- [ ] Time, app, content type, and pagination filters are stable and bounded.
- [ ] Search facets return normalized hostnames without browser paths, query
  strings, or fragments; local-calendar dates remain correct across UTC
  offsets and daylight-saving transitions.
- [ ] Project, person, evidence-type, tag, and speaker facets show explicit
  loading, empty, error, and retry states without claiming an empty library
  after a failed request.
- [ ] Saved queries round-trip query, content scope, app, hostname, local date,
  and tags from SQLite; rename waits for a successful write and deletion
  requires confirmation.
- [ ] Saved queries survive restart and age-based retention, appear in a
  portable export, and are removed by individual deletion or full local wipe.
- [ ] Unauthenticated, scoped workflow, MCP, and agent credentials cannot read
  facets or saved queries.
- [ ] Timeline keyboard navigation, zoom, multi-monitor context, deep links,
  and source preview work without disappearing frames.
- [ ] Search never exposes media through an unauthenticated URL.
- [ ] Meeting detection avoids duplicate transitions and suppresses false
  positives from browser chrome/title fragments.
- [ ] Manual meeting start/stop and meeting-bound HD capture terminate safely.
- [ ] Note/export preserves timestamps and source references.

Run the typed local-search contract and saved-query interaction regressions
with synthetic data:

```bash
cargo test --locked -p civitas-db --test consumer_search_test
cargo test --locked -p civitas-engine --test consumer_search_test

cd apps/civitas-app-tauri
bunx vitest run components/rewind/saved-query-controls.test.tsx \
  --config vitest.config.ts
```

Graph quality:

- [ ] Every visible claim/decision/procedure/blocker has source evidence,
  captured time, and confidence.
- [ ] Observed, inferred, user-authored, and confirmed states are distinct.
- [ ] Contradiction and supersession links are visible and consistent.
- [ ] Entity resolution handles aliases without unsafe auto-merge.
- [ ] Merge/split/rollback does not lose provenance.
- [ ] Ask distinguishes evidence, synthesis, and missing evidence.
- [ ] Ask abstains on unsupported personal-history questions.
- [ ] Captured prompt injection is quoted/treated as evidence, never followed
  as a tool instruction.

Run the public synthetic graph gate and the explicit single-threaded
performance/storage gate described in
[Local knowledge quality and performance evaluation](docs/QUALITY_EVALUATION.md):

```bash
cargo test --locked -p civitas-db --test knowledge_quality_eval \
  synthetic_graph_quality_meets_release_gates -- --exact
cargo test --locked -p civitas-db --test knowledge_quality_eval \
  synthetic_graph_latency_and_storage_meet_release_budgets \
  -- --exact --ignored --nocapture --test-threads=1
```

## 9. Next Actions

Use the synthetic evaluation corpus and adversarial fixtures.

- [ ] Explicit commitment, deadline, scheduled preparation, routine,
  saved-query follow-up, changed blocker, decision follow-up, open thread, and
  work-graph generators work; open threads and decision follow-ups surface
  with no AI provider configured.
- [ ] A deadline or preparation saved more than 45 days ahead surfaces when it
  becomes due (freshness follows the anchor, not the authoring time).
- [ ] Open threads require at least two captured sessions, three actions, a
  two-hour span, and a last touch between 2 and 72 hours ago; an artifact
  without an honest label is rejected, not guessed.
- [ ] Decision follow-ups require a transcript-attributed decision (or a
  screen-sourced one with a verbatim rationale), a resolvable moment, and no
  later state for the subject; a later state removes the card.
- [ ] `done` with `completesMemoryId` appends the `done` tag to the user's
  memory in the same transaction and rejects any non-commitment memory;
  `DELETE /next-actions/feedback/{id}` reverts exactly one row and reopens the
  memory it completed.
- [ ] Evidence validator rejects missing, deleted, expired, ambiguous,
  contradicted, and privacy-zone sources.
- [ ] Deduplication collapses semantic repeats without combining unrelated
  people/projects.
- [ ] Ranker is deterministic for identical inputs.
- [ ] Rank explanation includes evidence strength, recency, confidence,
  ambiguity, and penalties.
- [ ] Sensitive/high-risk categories are suppressed or require explicit
  review; no medical/legal/financial certainty is implied.
- [ ] Cards show action, reason, evidence, age, confidence, and safety state.
- [ ] Done, Later, Helpful, and Dismiss persist locally and affect
  cooldown/ranking; Done, Later, and Dismiss confirm inline with an Undo that
  works until the row collapses, and a failed save restores the card.
- [ ] The panel is pull-only: nothing is fetched until “Show next actions”, and
  the last pull is kept for the session so leaving and returning does not
  discard it.
- [ ] Refresh does not resurrect dismissed/expired suggestions improperly.
- [ ] Provider outage produces a deterministic safe fallback.
- [ ] No candidate automatically sends, edits, navigates, purchases, deletes,
  or executes a workflow.
- [ ] Precision@3, unsupported-suggestion, stale-evidence, duplicate,
  sensitive-domain, latency, and user-helpfulness gates meet the thresholds in
  `docs/publication/PUBLICATION_PLAN.md`.
- [ ] `GET /next-actions/quality` returns content-free local aggregates,
  deduplicates repeated ratings to the latest rating per candidate, reports
  `insufficient-data` below 20 ratings, and reports `passes` only at or above
  80% helpfulness.
- [ ] The quality response never includes candidate IDs, titles, evidence,
  prompts, or captured content, and ambient delivery remains disabled even
  when the pull-based helpfulness gate passes.

## 10. Workflows, connections, browser, and MCP

- [ ] Bundled workflows declare least-privilege local routes and filesystem
  roots.
- [ ] Workflow shell cannot use external curl or mixed local/remote URLs.
- [ ] Symlink/path traversal outside declared roots fails.
- [ ] Per-run token expires/revokes and cannot be reused across workflows.
- [ ] Connection proxy validates configured HTTPS host, resolved IP, method,
  path, port, redirects, body, response size, and timeout.
- [ ] Connection credentials never enter prompts, logs, UI responses, or
  workflow environment.
- [ ] Obsidian/Logseq/local-memory paths remain vault-only.
- [ ] Browser tools are absent until the explicit user-browser extension is
  connected.
- [ ] No hidden owned browser launches and no Chrome/Arc/Edge cookie database
  is read or decrypted.
- [ ] Extension manifest has no `<all_urls>`, `tabs`, `cookies`, or `debugger`
  permission and accepts only HTTP loopback hosts.
- [ ] WebSocket authentication uses the `civitas-auth.*` subprotocol and never
  a URL query credential.
- [ ] Snapshot requires active-tab invocation, stays bounded, omits every form
  value/password/hidden input, and strips URL credentials/query/fragment data.
- [ ] Unknown, arbitrary-code, cookie, hidden-tab, click, fill, and submit
  commands are unavailable at both Rust and extension boundaries.
- [ ] Every navigation rejects non-HTTPS/credential URLs, displays the exact
  destination in Civitas, and remains blocked until **Allow once**; deny,
  timeout, replay, and disconnected-extension cases fail closed.
- [ ] MCP default scope is read-only; state-changing/media tools are hidden and
  rejected without scope.
- [ ] MCP credential rotate/revoke works and raw media is unavailable by
  default.
- [ ] MCP output treats captured text as data and stays within result bounds.

The engine also runs deterministic property suites (256 generated boundary
cases per connection property and 128 per portable-data property). They cover
path traversal and encoded-separator smuggling, idempotency-key grammar,
control-character URL injection, Unicode-safe export truncation, settings
export allowlisting, and oversized settings values:

```bash
cargo test -p civitas-engine connections_api::tests:: --locked
cargo test -p civitas-engine routes::portable_data::tests:: --locked
```

Any generated failure is minimized by `proptest` and printed as a replayable
regression input. Add the minimized case to the adjacent fixed regression table
before changing the policy.

## 11. Export, retention, deletion, and recovery

- [ ] Export requires an explicit destination or the local exports directory.
- [ ] Filename sanitization, canonicalization, symlink, traversal, overwrite,
  and unsupported path tests pass.
- [ ] Workflow export cannot escape its allowed root or receive raw internal
  error paths.
- [ ] Retention handles media-only vs all-data modes, batches, restart, clock
  change, and partial failure.
- [ ] Deleting media leaves intentionally retained text/provenance in an
  understandable state.
- [ ] Deleting a source propagates through FTS, vectors, graph, suggestions,
  caches, exports index, and related derived rows.
- [ ] Delete-all stops capture/writers first, reports failed paths, and does not
  claim provider/backups/exports were deleted.
- [ ] Backup/restore uses a consistent SQLite snapshot and preserves
  encryption/vault requirements.
- [ ] Corrupt settings/DB recovery preserves the original and fails visibly.

## 12. Tauri and desktop interaction

- [ ] A clean first launch and opening Chat create no `pi-agent` directory and
  make no package-registry request.
- [ ] **Settings → AI** shows the pinned assistant package/version,
  `registry.npmjs.org`, data that leaves, local storage, and Windows Git
  prerequisite before installation.
- [ ] Assistant installation occurs only after **Install runtime**, uses the
  embedded frozen lock with lifecycle scripts disabled, and never invokes
  system npm or a global agent executable.
- [ ] **Remove runtime** requires destructive confirmation, stops active
  assistant sessions, rejects a symlinked runtime path, and preserves work
  data, conversations, provider profiles, and credentials.
- [ ] `CIVITAS_NETWORK_MODE=deny` rejects assistant installation before any
  socket opens; on Windows Civitas never downloads or runs a Git installer.
- [ ] Production CSP is explicit and rejects inline/unlisted remote content.
- [ ] Each window has only required Tauri capabilities.
- [ ] No global Tauri bridge, broad home-directory filesystem grant, arbitrary
  HTTP scope, `shell:default`, or unbounded shell interpreter exists.
- [ ] External URL helper rejects non-HTTPS, credentials, unexpected hosts, and
  dangerous schemes where the call site is allowlisted.
- [ ] Authenticated local images do not put tokens in URLs/history.
- [ ] Deep links accept only documented routes/arguments and never credentials.
- [ ] Overlay/chat appear on the active macOS Space without stealing focus from
  unrelated input or leaving ghost clicks.
- [ ] Escape, keyboard focus, screen-capture visibility, multiple monitors,
  full-screen apps, and tray/dock lifecycle remain correct.
- [ ] Live Text/VisionKit timeouts fail gracefully without deadlock.
- [ ] Windows DPI, COM/audio/video lifecycle, tray close behavior, and clean
  installer uninstall pass.

Run live macOS accessibility tests only in a dedicated synthetic-data test
user. They deliberately focus, type into, inspect, and close real apps:

```bash
cargo test -p civitas-a11y --test e2e_tree_walker -- --ignored --test-threads=1 --nocapture
cargo test -p civitas-a11y --test e2e_obsidian -- --ignored --test-threads=1 --nocapture
```

## 13. Accessibility and design quality

- [ ] Onboarding, Settings, Ask, graph, Timeline, Next Actions, provider
  diagnostics, and destructive dialogs are keyboard reachable.
- [ ] Focus order/indicators, Escape behavior, labels, descriptions, and live
  status announcements are correct.
- [ ] Text/controls meet contrast targets in light/dark/high-contrast modes.
- [ ] 200% zoom and Dynamic Type-equivalent scaling do not truncate critical
  disclosure or action controls.
- [ ] Reduced motion is honored.
- [ ] Error is not communicated by color alone.
- [ ] macOS UI uses consistent spacing, typography, materials, animation, and
  native interaction conventions without hiding privacy state.

## 14. Performance and resilience

- [ ] Cold start, first local search, p50/p95 query, memory, idle CPU, storage
  growth, and Next Actions latency meet documented budgets.
- [ ] Capture remains responsive during indexing, model load, provider timeout,
  export, and retention.
- [ ] SQLite busy/retry paths avoid corruption and unbounded queues.
- [ ] Full disk, low memory, device removal, sleep/wake, clock change, provider
  outage, malformed response, and process restart fail safely.
- [ ] Logs remain bounded, redacted, and useful without work content.

## 15. Signed release and clean-machine gate

For every artifact/architecture:

- [ ] Exact tag/version/commit confirmed.
- [ ] SHA-256 matches `SHA256SUMS`.
- [ ] GitHub provenance attestation verifies.
- [ ] Developer ID signature, hardened runtime, notarization, and stapling
  validate.
- [ ] Gatekeeper accepts the DMG and app on clean supported macOS.
- [ ] Bundle contains only expected sidecars, notices, assets, and
  architectures.
- [ ] SPDX SBOM and third-party notices are attached.
- [ ] Clean install, denied-permission launch, local-only use, BYOK setup,
  upgrade, interrupted update, rollback/recovery, and uninstall pass.
- [ ] Updater accepts the valid signature and rejects tampered, missing,
  wrong-channel, and downgrade artifacts.
- [ ] Release notes accurately disclose capture, provider, network, migration,
  and known limitations.
- [ ] Two people approve publication of the draft release.

See `docs/RELEASE_VERIFICATION.md` for commands and evidence to retain.
