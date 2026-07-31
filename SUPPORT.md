# Support

Civitas Desktop is a local-first open-source application. Community support
can help with installation, configuration, reproducible bugs, and development,
but maintainers cannot inspect your computer, recover deleted local data,
provide provider credits, or guarantee a response time.

## Before asking

1. Read [BUILDING.md](docs/BUILDING.md), [BYOK.md](docs/BYOK.md), and the
   [privacy boundary](docs/PRIVACY_AND_DATA_BOUNDARY.md).
2. Search existing issues.
3. Reproduce on the latest release or current `main`.
4. Reduce the problem to synthetic data and the smallest relevant settings.

Use the structured GitHub issue forms for bugs, documentation, feature
requests, or focused questions.

## macOS Screen Recording access

macOS grants Screen Recording to an exact app identity. Release, beta, source,
and ad-hoc builds can therefore appear as separate Civitas entries even when
one of them is already enabled.

After enabling the entry for the build that is currently open, return to
Civitas and choose **Relaunch Civitas**. ScreenCaptureKit requires a fresh
process before it can use a grant made during the current launch. Civitas keeps
this relaunch requirement across page navigation and continues to expose
existing Timeline history while new screen capture is paused.

If the app still reports missing access after the relaunch, choose **Reset &
re-request** in the recovery window, then enable the exact current entry under
**System Settings → Privacy & Security → Screen & System Audio Recording**.
The in-app permission surface shows the active bundle identifier to help
distinguish builds.

## Share the minimum

Never post:

- API keys, local API tokens, provider headers, signing material, or `.env`
  contents;
- recordings, screenshots of real work, OCR, transcripts, meetings, contacts,
  calendars, knowledge-graph exports, or databases;
- full logs, crash dumps, absolute personal paths, device identifiers, or
  provider request/response bodies.

Prefer the exact version/commit, operating system, a synthetic reproduction,
the visible error, and only the few sanitized diagnostic lines needed to
understand it. Replace names, domains, paths, IDs, and work text with invented
values. Do not assume that deleting an issue later removes it from mirrors or
notifications.

## Security and privacy incidents

Do not open a public issue for a vulnerability, unauthorized capture, exposed
credential, data disclosure, updater/signing problem, or prompt-injection
bypass. Follow [SECURITY.md](SECURITY.md) and use
[GitHub Private Vulnerability Reporting](https://github.com/civitass/civitas-desktop/security/advisories/new).

If local data may be exposed, pause capture, disconnect affected integrations,
rotate relevant provider and local API credentials, preserve minimal evidence
privately, and avoid uploading the database or raw media.

## Provider and platform boundaries

OpenAI, Anthropic, OpenRouter, Amazon Bedrock, operating-system permissions,
and third-party MCP clients are independently operated. Billing, quotas,
provider incidents, account recovery, and provider-side data handling must be
handled with that provider. Civitas does not include hosted AI credits or a
remote account service.
