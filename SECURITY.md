# Security policy

## Report a vulnerability privately

Do not open a public issue containing exploit details, credentials, captured
content, personal data, or an unpatched vulnerability.

Use GitHub Private Vulnerability Reporting:

<https://github.com/civitass/civitas-desktop/security/advisories/new>

If that form is unavailable, contact a repository owner through a previously
verified private channel and ask for the current security contact. Never send
raw Civitas data until the recipient and encrypted transfer method are
verified.

Include only what is necessary:

- affected release/commit and operating system;
- impact and prerequisites;
- minimal reproduction using synthetic data;
- sanitized logs;
- suggested mitigation, if known;
- whether you believe active exploitation or credential exposure occurred.

Never test against another person's device, data, provider account, or
integration. Do not exfiltrate, retain, alter, or publicly disclose captured
data.

## Response targets

Maintainers aim to:

- acknowledge a complete private report within 3 business days;
- provide an initial severity/next-step assessment within 7 business days;
- coordinate a fix and disclosure timeline based on exploitation risk and user
  impact.

These are targets, not a service-level agreement. Active exploitation,
credential compromise, updater/signing issues, or unauthenticated capture/data
access should be marked urgent.

## Supported versions

Security fixes are provided for the latest published stable release. A report
against an older version may require reproducing on the latest release. Source
builds are community-supported and do not carry the official Developer ID
signature or updater.

Before the first stable public release, report against the current reviewed
release-candidate commit.

## Priority areas

- capture occurring without informed consent or while visibly paused/private;
- local database, media, export, or log disclosure;
- credential storage, logging, or webview exposure;
- loopback API, MCP, workflow-token, Origin, or scope bypass;
- prompt injection leading to disclosure or action;
- Tauri/webview capability, CSP, path traversal, or shell escalation;
- browser-extension/session abuse;
- incomplete deletion or orphaned derived knowledge;
- update/signature/notarization/provenance bypass;
- release-pipeline or dependency compromise.

## Coordinated disclosure

Please allow time for investigation, patched artifacts, signing/notarization,
and user communication. Maintainers will credit reporters who request credit
and whose disclosure was responsible. Do not disclose a report until the
coordinated date or explicit maintainer approval.

The architecture and known residual risks are documented in
[Threat model](docs/THREAT_MODEL.md). Release authenticity checks are in
[Release verification](docs/RELEASE_VERIFICATION.md).
