# Local multilingual OCR

Civitas reads visible screen text on the user's computer. OCR is part of the
local capture pipeline: screenshot pixels are not sent to Civitas, an AI
provider, or an OCR service. A remote AI profile can receive selected text only
when the user later makes an explicit AI request under that profile's displayed
data boundary.

## Choose screen-text languages

Open **Settings → Recording → Screen text languages**.

- **Automatic / recommended** lets Apple Vision or Windows OCR choose locally.
  Tesseract does not detect languages automatically, so Linux uses Civitas's
  bundled English + Simplified Chinese + Traditional Chinese baseline. If an
  installed model matches the device locale, it receives first priority;
  Chinese locales prioritize their Simplified or Traditional script.
- Choose **Chinese (Simplified)** for `zh-Hans` / `chi_sim`.
- Choose **Chinese (Traditional)** for `zh-Hant` / `chi_tra`.
- Add English or another language when the same screen regularly mixes scripts.

Screen-text languages are independent from spoken transcription languages.
Existing settings are migrated once so an upgrade does not silently change the
languages an earlier version used for OCR.

The status below the picker reports the engine actually in use and whether all
selected language models or operating-system language packs are available. A
missing model is an actionable error; Civitas does not treat a missing model as
an empty, successful OCR result.

## Platform behavior

| Platform | Default engine | Chinese support | Setup |
| --- | --- | --- | --- |
| macOS | Apple Vision, accurate recognition | Explicit Simplified and Traditional script tags; mixed incompatible scripts run as separate local passes and are merged by position/confidence | No model download. A current macOS release is recommended. |
| Windows | Windows.Media.Ocr | Every explicitly selected installed language runs as a separate local pass; Simplified and Traditional packs remain distinct and results are merged in visual reading order | Install every selected language in **Settings → Time & language → Language & region**, then restart Civitas. |
| Linux | Tesseract LSTM | `chi_sim` and `chi_tra`, with `eng` for mixed text | Install distro language packs, or build the AppImage with Civitas's pinned model bundle. |

The app probes runtime capabilities instead of assuming that a selected
language exists. Script-specific Chinese tags require an exact match; Civitas
will not silently substitute Traditional for Simplified or vice versa.

### Ubuntu and Debian development

```bash
sudo apt-get update
sudo apt-get install -y \
  tesseract-ocr tesseract-ocr-eng \
  tesseract-ocr-chi-sim tesseract-ocr-chi-tra \
  libtesseract-dev
```

Verify the installed models:

```bash
tesseract --list-langs
```

### Reproducible Linux bundle

`bun run tauri:build:linux` stages a compact baseline from the official
`tesseract-ocr/tessdata_best` repository: English, Simplified Chinese, and
Traditional Chinese. The build pins revision
`e12c65a915945e4c28e237a9b52bc4a8f39a0cec` and verifies every file's exact
byte count and SHA-512 digest before Tauri can package it. Structured
word positions require Tesseract's `tsv` output configuration, so the bundle
also includes that 22-byte configuration and its license from the official
`tesseract-ocr/tessconfigs` revision
`3decf1c8252ba6dbeef0bf908f4b0aab7f18d113`.

```bash
cd apps/civitas-app-tauri
bun run tessdata:fetch
bun run tessdata:check
bun run tauri:build:linux
```

The generated files are build inputs and remain ignored by Git. The bundle also
includes both upstream Apache-2.0 licenses. Exact digests live beside the
fetcher in `scripts/fetch_tessdata.js`.

## Recognition quality

Civitas uses accuracy-oriented OCR settings and preserves line boundaries.
Chinese, Japanese, and Korean tokens are reconstructed without inserting
English spaces between ideographs. Low-confidence Tesseract noise lines are
discarded consistently from both text and bounding-box output. On macOS,
mixed-script passes are merged in reading order and overlapping observations
retain the higher-confidence result. On Windows, Civitas checks every selected
language pack before recognition, scales oversized captures within the
operating system's advertised OCR limit, runs one pass per selected pack, and
merges positioned lines without letting a lower-priority, wrong-script
hallucination replace an exact-script result. Windows OCR does not expose
per-word confidence, so Civitas reports confidence as unknown instead of
inventing a perfect score.

For best results:

1. capture the original UI rather than a recompressed photo;
2. use a normal display scale and sufficient text size;
3. select the exact Chinese script when a screen is predominantly one script;
4. add English for mixed product names and code;
5. verify the capability status after changing an OS language pack.

OCR can still be imperfect with handwriting, vertical CJK text, decorative
fonts, extreme scaling, motion blur, low contrast, or text hidden under another
window. Search and knowledge-graph results should remain linked to the original
local evidence so a user can inspect the source rather than trust OCR blindly.

## Engineering verification

The automated suite covers language aliases, settings migration, platform tag
selection, mixed-script reconstruction, missing-model behavior, image decoding
limits, Windows multi-pass merge ordering and script conflicts, and the
local-only region OCR path. CI generates deterministic English, Simplified
Chinese, and Traditional Chinese UI fixtures at runtime from fixed synthetic
phrases and operating-system fonts. It then runs the normally ignored, real
engine tests with `--ignored`: Apple Vision reads all three fixtures, Tesseract
reads both Chinese scripts, and Windows OCR reads the English fixture through
the complete capture pipeline. This avoids both personal screenshots and the
previous false-green state where a missing fixture caused zero integration
tests to run.

Developers can generate the same fixtures locally:

```bash
python3 -m pip install Pillow==11.3.0
python3 scripts/generate_ocr_fixtures.py \
  --output-dir /tmp/civitas-ocr-fixtures \
  --latin-font "/System/Library/Fonts/Supplemental/Arial.ttf" \
  --cjk-font "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
```

macOS integration tests also accept user-supplied synthetic fixtures:

```bash
CIVITAS_OCR_FIXTURE_ZH=/absolute/path/simplified.png \
  cargo test -p civitas-screen --test apple_vision_test \
  test_apple_native_ocr_chinese -- --ignored --nocapture

CIVITAS_OCR_FIXTURE_ZH_HANT=/absolute/path/traditional.png \
  cargo test -p civitas-screen --test apple_vision_test \
  test_apple_native_ocr_chinese_traditional -- --ignored --nocapture
```

The fixture tests assert meaningful Chinese phrases and confidence, not merely
that some text was returned.

## Primary references

- [Apple: Recognizing text in images](https://developer.apple.com/documentation/vision/recognizing-text-in-images)
- [Apple: VNRecognizeTextRequest](https://developer.apple.com/documentation/vision/vnrecognizetextrequest)
- [Microsoft: installed OCR recognizer languages](https://learn.microsoft.com/en-us/uwp/api/windows.media.ocr.ocrengine.availablerecognizerlanguages)
- [Tesseract: data files and engine compatibility](https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html)
- [Tesseract: command-line language selection](https://tesseract-ocr.github.io/tessdoc/Command-Line-Usage.html)
- [Official `tessdata_best` models](https://github.com/tesseract-ocr/tessdata_best)
