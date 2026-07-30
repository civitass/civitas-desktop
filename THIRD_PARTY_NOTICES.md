# Third-party notices

Civitas Desktop is licensed under the MIT License. It also uses third-party
software and optional model weights governed by their own licenses.

The machine-readable inventory shipped with each GitHub release is
`civitas-desktop-<version>.spdx.json`. That SBOM is generated from the exact
release commit and is the authoritative package/version inventory. The
lockfiles in this repository remain the source of truth for reproducible source
builds.

## Software bundled in official applications

### FFmpeg (macOS)

- Project: FFmpeg
- Release: `n8.1.2`
- Source commit: `38b88335f99e76ed89ff3c93f877fdefce736c13`
- Source: <https://github.com/FFmpeg/FFmpeg>
- License for the Civitas build: GNU Lesser General Public License, version 2.1
  or later
- Rebuild script: `apps/civitas-app-tauri/scripts/build_ffmpeg_macos.sh`

The Civitas release job builds FFmpeg from that exact commit with GPL, nonfree,
network, and auto-detected external components disabled. It verifies the
resulting architecture and rejects package-manager runtime dependencies. The
application bundle includes FFmpeg's `COPYING.LGPLv2.1` and a corresponding
source pointer.

Local development builds use separately distributed static FFmpeg `8.1`
(Apple Silicon) or `8.0` (Intel) binaries from
<https://www.osxexperts.net/>. Their archive and executable digests are pinned
in `apps/civitas-app-tauri/scripts/pre_build.js`; they are never used by the
protected release workflow. Those publisher builds enable GPL and version 3
components and are governed by the publisher's corresponding FFmpeg license
and source terms.

### Bun (macOS)

- Project: Bun
- Release: `1.3.10`
- Source: <https://github.com/oven-sh/bun>
- License: MIT

The macOS sidecar archives are downloaded from the versioned Bun GitHub release
and verified against the exact byte counts and SHA-256 values pinned in the
build script before being included in the application.

### Tesseract language models and output configuration (Linux bundle)

- Project: `tesseract-ocr/tessdata_best`
- Revision: `e12c65a915945e4c28e237a9b52bc4a8f39a0cec`
- Bundled baseline: `eng`, `chi_sim`, and `chi_tra`
- Source: <https://github.com/tesseract-ocr/tessdata_best>
- License: Apache License 2.0
- Configuration project: `tesseract-ocr/tessconfigs`
- Configuration revision: `3decf1c8252ba6dbeef0bf908f4b0aab7f18d113`
- Bundled configuration: `configs/tsv`
- Source: <https://github.com/tesseract-ocr/tessconfigs>
- License: Apache License 2.0

Linux AppImage builds use
`apps/civitas-app-tauri/scripts/fetch_tessdata.js` to fetch only this baseline.
The script verifies the exact byte count and SHA-512 of every model, the TSV
output configuration, and both upstream licenses before packaging. The fetched
build inputs are not committed to this repository. Debian-family installations
may use the distribution's equivalent language packages instead.

### Optional assistant runtime

- Project: `pi-mono`
- Packages: `@earendil-works/pi-coding-agent`,
  `@earendil-works/pi-agent-core`, `@earendil-works/pi-ai`, and
  `@earendil-works/pi-tui`
- Release: `0.82.1`
- Source: <https://github.com/earendil-works/pi-mono>
- License: MIT

These packages and their transitive dependencies are not fetched on first
launch. A user can explicitly install them from **Settings → AI**. The exact
dependency graph and registry integrity values are recorded in
`crates/civitas-core/assets/pi-runtime/bun.lock`; the application
embeds that lockfile and installs with dependency lifecycle scripts disabled.
The release SBOM and lockfile are the authoritative full inventory.

## Windows build and runtime dependencies

Official Windows builds stage these native components from versioned HTTPS
sources. The build fails unless each archive matches the exact byte count and
SHA-256 pinned in the workflow or build script:

- FFmpeg `8.0.1` shared build (x86-64) or the pinned 2026-07-27 ARM64
  autobuild;
- OpenBLAS `0.3.31` (x86-64 or Windows on ARM);
- ONNX Runtime `1.22.0` for the applicable CI/build target.

SSL.com CodeSignTool `1.3.2` is a signing-workflow tool and is not shipped in
the application. Scream `4.0` is used only by Windows audio integration tests
and is not shipped. Exact source URLs, hashes, and sizes are enforced by
`.github/scripts/windows/download-verified.ps1`,
`apps/civitas-app-tauri/scripts/pre_build.js`, and
`apps/civitas-app-tauri/scripts/setup_openblas.js`.

## Evaluation datasets

No evaluation audio is committed to the repository or included in release
artifacts.

The public audio evaluation workflow can fetch the fixed LibriSpeech
`test-clean` split:

- Project: LibriSpeech / OpenSLR SLR12
- Authors: Vassil Panayotov, Guoguo Chen, Daniel Povey, Sanjeev Khudanpur
- License: Creative Commons Attribution 4.0 International (CC BY 4.0)
- Publisher checksum: `32fa31d27d2e1cad72775fee3f4849a9`

