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

## AI and local-service recovery

Treat the failing boundary before changing credentials:

| Visible state | Boundary | Safe recovery |
| --- | --- | --- |
| **Civitas's local assistant service is unavailable** | The optional managed assistant process did not become ready or exited | Wait once, retry, then restart Civitas. If it persists, inspect or reinstall the optional runtime in **Settings → AI**. Core capture, Timeline, search, graph, and export do not depend on it. |
| **Civitas couldn't authenticate its local assistant session** | The child process and authenticated loopback inference gateway did not agree on the process-scoped bearer credential | Restart Civitas to create a fresh child session. Do not paste the device-owner API key into any assistant file. Run provider diagnostics only if the next attempt still fails. |
| Provider authentication or model diagnostic fails | The request reached the selected remote provider and it rejected the current credential, entitlement, region, or exact model ID | Test the profile in **Settings → AI**. Check the provider account, model access, region, quota, and credential expiry; replace a key only when the provider diagnostic identifies it. |
| **Audit unavailable** | Civitas could not durably begin or finish the local metadata-only egress record | Check free disk space and permissions on the Civitas data directory, then retry. The request is blocked or its response withheld rather than sent without an audit. |
| Timeline is reconnecting while Chat also fails | The local engine is unavailable or its storage writer is under sustained pressure | Restart once, verify free disk space, then use **Settings → Storage** to review retention. If it recurs, share only sanitized status codes and timing—never the database or captured content. |

The assistant receives the current authenticated loopback credential only
through its child-process environment; Pi's configuration stores an environment
reference, never the credential value. This channel is separate from OpenAI,
Anthropic, OpenRouter, Bedrock, and MCP-client credentials. A local handshake
error must therefore not be reported as proof that a provider key is wrong.
