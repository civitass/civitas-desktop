# Model and capability catalog

Civitas stores exact provider model IDs rather than maintaining a frozen list
of marketing names. Provider catalogs, aliases, availability, and pricing
change frequently; the provider's model-list endpoint is authoritative when
the adapter supports it.

The table below is the adapter contract implemented by this repository. It does
not claim that every model offered by a provider supports every advertised
adapter capability.

| Provider adapter    | Stream | Tools | Structured output | Vision | Audio | Embeddings | Model list |
| ------------------- | -----: | ----: | ----------------: | -----: | ----: | ---------: | ---------: |
| OpenAI              |    Yes |   Yes |               Yes |    Yes |   Yes |        Yes |        Yes |
| OpenRouter          |    Yes |   Yes |               Yes |     No |    No |        Yes |        Yes |
| Compatible endpoint |    Yes |   Yes |               Yes |     No |    No |        Yes |        Yes |
| Local loopback      |    Yes |    No |               Yes |     No |    No |        Yes |        Yes |
| Anthropic           |    Yes |   Yes |               Yes |     No |    No |         No |        Yes |
| Amazon Bedrock      |    Yes |   Yes |                No |     No |    No |         No | Yes¹ |

“Yes” means the Civitas adapter exposes the capability. A selected model can
still reject it. “No” means Civitas must not silently depend on that capability
for the profile. Anthropic and Bedrock may offer vision models, but the current
Civitas translation adapters do not yet translate OpenAI-style image blocks
into those providers' native image contracts, so they deliberately report
vision as unavailable.

¹ Bedrock foundation-model discovery is currently available with a short-term
Bedrock API key through the regional control-plane endpoint. Signed AWS
profiles/access keys and inference-profile IDs use exact manual IDs verified by
invocation. A discovered `responseStreamingSupported` value is provider
reported; Bedrock's catalog does not prove tool support.

Every returned model includes a capability descriptor using registry version
1. Each feature is `supported`, `unsupported`, or `unknown`; Civitas never
turns an absent provider field into a support claim. Maximum context is
included only when the provider's model-list response reports it. An unknown
context limit remains `null` and must be checked in provider documentation or
with a synthetic account-specific test.

## Selecting models

Use the exact ID shown by the provider account or local server. Avoid copying a
model name from a blog post or another region. After selection:

1. refresh the model list when available;
2. save the profile;
3. review and run the fixed capability diagnostic;
4. exercise the intended role with synthetic content before using personal
   evidence.

For Bedrock, distinguish a foundation-model ID from an inference-profile ID.
The regional catalog can return `anthropic.claude-sonnet-4-6`, while a US
cross-region invocation uses `us.anthropic.claude-sonnet-4-6`. Both are exact
IDs, not interchangeable aliases. The region, account entitlement, IAM policy,
credential lifetime, and selected ID must all agree; a successful catalog row
does not by itself prove that a cross-region profile can be invoked.

The diagnostic reports separate rows for endpoint policy, DNS, TLS,
authentication, model list/access, fixed text inference, structured output,
tool calling, and streaming. Structured output, tools, and streaming are
tested only when the adapter/model descriptor does not report them as
unsupported. Those optional capability failures do not disguise a working
basic text profile, but the row remains failed and should block any feature
that depends on it.

The test uses no personal data. It sends up to four fixed requests, each capped
at eight output tokens. A passing row verifies the observed wire contract for
the selected endpoint, credential, and model at that time; it does not prove
price, latency, privacy terms, model quality, or an unreported context limit.
Every provider test and model-list request has a durable local metadata-only
audit row. If the audit cannot start, no provider request is sent. If the audit
cannot be completed, provider results are withheld.

## Role requirements

### Chat and Ask

The model must accept a chat-style request and produce grounded text. Anthropic
Messages SSE and Bedrock ConverseStream are translated from their native event
lifecycles into the provider-neutral stream contract, including text, tool
argument deltas, and stop reasons. The local gateway finishes its metadata-only
audit before releasing a successful response, so a valid normalized event body
may be released after bounded local buffering rather than token by token. This
is audit gating, not a fabricated one-event stream.

### Knowledge extraction