The workflow verifies the exact publisher byte count and checksum, generates
temporary corpus-derived fixtures, and uploads aggregate JSON metrics only.
VoxConverse is supported solely as an optional user-supplied local benchmark;
Civitas does not automatically download or redistribute its audio. Full
dataset citations and bias/privacy notes are in
`crates/civitas-audio-eval/evals/ATTRIBUTION.md`.

## Optional model downloads

Model weights are not embedded in the DMG. Civitas downloads a model only after
the user chooses a local feature that requires it. The model setup surface must
show the model name, publisher, approximate size, source host, license, and
local deletion path before download. Current model families include:

- Whisper-compatible speech recognition weights;
- Qwen3-ASR and Parakeet speech recognition weights;
- Silero voice-activity detection;
- local text and image PII-redaction weights.

Model licenses can differ from the application license. A model whose license
or provenance cannot be resolved by the release gate must not be offered by an
official build.

### OpenAI Whisper / whisper.cpp weights

- Source: `ggerganov/whisper.cpp` model repository
- Pinned revision: `5359861c739e955e79d9a303bcbc70fb988958b1`
- License: MIT
- Copyright and attribution: OpenAI Whisper and the whisper.cpp project

Only the variant selected by the user is downloaded. Exact filenames, sizes,
and SHA-256 values are recorded in
[`docs/MODEL_CATALOG.md`](docs/MODEL_CATALOG.md).

### NVIDIA Parakeet TDT 0.6B v3

- Original model: NVIDIA Parakeet TDT 0.6B v3
- ONNX conversion: `istupakov/parakeet-tdt-0.6b-v3-onnx`
- Pinned revision: `8f23f0c03c8761650bdb5b40aaf3e40d2c15f1ce`
- License: Creative Commons Attribution 4.0 International (CC BY 4.0)

The model is attributed to NVIDIA. The conversion repository and its model card
are shown before download. Civitas verifies the selected INT8 encoder, decoder,
and vocabulary independently.

### Qwen3-ASR 0.6B

- Publisher: Qwen
- Source: `Qwen/Qwen3-ASR-0.6B`
- Pinned revision: `5eb144179a02acc5e5ba31e748d22b0cf3e303b0`
- License: Apache License 2.0

### Silero VAD

- Project: Silero VAD
- Pinned revision: `76e3dc408eb2a5c655c34e230d2d5459b4439daa`
- License: MIT

### pyannote Segmentation 3.0

- Project: pyannote.audio Segmentation 3.0
- Runtime artifact mirror:
  `screenpipe/screenpipe@892199f742e46d0c5d9e8c06687b35ca7c2b6547`
- License: MIT

The ONNX bytes are fetched from the immutable last MIT Screenpipe baseline and
verified against the Civitas release digest. pyannote is not affiliated with or
endorsing Civitas.

### WeSpeaker CAM++ speaker embedding

- Project: WeSpeaker
- Runtime artifact mirror:
  `screenpipe/screenpipe@892199f742e46d0c5d9e8c06687b35ca7c2b6547`
- Model license: Creative Commons Attribution 4.0 International (CC BY 4.0)
- Toolkit license: Apache License 2.0

WeSpeaker's official pretrained-model terms apply to the model weights. The
immutable ONNX artifact is digest-verified before loading.

### Optional Smart PII models

- Text model: `screenpipe/pii-redactor` revision
  `5c907008e2a2ad394712496a26819ad28dd44662`
- Image model: `screenpipe/pii-image-redactor` revision
  `d4bb93370fc3fe3c36007bef22f71bd0e97a0951`
- License: Creative Commons Attribution-NonCommercial 4.0 International
  (CC BY-NC 4.0)

These weights require a separate versioned acknowledgement and are unsuitable
for commercial use without separately licensed weights. They are not included
in the DMG.

## Third-party names and service marks

The interface can display names or icons for compatible applications and
providers so a user can identify a source or destination. Those names, logos,
and marks belong to their respective owners. Their presence indicates
interoperability only and does not imply affiliation, sponsorship, or
endorsement. The public-release asset allowlist and trademark wording require
owner and legal review before repository visibility changes.

## Source dependencies

Rust and JavaScript dependencies are enumerated in `Cargo.lock` and the Bun
lockfiles. Their package metadata and license expressions are captured in the
release SBOM. Copyright and license notices contained in dependency source
distributions remain applicable.

## Design review reference

The repository's non-runtime design-review heuristics were informed by
[`emilkowalski/skills`](https://github.com/emilkowalski/skills/tree/70744e3816f1d93eafb697161a8b880a7384c5ff),
copyright Emil Kowalski and contributors, licensed under the MIT License. No
package, source module, or runtime asset from that repository is bundled with
Civitas; it is recorded here as a review and interaction-design reference.

If an attribution appears incomplete, please report it privately using
[SECURITY.md](SECURITY.md) when disclosure could create a security concern, or
open a documentation issue otherwise.
