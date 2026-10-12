# README visuals and capture provenance

The product images use the real Civitas Desktop interface from native macOS
E2E tests. Layout, captions, backgrounds and diagrams are generated separately;
they do not add controls, invent results or alter text inside the app captures.
The original Civitas brand marks are retained. AI image generation was not
needed: the application captures provide the evidence these images should show.

## Capture sources

All four raw PNGs were copied without retouching from the
`macos-e2e-test-artifacts` artifact in
[E2E run 38182251850](https://github.com/civitass/civitas-desktop/actions/runs/38182251850),
built from commit
[`eb15b2af8e25780af405a18fd030784ab08da01b`](https://github.com/civitass/civitas-desktop/commit/eb15b2af8e25780af405a18fd030784ab08da01b).
The native macOS publication scenarios completed on October 11, 2026. The
screenshots are 1600 × 677 pixels; the hosted Mac display constrained the
requested 1600 × 1100 window height.

| Unmodified source | Artifact filename | Scenario |
| --- | --- | --- |
| [Next Actions](../demo/next-actions.png) | `screenshots/publication-next-actions.png` | Creates two synthetic commitments through the real form, refreshes the ranking and verifies the resulting cards. |
| [Timeline](../demo/timeline.png) | `screenshots/publication-timeline.png` | Seeds three frames in the isolated local library, then verifies the normal Timeline renders the expected image. |
| [AI providers](../demo/ai-providers.png) | `screenshots/publication-ai-settings.png` | Opens AI settings and selects Amazon Bedrock without entering a credential or sending a prompt. |
| [Privacy](../demo/privacy.png) | `screenshots/settings-privacy.png` | Opens Privacy settings and verifies the API-authentication and credential-storage controls render. |

The first three captures come from
[`publication-demo.spec.ts`](../../../apps/civitas-app-tauri/e2e/specs/publication-demo.spec.ts).
The Privacy capture comes from the test beginning “Privacy section renders api
auth + keychain controls” in
[`settings-sections.spec.ts`](../../../apps/civitas-app-tauri/e2e/specs/settings-sections.spec.ts).
It shows the Local-only network boundary, masked local API credential and
credential-storage status in the isolated test profile.

These are native interface captures with synthetic content. The E2E launcher
uses a separate `.e2e` data directory, and the publication journey runs with
the `onboarding,no-recording` seed. The published pixels contain no personal
capture, real conversation, customer data or usable credential.

**The Northstar launch board inside Timeline is a synthetic source image,
not a Civitas dashboard.** The fixture is
[`publication-timeline-frame.png`](../../../apps/civitas-app-tauri/e2e/fixtures/publication-timeline-frame.png).
The E2E-only seed command places it in the local database and frame cache; the
real Timeline retrieves and displays it through the normal application path.
The sidebar, date navigation, Timeline controls and time scrubber belong to
Civitas. Northstar, Atlas migration and the commitments are demonstration data.

## Presentation assets

The [manifest](manifest.json) records source hashes, dimensions and crop
rectangles. Closeups use deliberate crops and uniform scaling. No interface
text or controls are repainted or invented. The Privacy presentation contains
two separately labelled excerpts, not a reconstructed settings screen. The
root README links to the full raw captures.

| Native detail | Source rectangle: x, y, width, height |
| --- | --- |
| Complete first Next Actions card | `520, 209, 785, 366` |
| Full Timeline | `0, 0, 1600, 677` |
| AI-provider choice grid | `463, 65, 897, 351` |
| Selected Local-only control | `272, 239, 638, 86` |
| Credential-storage explanation | `278, 491, 753, 39` |

Coordinates are in original screenshot pixels. The share cards reuse the
Next Actions and Local-only crops respectively; every placement and uniform
scale is recorded in the manifest.

| Files | Purpose |
| --- | --- |
| `hero-light.svg`, `hero-dark.svg` | Original wordmark adapted for both GitHub themes. |
| `scene-timeline.svg` | Timeline presentation with its synthetic source content identified. |
| `shot-next-actions.svg` | Focused view of a reviewable action and its visible controls. |
| `shot-ai-providers.svg` | AI-provider choices and the local/remote boundary. |
| `shot-privacy.svg` | The actual Local-only and security settings. |
| `how-it-works-light.svg`, `how-it-works-dark.svg` | Explanatory diagrams, not application screenshots. |
| `share-context.svg`, `share-context.png` | Shareable product image built around real interface evidence. |
| `share-privacy.svg`, `share-privacy.png` | Shareable privacy image built around the actual settings. |

## Share images

Both PNGs are 1200 × 630 pixels and use actual native interface details.
The SVG sources retain their text and composition for future edits through
the renderer.

[![Civitas context card: Pick up where you left off, with a real Next Actions card and its review controls.](share-context.png)](share-context.png)

[Context PNG](share-context.png) · [Context SVG](share-context.svg)

[![Civitas privacy card: Your work, on your computer, with the actual selected Local-only network setting.](share-privacy.png)](share-privacy.png)

[Privacy PNG](share-privacy.png) · [Privacy SVG](share-privacy.svg)

## Regenerate the presentation

Install the locked frontend dependencies first; the renderer uses the app's
pinned Sharp dependency. From the repository root:

```bash
cd apps/civitas-app-tauri
bun install --frozen-lockfile
cd ../..
bun scripts/generate-readme-visuals.mjs
bun scripts/generate-readme-visuals.mjs --check
```

SVG generation is reproducible byte for byte. Share-PNG rasterization uses
the rendering host's fonts, so a different host can produce different PNG
bytes. `--check` regenerates and compares the SVG source exactly, verifies
native-source hashes, and checks the existing share PNGs against their reviewed
manifest hashes and 1200 × 630 dimensions without rerasterizing them.

Rendering reuses the checked-in captures; it does not launch Civitas or
certify a newer interface. Review any regenerated PNGs before publishing, plus
the README at normal and narrow widths in both themes. Check readable labels,
intact controls, accurate captions and links to the original captures.

## Capture a newer native interface

Follow [the build prerequisites](../../BUILDING.md) and
[the E2E instructions](../../../apps/civitas-app-tauri/e2e/README.md), or use the
existing [E2E workflow](../../../.github/workflows/e2e-test.yml). Native capture
requires a compiled E2E application, the platform toolchain and a working
graphical session; the presentation renderer is not a replacement for these.

After completing the platform prerequisites, the build and test stages are
separate. For a POSIX development shell, from `apps/civitas-app-tauri`:

```bash
bun install --frozen-lockfile
NEXT_PUBLIC_CIVITAS_E2E=true bun tauri build --no-sign --debug --no-bundle -- --features e2e
CIVITAS_E2E_SEED=onboarding,no-recording bun run test:e2e
```

The launcher recreates its isolated `.e2e` directory for each run. Keep
recording disabled for publication captures and use synthetic fixtures. The
complete suite preserves the capture order and settings used by this set;
running an individual spec can produce a different viewport or settings state.
Screenshots are saved in `e2e/screenshots/`; CI includes them in each platform's
test artifact.

When replacing a source, inspect its pixels rather than trusting the filename.
Record the new immutable commit, successful scenario, platform and workflow
run. Replace the raw PNG and update the provenance constants, expected source
hash and crop coordinates in
[`scripts/generate-readme-visuals.mjs`](../../../scripts/generate-readme-visuals.mjs),
then regenerate. The manifest is generated output; do not edit it by hand.
Retain truthful fixture captions and never substitute an invented interface
for a missing product state.
