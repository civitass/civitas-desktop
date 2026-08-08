# Building Civitas Desktop

This guide builds the consumer, local-first edition from source. A source build
does not use Civitas accounts or private Civitas infrastructure. It is not
signed by the Civitas Developer ID and does not use the official automatic
updater.

## Supported toolchain

The repository pins Rust `1.93.1` in `rust-toolchain.toml` and Bun `1.3.10` in
the desktop `package.json` and release workflow. Use the pinned versions when
reproducing a release.

Common requirements:

- Git;
- Rustup with the repository toolchain;
- Bun `1.3.10`;
- CMake, pkg-config, a C/C++ toolchain, and platform SDKs;
- FFmpeg and Tesseract for a development build.

Official macOS release jobs build a reduced, network-disabled FFmpeg sidecar
from the pinned source commit documented in `THIRD_PARTY_NOTICES.md`. A local
development build instead prepares only the current Mac architecture from
version-pinned static archives. It verifies both the archive and extracted
executables and records their provenance beside the ignored build inputs.
These development sidecars are not equivalent to the license-minimized
official release input.

## macOS

Install full Xcode, accept its license, and run its first-launch setup:

```bash
sudo xcodebuild -license
xcodebuild -runFirstLaunch
brew install bun cmake ffmpeg jq pkg-config tesseract wget
rustup show
```

The app needs macOS permission for each capture modality you enable. A
development build and an official signed build have different identities, so
macOS may ask again when you switch between them.

## Windows

Install Visual Studio 2022 Build Tools with the Desktop development with C++
workload, Windows SDK, Rustup, LLVM, CMake, Git, Bun, 7-Zip, and FFmpeg. Set
`LIBCLANG_PATH` to the LLVM `bin` directory if bindgen cannot locate Clang.

The supported release target is `x86_64-pc-windows-msvc`. Windows signing and
installer verification are release-owner operations and are not required for a
local source build. The official workflow requires timestamped Authenticode on
the application, NSIS installer, and every installed executable payload,
verifies their publisher and timestamp, scans the decompressed installation
boundary, and performs an isolated install and uninstall. An unsigned local
build must not be redistributed as an official Civitas package.

Git for Windows supplies Bash to optional assistant tools. The application does
not download or run PortableGit or another system installer. Without Git Bash,
core Civitas features continue to work and assistant tools that require Bash
fail with local guidance.

## Linux

Package names differ by distribution. On Ubuntu, the common dependencies are:

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential cmake ffmpeg libavdevice-dev libavfilter-dev \
  libavformat-dev libclang-dev libpipewire-0.3-dev libsdl2-dev libssl-dev \
  libtesseract-dev libxdo-dev libxtst-dev pkg-config \
  tesseract-ocr tesseract-ocr-eng \
  tesseract-ocr-chi-sim tesseract-ocr-chi-tra
```

Linux desktop support depends on the compositor, portal, and audio stack. See
the current release notes for tested distributions. The distro packages above
provide the local English, Simplified Chinese, and Traditional Chinese OCR
baseline. See [Local multilingual OCR](OCR.md) for capability checks and other
languages.

## Clone and build

```bash
git clone https://github.com/civitass/civitas-desktop.git
cd civitas-desktop

cargo build --locked

cd apps/civitas-app-tauri
bun install --frozen-lockfile
bun run typecheck
bun run tauri dev
```

The consumer source tree intentionally contains no Git LFS pointers. Models
and retained native runtime assets use the verified download paths documented
below; a source clone never needs access to historic LFS objects.

For an optimized local desktop bundle:

```bash
cd apps/civitas-app-tauri
./scripts/build_macos.sh --bundles app
```

On macOS, this wrapper validates the selected target, builds without invoking
release signing, then applies and verifies a local hardened-runtime signature.
It uses an ad-hoc identity by default. Release maintainers may set
`CIVITAS_DEVELOPMENT_SIGNING_IDENTITY` to an explicitly reviewed Developer ID
Application identity; non-ad-hoc signatures also receive Apple’s trusted
timestamp. The protected release workflow remains the only supported path for
notarized public artifacts.

The helper fails closed if the Tauri bundle identity and credential-vault
identity disagree. A local production-identity release candidate therefore
requires both reviewed controls:

```bash
./scripts/build_macos.sh \
  --bundles app \
  --config src-tauri/tauri.prod.conf.json \
  --config src-tauri/tauri.macos.conf.json \
  --features official-build,metal,redact-onnx-coreml
```

That artifact is locally signed, not notarized, and must not be distributed.
The second configuration restores the reviewed macOS-only `bun`, `ffmpeg`,
and `ffprobe` sidecar allowlist after the production configuration overlay.
Every nested executable is also rejected if its deployment target exceeds the
app's advertised macOS 13 minimum.
Public DMG and updater artifacts are built, signed, notarized, stapled, and
verified only by the protected release workflow.

On Linux, use the dedicated command. It downloads only the pinned,
integrity-checked Tesseract baseline needed by a self-contained AppImage:

```bash
cd apps/civitas-app-tauri
bun run tauri:build:linux
```

Source, test, development, and ad-hoc optimized builds use both an isolated
`team.civitas.app.debug.<namespace>` credential-vault service and the matching
`~/.civitas-development/<namespace>` data directory. They never request the
signed release app's `team.civitas.app` vault item or open its default
`~/.civitas` database. This paired boundary prevents two build identities from
encrypting rows in one database with different keys.

Set `CIVITAS_KEYCHAIN_NAMESPACE` to a 1–64 character alphanumeric, hyphen, or
underscore value when separate local builds should not share development data
or credentials:

```bash
CIVITAS_KEYCHAIN_NAMESPACE=feature_review bun run tauri build
```

An explicit, absolute `CIVITAS_DATA_DIR` takes precedence. When setting it,
use a directory dedicated to the same development namespace:

```bash
CIVITAS_KEYCHAIN_NAMESPACE=feature_review \
  CIVITAS_DATA_DIR=/absolute/path/to/civitas-feature-review \
  bun run tauri dev
