# Civitas Browser Bridge

An optional Manifest V3 extension that gives local Civitas a deliberately
small view of one browser tab.

The extension is not a general browser-automation or cookie-export tool. It
supports two reviewed operations:

- `snapshot`: return a bounded accessibility-style outline of the active tab
  after the user invokes the extension on that tab;
- `navigate`: change that active tab to one HTTPS URL after Civitas displays
  the exact destination and the user chooses **Allow once**.

There is no arbitrary JavaScript, remote code, cookie, hidden-tab, click,
form-fill, form-submit, download, debugger, or network-inspection operation.

## Install

The Chrome Web Store build must complete independent store review before a
listing URL can be published. Until that external step is complete, reviewers
and developers can load the reproducible package:

```bash
cd packages/browser-extension
bun install --frozen-lockfile
bun run check
```

Then:

1. Open `chrome://extensions`.
2. Enable **Developer mode**.
3. Select **Load unpacked**.
4. Choose `packages/browser-extension/dist`.
5. Open Civitas, click the extension on the tab you want to share, and approve
   the matching connection code in the desktop app.

The packaged build copies the same circular Civitas icon used by the desktop
app. Do not edit generated `dist/` files; they are intentionally untracked.

## Consent model

Connection approval and page access are separate decisions:

1. Pairing asks the desktop user to approve a six-digit matching code. The
   approval mints a narrow, revocable browser credential that expires after
   30 days. A one-time challenge binds delivery to the requesting extension
   and is never put in a URL. The device-owner API key is never disclosed.
2. Chrome's `activeTab` permission becomes available only after the user
   invokes the extension on the active tab. It expires when that tab closes or
   navigates away.
3. A snapshot can read only that temporarily shared tab.
4. Every requested navigation creates a separate desktop prompt showing the
   complete HTTPS URL. Denial and timeout fail closed.

This matches Chrome's
[`activeTab` privacy model](https://developer.chrome.com/docs/extensions/develop/concepts/activeTab)
and keeps all executable extension logic inside the submitted package, as
required by the
[Manifest V3 remote-code policy](https://developer.chrome.com/docs/webstore/program-policies/mv3-requirements/).

## Snapshot boundary

The bundled snapshot function:

- caps the outline at 220 rows and limits label lengths;
- skips hidden, presentation-only, script, style, template, password, and
  hidden-input elements;
- never reads input, textarea, or select values;
- strips usernames, passwords, query strings, and fragments from page and link
  URLs;
- returns only `title`, redacted `url`, `tree`, and `truncated`;
- runs through `chrome.scripting.executeScript` with packaged code, never a
  string received over the bridge.

Page titles, visible labels, headings, and link paths can still be sensitive.
Share only the tab needed for the task.

## Local transport

- HTTP and WebSocket destinations are restricted to `localhost` or
  `127.0.0.1`.
- The default endpoint is
  `ws://127.0.0.1:3030/connections/browser/ws`.
- The scoped browser credential is encoded in a WebSocket subprotocol header.
  It is never placed in a URL, console message, page, or request body, and
  cannot authorize non-browser API routes.
- Page content is not stored by the extension.
- The extension has no analytics or remote server.

Civitas may use snapshot text in an explicitly requested workflow or send
selected context to a remote AI provider the user configured. That downstream
boundary belongs to the desktop app and is disclosed in
[`docs/NETWORK_BOUNDARY.md`](../../docs/NETWORK_BOUNDARY.md) and
[`docs/PRIVACY_AND_DATA_BOUNDARY.md`](../../docs/PRIVACY_AND_DATA_BOUNDARY.md).

## Development

```bash
bun install --frozen-lockfile
bun run test
bun run build
bun run zip
```

`bun run build` fails when the manifest and package versions differ or when a
forbidden broad permission is present. The release workflow packages the
reviewed `dist/` directory, generates a SHA-256 checksum, and uploads a GitHub
Actions artifact. Submission and publication in the Chrome Web Store remain
separate human-reviewed actions.

## Wire protocol

Server to extension:

```json
{"id":"uuid","action":"snapshot"}
{"id":"uuid","action":"navigate","url":"https://example.com/path"}
{"type":"ping"}
```

Extension to server:

```json
{"id":"uuid","ok":true,"result":{"title":"…","url":"https://example.com/path","tree":"…","truncated":false}}
{"id":"uuid","ok":false,"error":"…"}
{"type":"pong"}
```

Unknown commands are ignored. The Rust bridge can construct only the two fixed
command variants.

## Reporting

See the repository [security policy](../../SECURITY.md) for vulnerabilities and
[support guide](../../SUPPORT.md) for private-data-safe diagnostics. Never
attach real page snapshots, browser credentials, or browser profiles to a
public issue.
