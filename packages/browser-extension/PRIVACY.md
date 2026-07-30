# Privacy practices — Civitas Browser Bridge

Last updated: July 28, 2026

## Single purpose

Civitas Browser Bridge lets a user share a bounded outline of the active
browser tab with the Civitas desktop app running on the same computer. It can
also navigate that active tab to a user-approved HTTPS destination.

The extension does not provide arbitrary code execution, cookie access,
general web automation, form submission, hidden-tab access, or browsing-history
collection.

## User control

- The extension first pairs with the local desktop app using a matching code
  that must be approved in Civitas.
- Page access uses Chrome's temporary `activeTab` grant. The user invokes the
  extension on the exact tab they intend to share.
- A navigation does not run until Civitas shows the complete URL and the user
  chooses **Allow once**.
- Removing or disabling the extension revokes its browser access. The scoped
  credential can be revoked in Civitas, expires after 30 days, and can be
  replaced by pairing again.

## Permissions

| Permission | Why it is needed |
| --- | --- |
| `activeTab` | Temporary access to the active tab only after the user invokes the extension |
| `scripting` | Run the fixed snapshot function bundled in the extension package |
| `storage` | Store the loopback address, scoped browser credential, and short-lived pairing state |
| `alarms` | Wake the Manifest V3 service worker to maintain or restore the local WebSocket |
| `notifications` | Show a rate-limited reconnect notice after repeated local authentication failures |
| `http://localhost/*`, `http://127.0.0.1/*` | Pair with and connect to the local Civitas engine on a configurable port |

The extension does not request `<all_urls>`, `tabs`, `cookies`, `debugger`,
history, downloads, clipboard, web-request, identity, or native-messaging
permissions.

## Data processed

When the user shares a tab and Civitas requests a snapshot, the extension may
process:

- the page title;
- visible headings and bounded accessible labels;
- semantic element roles;
- HTTP/HTTPS link paths;
- the page's origin and path.

Before returning the snapshot, the extension:

- omits password and hidden inputs;
- never reads form-field values;
- strips URL usernames, passwords, query strings, and fragments;
- caps output count and string length.

These controls reduce exposure but do not make every visible page label
non-sensitive. Users should share only the tab necessary for the task.

## Storage and retention

The extension stores:

- the selected loopback origin;
- a scoped, revocable Civitas browser credential;
- short-lived pairing state, including a one-time delivery challenge, in
  browser session storage.

It does not persist page snapshots or navigation requests. The credential is
used as a WebSocket subprotocol header and is never added to a URL. It cannot
authorize non-browser API routes, and the pairing flow never discloses the
device-owner API key. Uninstalling the extension removes extension-managed
local storage under the browser's normal uninstall behavior.

## Network and downstream processing

The extension itself connects only to HTTP/WebSocket loopback at `localhost`
or `127.0.0.1`. It has no analytics, advertising, tracking, or remote service.

Snapshot data enters the local Civitas desktop app. If the user explicitly
runs a workflow or uses a configured remote AI provider, selected snapshot
content may then be sent by Civitas to that provider or connection. The
provider's terms, retention, billing, and data controls apply. The desktop
discloses those destinations separately in its provider and workflow UI.

See the repository
[network boundary](../../docs/NETWORK_BOUNDARY.md) and
[privacy/data boundary](../../docs/PRIVACY_AND_DATA_BOUNDARY.md).

## Sharing and sale

The extension does not sell data. It does not use or transfer user data for
advertising, creditworthiness, lending, or unrelated purposes. It does not
send data to Civitas-operated remote servers.

## Contact

Report a security issue using the repository
[security policy](../../SECURITY.md). For ordinary help, use the
[support guide](../../SUPPORT.md). Do not include page content, credentials,
or browser-profile archives in a public report.