```

Never point a source build at the signed app's `~/.civitas` directory. The
secret-store identity check fails closed before a mismatched build can write a
credential, but it cannot make one database safely share two encryption keys.

Settings and startup metadata remain in the identity-scoped directory. When a
user selects a different local data directory, capture, timeline media, chat
history, assistant workspaces, and retrieval use the validated resolved
directory. Tauri grants the webview access only to the required chat,
large-context, and media subdirectories; the database, settings store, logs,
and credential metadata are never added to the webview filesystem scope.

The `official-build` Cargo feature selects the production vault identity and
is reserved for the protected workflow and the explicitly configured local
release-candidate check above. Never enable it with the development Tauri
configuration.

For the standalone engine:

```bash
cargo build --locked --release -p civitas-engine
./target/release/civitas record --use-all-monitors
```

The engine stores data under `~/.civitas` by default and exposes its
authenticated API only on `127.0.0.1`. A bare `civitas record` serves that
local API with screen, microphone, system audio, typed-text, and clipboard
capture all off. Opt in with `--use-all-monitors` or `--monitor-id`,
`--capture-microphone`, `--capture-system-audio`,
`--capture-typed-text`, and `--capture-clipboard-content` as needed.
Remote providers or downloads additionally require `--allow-remote`.

Use `CIVITAS_DATA_DIR` for an isolated development profile:

```bash
CIVITAS_DATA_DIR=/absolute/path/to/civitas-dev \
  cargo run -p civitas-engine --bin civitas -- record --port 3035 --use-all-monitors
```

Do not point a development build at a production data directory without a
backup.

## Feature choices

On Apple Silicon, local acceleration is available through the `metal` feature.
The official Apple Silicon release additionally enables the reviewed local PII
model feature selected in the release workflow.

```bash
cargo build --release --features metal,apple-intelligence
```

Features change the native dependency graph. Run the same feature set in tests
that you intend to ship.

## Generated files

Rust commands exported to the webview are checked into
`apps/civitas-app-tauri/lib/utils/tauri.ts`. Regenerate them after adding,
removing, or changing a Tauri command:

```bash
cd apps/civitas-app-tauri
bun run bindings:generate
bun run bindings:check
```

Embedded skill content is also generated:

```bash
cd apps/civitas-app-tauri
bun run skills:generate
```

Commit generated changes with the source change that produced them.

The optional assistant dependency graph has a separate reviewed manifest and
lockfile at `crates/civitas-core/assets/pi-runtime/`. Regenerate that lock only
with the pinned Bun `1.3.10`, review the full diff and licenses, and validate:

```bash
cd crates/civitas-core/assets/pi-runtime
bun install --lockfile-only --ignore-scripts
bun install --frozen-lockfile --production --ignore-scripts
```

The release binary embeds both files. Runtime installation is an explicit
in-app action and refuses a changed dependency graph.

The public API contract is generated from the same router that the engine
serves. For a deterministic offline refresh:

```bash
CIVITAS_DUMP_OPENAPI=/tmp/civitas-openapi.json \
  cargo test --locked -p civitas-engine --test endpoint_test \
  tests::dump_openapi_spec_to_file -- --exact --ignored
./scripts/update-openapi.sh --from-json /tmp/civitas-openapi.json
```

Review `docs/openapi.yaml` before committing it. The endpoint tests compare the
checked-in snapshot with the live router and fail when a route is missing.

## Required checks

Run focused tests while iterating and the broad checks before release:

```bash
cargo fmt --all -- --check
cargo check --locked --workspace
cargo test --locked --workspace

cd apps/civitas-app-tauri
bun run typecheck
bun run test
bun run bindings:check

cd ../..
node scripts/audit-consumer-design.mjs
node scripts/validate-tauri-production-security.mjs .
node scripts/audit-publication.mjs .
```

Platform capture and clean-install tests cannot be replaced by unit tests.
Official release candidates must also pass signing, notarization, stapling,
Gatekeeper, checksum, updater-signature, and clean-machine checks described in
`docs/RELEASE_VERIFICATION.md`.

## Secrets and release credentials

No build credential belongs in source, a shell transcript, an issue, or a
fixture. Local provider credentials are entered through Settings → AI and
stored through the OS credential vault.

Official release signing, notarization, and updater secrets are held in GitHub
Actions secrets. The release workflow fails closed when a required credential
is missing. It publishes the protected draft only after exact-commit CI,
platform signatures, notarization, updater signatures, checksums, SBOM,
provenance, and isolated installation verification all pass.

## Troubleshooting

- If Rust uses the wrong version, run `rustup override unset` and `rustup show`
  from the repository root.
- If generated bindings differ, run `bun run bindings:generate`, inspect the
  diff, and rerun `bun run bindings:check`.
- If macOS permissions appear stuck, remove the development app from System
  Settings → Privacy & Security, relaunch it, and grant only the modalities you
  intend to test.
- If a local model is unavailable in network-deny mode, download it first while
  online, verify its license and source, then retry.
- If the credential vault is denied or unavailable, Civitas intentionally
  refuses to persist remote-provider credentials. Its UI may hold a provider
  credential only in process memory after an explicit session-only choice.
  Repair OS vault access rather than placing a key in settings or an
  environment file.
