# Bring your own AI provider

Civitas can run its AI work against a loopback model server or directly against
an account you control at OpenAI, Anthropic, OpenRouter, or Amazon Bedrock.
Civitas does not include API credits, and a ChatGPT or Claude consumer
subscription is not an API credential.

Capture, media, SQLite search, the knowledge graph, and exports remain local.
When a remote profile is active, the evidence selected for an AI request leaves
the computer and is governed by that provider's terms, retention settings, and
charges.

## Safe setup flow

1. Open **Settings → Privacy → Network boundary**.
2. Review the global disclosure and choose **Allow remote features**. This
   changes permission only; it does not send data or create a provider.
3. Open **Settings → AI** and choose a provider.
4. Read the provider-specific data-boundary sentence and verify the exact destination
   host.
5. Enter the exact model ID enabled for your account.
6. Enter a credential only in the credential field.
7. Check the provider-specific boundary acknowledgement.
8. Leave **Keep this credential only until Civitas quits** off for protected
   persistent storage. Turn it on only when you deliberately want a temporary
   process-memory credential.
9. Save the profile.
10. Run **Test**. Review and approve the pre-send sheet, which shows the exact
   destination, provider, model, credential mode, likely billing owner, and the
   fixed capability probes. Civitas sends up to four non-sensitive requests
   (basic text, JSON, tools, and streaming when applicable), each capped at
   eight output tokens.

The credential is submitted to Rust for the save or test operation. It is
never returned to the webview. By default it is stored as an encrypted local
secret whose encryption key is held by the operating-system credential vault.
Profile listings show only whether a credential exists, its storage mode and
kind, and at most a four-character suffix.

If the OS credential vault is unavailable, denied, or cannot protect the
credential, persistent saving fails closed. The explicit session-only option
keeps the credential only in Civitas process memory, never writes it to disk,
and clears it when Civitas quits. The non-secret profile metadata remains
local, so the credential must be re-entered after every restart. There is no
plaintext or base64 fallback.

Persistent profile metadata and its protected credential are committed in one
local database transaction. A failed vault or database write therefore cannot
leave a profile claiming that a credential was saved when it was not, or leave
an orphaned credential after a failed deletion.

Provider requests use a metadata-only local audit containing purpose, data
classes, source count, byte/token estimates, redaction state, exact profile and
host, timeout, no-retry policy, and deadline cancellation policy. It never
stores prompts, evidence, responses, or credentials. A failed audit start
blocks provider egress. A failed audit completion withholds the provider
response.

On first launch after upgrading from the legacy settings format, **Settings →
AI** shows a local migration receipt. It identifies which profile IDs were
retained, require credential re-entry, require a fresh remote-data boundary
confirmation, or were skipped. The receipt never contains credential values.
Imported remote profiles remain inactive until their boundary is confirmed and
their credential is available.

## Local only: Ollama or compatible loopback server

The default profile is:

- endpoint: `http://127.0.0.1:11434/v1`;
- chat/extraction model: `llama3.2:3b`;
- embedding model: `nomic-embed-text`.

Install and start Ollama separately, then make the configured models available:

```bash
ollama pull llama3.2:3b
ollama pull nomic-embed-text
ollama serve
```

You may select other model IDs supported by your local server. A local profile
is restricted to `localhost`, `127.0.0.1`, or `::1`; it cannot be repointed to
another machine under the “Local only” label.

Fresh and migrated consumer installs default to the durable **Local-only**
network boundary. It blocks every reviewed non-loopback feature, not just AI.
For an additional launch-time override:

```bash
CIVITAS_NETWORK_MODE=deny civitas record --use-all-monitors
```

This override blocks remote inference and transcription, connection and ICS
traffic, workflow proxy egress, remote HTTP MCP, stdio MCP subprocesses,
optional analytics, model downloads, assistant-runtime installation, and
updater checks in the reviewed paths. Loopback providers remain usable. Crash
diagnostics are already local-only and are never uploaded automatically.
Local-only is an application guardrail, not an operating-system firewall; use
an OS firewall or isolated network when an independent no-egress guarantee is
required.

The standalone CLI starts local-only even without the environment override.
Each capture class also starts off: use `--use-all-monitors` or `--monitor-id`
for screen capture, `--capture-microphone` and/or
`--capture-system-audio` for audio, and the separately disclosed
`--capture-typed-text` or `--capture-clipboard-content` flags only when those
records are wanted. Remote providers and artifact downloads additionally
require the process-level `--allow-remote` acknowledgement.

## OpenAI API

1. Create or select an OpenAI API project.
2. Create a project API key at
   <https://platform.openai.com/api-keys>.