Extraction benefits from reliable structured output, low-temperature
instruction following, and enough context for the evidence window. If native
schema enforcement is unavailable, Civitas may request JSON in the system
instruction and must validate the result before persisting it. Invalid or
unsupported output must be rejected rather than converted into an
unattributed fact.

### Embeddings

The embedding role requires the provider adapter and chosen model to expose an
embedding endpoint. Anthropic and Bedrock profiles currently do not. Use a
separate local or compatible embedding profile where the feature supports
separate roles.

Vector dimensions are model-specific. Changing an embedding model can require
re-indexing; do not compare vectors produced by different models as if they
shared a space.

### Vision and audio

An adapter capability does not mean captured media is sent automatically.
Media egress requires the feature to select it and the user-visible provider
boundary to permit it. Prefer local OCR and transcription when raw work media
does not need to leave the device.

## Default local profile

The initial local profile uses:

- chat and extraction: `llama3.2:3b`;
- embeddings: `nomic-embed-text`;
- endpoint: `http://127.0.0.1:11434/v1`.

These are practical defaults, not quality promises. Users can replace them
with compatible local models. Model weights are not bundled in the DMG; review
the publisher, license, size, and source before download.

## Local speech model downloads

No speech, voice-activity, or speaker model is embedded in the source tree or
DMG. Enabling audio and choosing a local transcription engine opens a
pre-download disclosure with the publisher, approximate size, immutable source
revision, material license, and cache location. Cancel leaves audio disabled or
keeps the prior engine. A model request contains no recording or transcript.
With `CIVITAS_NETWORK_MODE=deny`, Civitas will use only already cached,
digest-verified model files and will fail closed instead of downloading a
missing file.

The official consumer build uses the following content-pinned inputs:

| Capability                      | Publisher / conversion                                         | Immutable source                                                               |                 Approximate download | License         | Local cache                     |
| ------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------ | -----------------------------------: | --------------- | ------------------------------- |
| Whisper Tiny / Large v3 / Turbo | OpenAI / whisper.cpp                                           | `ggerganov/whisper.cpp@5359861c739e955e79d9a303bcbc70fb988958b1`               | 44 MB–3.10 GB, selected variant only | MIT             | Hugging Face cache              |
| Parakeet TDT 0.6B v3, ONNX INT8 | NVIDIA / istupakov                                             | `istupakov/parakeet-tdt-0.6b-v3-onnx@8f23f0c03c8761650bdb5b40aaf3e40d2c15f1ce` |                               671 MB | CC BY 4.0       | OS cache under `civitas/models` |
| Qwen3-ASR 0.6B                  | Qwen                                                           | `Qwen/Qwen3-ASR-0.6B@5eb144179a02acc5e5ba31e748d22b0cf3e303b0`                 |                              1.89 GB | Apache-2.0      | OS cache under `civitas/models` |
| Silero VAD v5                   | Silero                                                         | `snakers4/silero-vad@76e3dc408eb2a5c655c34e230d2d5459b4439daa`                 |                               2.4 MB | MIT             | OS cache under `civitas/vad`    |
| Segmentation 3.0 ONNX           | pyannote.audio; mirrored from the last MIT Screenpipe baseline | `screenpipe/screenpipe@892199f742e46d0c5d9e8c06687b35ca7c2b6547`               |                               6.0 MB | MIT             | OS cache under `civitas/models` |
| WeSpeaker CAM++ ONNX            | WeSpeaker; mirrored from the last MIT Screenpipe baseline      | `screenpipe/screenpipe@892199f742e46d0c5d9e8c06687b35ca7c2b6547`               |                              29.3 MB | CC BY 4.0 model | OS cache under `civitas/models` |

Parakeet MLX is an optional source-build feature, not part of the default
consumer DMG. It will load only when a pre-existing Hugging Face cache contains
the exact expected files for
`mlx-community/parakeet-tdt-0.6b-v3@ed2b7e8c15f9aaa0b5772e2efb986255eaef7e15`;
Civitas does not start an unverified MLX download.

### Speech model integrity

Every file is checked before loading. These digests are release inputs:

- Whisper:
  - `ggml-tiny.bin` — `be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21`
  - `ggml-tiny-q8_0.bin` — `c2085835d3f50733e2ff6e4b41ae8a2b8d8110461e18821b09a15c40c42d1cca`
  - `ggml-large-v3.bin` — `64d182b440b98d5203c4f9bd541544d84c605196c4f7b845dfa11fb23594d1e2`
  - `ggml-large-v3-q5_0.bin` — `d75795ecff3f83b5faa89d1900604ad8c780abd5739fae406de19f23ecd98ad1`
  - `ggml-large-v3-turbo.bin` — `1fc70f774d38eb169993ac391eea357ef47c88757ef72ee5943879b7e8e2bc69`
  - `ggml-large-v3-turbo-q8_0.bin` — `317eb69c11673c9de1e1f0d459b253999804ec71ac4c23c17ecf5fbe24e259a1`
- Parakeet ONNX:
  - `encoder-model.int8.onnx` — `6139d2fa7e1b086097b277c7149725edbab89cc7c7ae64b23c741be4055aff09`
  - `decoder_joint-model.int8.onnx` — `eea7483ee3d1a30375daedc8ed83e3960c91b098812127a0d99d1c8977667a70`
  - `vocab.txt` — `d58544679ea4bc6ac563d1f545eb7d474bd6cfa467f0a6e2c1dc1c7d37e3c35d`
- Qwen3-ASR:
  - `model.safetensors` — `79d6cbd4c98c7bbffe9db2edac07f56cd6637d0d5944b27f6c2b8353840323ea`
  - `config.json` — `76d3ae4601ce939830b2517f4a6cadb86cc51316c3900af6b020b051c21a478c`
  - `vocab.json` — `ca10d7e9fb3ed18575dd1e277a2579c16d108e32f27439684afa0e10b1440910`
  - `merges.txt` — `8831e4f1a044471340f7c0a83d7bd71306a5b867e95fd870f74d0c5308a904d5`
- Silero VAD — `1a153a22f4509e292a94e67d6f9b85e8deb25b4988682b7e174c65279d8788e3`
- pyannote Segmentation — `b78fc48113bb46fd247ae6a9aea737079550c647638db961df7e0e1e9f4ba62e`
- WeSpeaker CAM++ — `c46fad10b5f81e1aa4a60c162714208577093655076c5450f8c469e522ec54ef`

A size or digest mismatch deletes the candidate file and fails closed. Changing
one byte requires a reviewed code, catalog, notice, and release-evidence
update.

## Local privacy-redaction downloads

Smart PII is optional and disabled until the user accepts the separate
non-commercial model license. Its weights are not bundled:

| Capability                      | Immutable source                                                         |                          Approximate download | License      | SHA-256                                                            |
| ------------------------------- | ------------------------------------------------------------------------ | --------------------------------------------: | ------------ | ------------------------------------------------------------------ |
| Text PII redaction v45 phase 5  | `screenpipe/pii-redactor@5c907008e2a2ad394712496a26819ad28dd44662`       | 167 MB across model, tokenizer, config, remap | CC BY-NC 4.0 | Per-file constants in `crates/civitas-redact/src/adapters/onnx.rs` |
| Image PII redaction RF-DETR v12 | `screenpipe/pii-image-redactor@d4bb93370fc3fe3c36007bef22f71bd0e97a0951` |                                       54.4 MB | CC BY-NC 4.0 | `71cd7d976ef769255a8d5b7523ecdd547710cc18f8464e0cc9da64c4e8c1aaba` |

Commercial use of these optional Smart PII weights requires separately
licensed weights. Civitas' MIT source license does not override a model
license.

## Quality rules

- Personal-history answers must cite local evidence and abstain when evidence
  is missing.
- Captured text is untrusted data, not an instruction to the model or tools.
- A provider response cannot authorize an external action.
- Next Actions never auto-executes and must expose its evidence, uncertainty,
  and safety state.
- Model/provider changes should be recorded with evaluation results so quality
  regressions are distinguishable from retrieval regressions.

## Catalog maintenance

Do not commit API keys or provider account exports when updating this document.
When an adapter capability changes, update:

- the Rust `ProviderCapabilities` contract and tests;
- the Settings capability display;
- this table;
- provider contract tests;
- the network and privacy documentation if a new endpoint or data class is
  introduced.

Model aliases and prices belong in provider documentation rather than this
repository unless they are pinned release inputs.