3. In Civitas select **OpenAI API**.
4. The endpoint is pinned to `https://api.openai.com/v1` and is not editable.
5. Refresh the model list, or enter an exact model ID available to the project.
6. Paste the key, acknowledge that selected evidence is sent to
   `api.openai.com`, save, and test.

Use an API key with the least privileges and budget appropriate for the
project. Configure provider-side usage limits and rotate the key if it is ever
placed in a screenshot, log, issue, or shell history.

## Anthropic Claude API

1. Create an Anthropic API key at
   <https://console.anthropic.com/settings/keys>.
2. In Civitas select **Anthropic**.
3. The endpoint is pinned to `https://api.anthropic.com`.
4. Refresh the model list or enter the exact Claude model ID enabled for the
   account.
5. Paste the key, acknowledge the boundary, save, and test.

The adapter translates system turns, text blocks, tool definitions, named and
required tool choices, tool-use results, and JSON-schema output requests to the
native Messages contract. It normalizes native text/tool responses, stop
reasons, usage, and Anthropic SSE deltas back into Civitas' provider-neutral
format. The local gateway may hold the bounded normalized SSE body until its
metadata-only audit is durably complete; it never replaces a native stream
with a fabricated one-event success. Run the JSON, tool, and streaming
diagnostic rows for the exact Claude model because model support remains an
observed, account-specific fact.

Protocol references:

- [Anthropic Messages streaming](https://platform.claude.com/docs/en/build-with-claude/streaming)
- [Anthropic tool definitions](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools)
- [Anthropic structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)

## OpenRouter

1. Create an OpenRouter API key at <https://openrouter.ai/settings/keys>.
2. Select **OpenRouter** in Civitas.
3. The endpoint is pinned to `https://openrouter.ai/api/v1`.
4. Refresh models and choose the exact routed model ID.
5. Review the upstream provider and data policy associated with that model.
6. Paste the key, acknowledge that OpenRouter may route selected evidence to
   the chosen upstream provider, save, and test.

Provider routing, pricing, logging, and availability can change independently
of Civitas. Recheck the selected model's OpenRouter policy before using
sensitive work context.

## Amazon Bedrock

1. Enable model access in the AWS account and region you intend to use.
2. Apply least-privilege IAM permissions. Invocation uses
   `bedrock:InvokeModel`; streaming also needs
   `bedrock:InvokeModelWithResponseStream`. API-key catalog discovery uses
   `bedrock:ListFoundationModels`.
3. Select **Amazon Bedrock** and enter the region and exact model or inference
   profile ID.
4. Choose one authentication method:
   - a Bedrock short-term API key;
   - a named AWS profile already configured on the computer;
   - an access key ID and secret access key, with an optional session token for
     temporary AWS credentials.
5. Confirm the generated host
   `bedrock-runtime.<region>.amazonaws.com`.
6. Acknowledge the boundary, save, and test.

Bedrock distinguishes a foundation-model ID from a cross-region inference
profile ID. Use the exact value enabled for the selected region. For example,
Claude Sonnet 4.6 uses the foundation-model ID
`anthropic.claude-sonnet-4-6`; a US cross-region profile uses
`us.anthropic.claude-sonnet-4-6`. Do not append a version suffix copied from a
different Claude generation, and do not substitute a display name. **Find
models** lists foundation models; inference-profile IDs remain manual entries
and are verified by the fixed invocation test.

Long-lived AWS access keys are discouraged. Prefer a named profile backed by
short-lived credentials or a Bedrock short-term key. Civitas validates region
syntax and pins the runtime host to the selected region. With a short-term
Bedrock API key, **Find models** makes a metadata-only request to
`bedrock.<region>.amazonaws.com`; it sends the protected credential but no
question or evidence. The control-plane response can prove a foundation model's
streaming flag and modalities, but does not prove tool or structured-output
support. Inference-profile IDs remain exact manual entries.

Signed access-key and named-profile modes use the official AWS SDK and do not
implement SigV4 in Civitas. Every SDK HTTP request—including SSO, STS, and role
credential exchanges—passes the current local-only/remote-enabled network
policy. This blocks EC2 instance-metadata access because it is non-loopback
plain HTTP. A named profile can still run a locally configured
`credential_process`; selecting that advanced mode is permission to use the
profile's own AWS authentication configuration. The UI discloses this before
saving. Signed modes currently verify an exact model or inference-profile ID by
invocation rather than listing the Bedrock control plane.

Converse text, tool-use/tool-result blocks, tool choice, stop reasons, and
native ConverseStream events are normalized for both Bedrock API-key and signed
SDK modes. Structured-output enforcement remains unadvertised because support
and wire behavior vary by Bedrock model; Civitas uses a schema instruction and
validates returned JSON instead of claiming native enforcement.

Protocol references:

- [Bedrock Converse and ConverseStream](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html)
- [Bedrock tool use](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html)
- [Bedrock API-key authentication](https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys-use.html)
- [Bedrock foundation-model catalog](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_ListFoundationModels.html)
- [AWS SDK credential-provider chain](https://docs.aws.amazon.com/sdk-for-rust/latest/dg/credproviders.html)

## Compatible endpoint

This advanced option accepts an OpenAI-compatible endpoint.

- Non-loopback endpoints must use HTTPS.
- Loopback endpoints may use HTTP.
- Credentials in URL user-info, query strings, or fragments are rejected.
- Redirects are disabled.
- Civitas displays the exact host in the boundary acknowledgement.

Only use a server you trust. “OpenAI-compatible” describes the wire shape, not
the operator, privacy policy, model quality, or safety of the service.

## Models and roles

Each profile can specify:

- **Chat model** for Ask and interactive generation;
- **Extraction model** for structured knowledge and candidate synthesis;
- **Embedding model** for semantic vectors when the provider supports them.

Using one model for all roles is valid only when it supports all required
capabilities. The UI distinguishes adapter support from versioned
provider-reported model facts. Model capabilities are tri-state
(`supported`/`unsupported`/`unknown`), and maximum context is shown only when
the provider reports it. The current matrix and limitations are in
`docs/MODEL_CATALOG.md`.

## Rotation, replacement, and deletion

- To rotate a key, edit the profile, enter the replacement, save, and rerun the
  diagnostic before revoking the old key.
- Changing between OS-vault and session-only storage requires re-entering the
  credential; Civitas never copies it silently between storage modes.
- Changing provider type requires re-entering a credential.
- Deleting a profile deletes its encrypted or in-memory credential and profile
  metadata even if the vault is currently locked. It does not revoke the
  credential at the provider; revoke it in the provider console too.
- Never paste a credential into Ask, captured notes, a workflow prompt, a bug
  report, or a screenshot.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Vault unavailable or access denied | Unlock the login keychain or OS credential manager and retry. If you need a temporary session, explicitly select session-only storage; never use a plaintext workaround. |
| DNS row fails | Endpoint spelling, DNS, VPN, or managed-network resolver. No inference probes are sent after this failure. |
| TLS row fails | Official HTTPS host, system time, certificate trust, or TLS-inspection policy. Loopback HTTP correctly shows “not applicable.” |
| Authentication row fails | Credential validity, project/account permissions, AWS IAM, and provider billing. Replace the credential explicitly. |
| Chat says the provider refused a model or credential, but the profile diagnostic passes | Restart Civitas so a fresh assistant process receives the current authenticated loopback credential. This is a local assistant-to-gateway handshake, not evidence that the remote key is invalid. If it persists, open **Settings → AI**, confirm the assistant runtime is healthy, and run diagnostics before rotating a provider credential. |
| Local assistant authentication fails | Restart Civitas. The assistant receives its loopback bearer through the child-process environment at spawn and must never be given the device-owner API key manually. If a restart does not recover it, remove and reinstall only the optional runtime from **Settings → AI**; this does not delete work data or provider profiles. |
| Model list/access row fails | Exact model ID, region, list permission, and model entitlement. A Bedrock short-term API key can list foundation models through the regional control plane; signed modes and inference-profile IDs are verified by invocation. |
| Fixed inference fails | Endpoint contract, exact model ID, region, quota, and basic chat compatibility. |
| Bedrock streaming fails | Confirm `bedrock:InvokeModelWithResponseStream`, the exact region, and that the selected model reports streaming support. Basic Converse may still work. |
| JSON/tools/streaming row fails | The basic profile may still work, but do not assign it to a feature requiring that failed optional capability. Tool and structured-output support are model-specific even when the adapter can translate the contract. |
| Audit unavailable | Local SQLite must be writable. Civitas serializes these short audit writes and reconciles interrupted rows on the next request; it still blocks egress or withholds the result instead of producing an unaudited provider exchange. Check free disk space and local-data-directory permissions, then retry. |
| Remote profile blocked | Enable remote features in **Settings → Privacy**. If `CIVITAS_NETWORK_MODE=deny` is set, remove it and restart; the environment override cannot be weakened in the UI. |
| Local server unreachable | Start the server and confirm its `/v1/models` or compatible endpoint on loopback. |
| Profile saves but cannot activate | Complete the boundary acknowledgement and ensure its protected or current-session credential is available. |

Sanitize logs before sharing them. Civitas intentionally turns provider errors
into bounded messages, but upstream tooling or shell output can still contain
account identifiers.
