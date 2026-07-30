# Core Engine Coverage Map

This is a behavioral coverage dashboard for Civitas's core Rust crates.
It is not line or branch coverage. A mapped suite contributes coverage to
each declared platform and layer based on non-ignored Rust test blocks,
confidence, and criticality.

- Manifest: `coverage/core-engine-map.json`
- Tracked crates: civitas-engine, civitas-db, civitas-audio, civitas-screen, civitas-a11y
- Mapped suites: 27
- Mapped Rust files: 228
- Active test blocks: 1961
- Ignored/manual test blocks: 121
- Declared test blocks: 2082
- Weighted coverage points: 1681.9

Confidence weights: strong=1.0, partial=0.7, conditional=0.4, smoke=0.3.
Criticality weights: high=1.0, medium=0.7, low=0.4.
Ignored tests are counted but do not contribute weighted points until they
are explicitly enabled in a runtime lane.

## Platform Summary

| Platform | Suites | Active tests | Ignored tests | Weighted points | Layers | Flows | Critical score |
| --- | --- | --- | --- | --- | --- | --- | --- |
| windows | 24 | 1872 | 108 | 1640.5 | 22 | 13 | 100% |
| macos | 24 | 1912 | 97 | 1651.4 | 23 | 13 | 100% |
| linux | 22 | 1857 | 84 | 1627.0 | 21 | 13 | 100% |

## Crate Summary

| Crate | Suites | Integration files | Source unit files | Active tests | Ignored tests | Weighted points | Flows |
| --- | --- | --- | --- | --- | --- | --- | --- |
| civitas-engine | 8 | 17 | 67 | 877 | 42 | 702.2 | 12 |
| civitas-db | 5 | 31 | 15 | 378 | 5 | 368.8 | 12 |
| civitas-audio | 5 | 22 | 29 | 287 | 34 | 249.1 | 5 |
| civitas-screen | 5 | 9 | 10 | 168 | 7 | 166.8 | 4 |
| civitas-a11y | 4 | 2 | 26 | 251 | 33 | 195.0 | 3 |

## Line Coverage

No `cargo llvm-cov` summary was supplied. Behavioral flow coverage above answers
which product risks are represented by tests; line/branch coverage should be
measured separately with `cargo llvm-cov` when the Rust toolchain is available.

Suggested command from the repo root:

```bash
cargo llvm-cov --workspace --summary-only --output-format json > coverage/core-llvm-cov-summary.json
```

Then regenerate with:

```bash
cd apps/civitas-app-tauri
bun run coverage:core -- --llvm-cov-summary ../../coverage/core-llvm-cov-summary.json
```

## Layer Matrix

| Layer | windows | macos | linux |
| --- | --- | --- | --- |
| accessibility | 4 suites / 273 active / 25 ignored / 255.4 pts | 4 suites / 309 active / 14 ignored / 261.4 pts | 4 suites / 263 active / 3 ignored / 244.6 pts |
| audio | 6 suites / 371 active / 35 ignored / 333.1 pts | 6 suites / 371 active / 35 ignored / 333.1 pts | 6 suites / 371 active / 35 ignored / 333.1 pts |
| audio-device | 1 suites / 78 active / 4 ignored / 78.0 pts | 1 suites / 78 active / 4 ignored / 78.0 pts | 1 suites / 78 active / 4 ignored / 78.0 pts |
| configuration | 2 suites / 119 active / 3 ignored / 109.8 pts | 2 suites / 119 active / 3 ignored / 109.8 pts | 2 suites / 119 active / 3 ignored / 109.8 pts |
| database | 4 suites / 292 active / 4 ignored / 282.8 pts | 4 suites / 292 active / 4 ignored / 282.8 pts | 4 suites / 292 active / 4 ignored / 282.8 pts |
| db-search | 2 suites / 109 active / 7 ignored / 109.0 pts | 2 suites / 109 active / 7 ignored / 109.0 pts | 2 suites / 109 active / 7 ignored / 109.0 pts |
| engine-lifecycle | 3 suites / 117 active / 1 ignored / 115.6 pts | 3 suites / 117 active / 1 ignored / 115.6 pts | 2 suites / 115 active / 1 ignored / 115.0 pts |
| inference | 1 suites / 159 active / 0 ignored / 159.0 pts | 1 suites / 159 active / 0 ignored / 159.0 pts | 1 suites / 159 active / 0 ignored / 159.0 pts |
| knowledge-graph | 2 suites / 225 active / 0 ignored / 225.0 pts | 2 suites / 225 active / 0 ignored / 225.0 pts | 2 suites / 225 active / 0 ignored / 225.0 pts |
| local-api | 4 suites / 301 active / 8 ignored / 269.5 pts | 4 suites / 301 active / 8 ignored / 269.5 pts | 4 suites / 301 active / 8 ignored / 269.5 pts |
| meeting | 5 suites / 793 active / 11 ignored / 661.0 pts | 5 suites / 793 active / 11 ignored / 661.0 pts | 5 suites / 793 active / 11 ignored / 661.0 pts |
| ocr | 4 suites / 90 active / 5 ignored / 88.8 pts | 4 suites / 94 active / 5 ignored / 93.7 pts | 3 suites / 87 active / 3 ignored / 86.7 pts |
| os-integration | 1 suites / 2 active / 0 ignored / 0.6 pts | 1 suites / 2 active / 0 ignored / 0.6 pts | - |
| performance | 11 suites / 939 active / 55 ignored / 859.2 pts | 12 suites / 1003 active / 66 ignored / 884.8 pts | 11 suites / 939 active / 55 ignored / 859.2 pts |
| pipes | 1 suites / 335 active / 6 ignored / 234.5 pts | 1 suites / 335 active / 6 ignored / 234.5 pts | 1 suites / 335 active / 6 ignored / 234.5 pts |
| privacy | 8 suites / 917 active / 39 ignored / 799.4 pts | 8 suites / 953 active / 28 ignored / 805.4 pts | 8 suites / 907 active / 17 ignored / 788.6 pts |
| real-app | - | 1 suites / 64 active / 11 ignored / 25.6 pts | - |
| speaker | 2 suites / 194 active / 3 ignored / 194.0 pts | 2 suites / 194 active / 3 ignored / 194.0 pts | 2 suites / 194 active / 3 ignored / 194.0 pts |
| storage | 2 suites / 262 active / 28 ignored / 220.6 pts | 2 suites / 262 active / 28 ignored / 220.6 pts | 2 suites / 262 active / 28 ignored / 220.6 pts |
| timeline | 4 suites / 524 active / 31 ignored / 451.1 pts | 4 suites / 524 active / 31 ignored / 451.1 pts | 4 suites / 524 active / 31 ignored / 451.1 pts |
| transcription | 5 suites / 314 active / 32 ignored / 244.6 pts | 5 suites / 314 active / 32 ignored / 244.6 pts | 5 suites / 314 active / 32 ignored / 244.6 pts |
| ui-events | 4 suites / 522 active / 30 ignored / 403.9 pts | 3 suites / 494 active / 8 ignored / 384.3 pts | 3 suites / 494 active / 8 ignored / 384.3 pts |
| vision-capture | 4 suites / 299 active / 30 ignored / 256.4 pts | 4 suites / 303 active / 30 ignored / 261.3 pts | 3 suites / 296 active / 28 ignored / 254.3 pts |

## Critical Flow Matrix

| Flow | Required layers | windows | macos | linux |
| --- | --- | --- | --- | --- |
| Settings to engine recording config | configuration | covered (strong; engine-config-lifecycle, db-accessibility-ui-events) | covered (strong; engine-config-lifecycle, db-accessibility-ui-events) | covered (strong; engine-config-lifecycle, db-accessibility-ui-events) |
| Engine health, sleep, and lifecycle | engine-lifecycle | covered (strong; engine-config-lifecycle, engine-local-security-reliability) | covered (strong; engine-config-lifecycle, engine-local-security-reliability) | covered (strong; engine-config-lifecycle, engine-local-security-reliability) |
| Capture, OCR, and frame persistence | vision-capture, ocr | covered (partial; screen-windows-ocr, screen-capture-ocr-contract) | covered (strong; screen-macos-ocr, screen-capture-ocr-contract) | covered (partial; screen-capture-ocr-contract) |
| Timeline frame and stream delivery | timeline | covered (strong; screen-capture-windowing, db-timeline-frames) | covered (strong; screen-capture-windowing, db-timeline-frames) | covered (strong; screen-capture-windowing, db-timeline-frames) |
| Local API search and indexing | local-api, db-search | covered (strong; engine-local-api-search-integration) | covered (strong; engine-local-api-search-integration) | covered (strong; engine-local-api-search-integration) |
| Personal knowledge graph ingestion, review, and query | knowledge-graph, database | covered (strong; db-personal-knowledge-graph) | covered (strong; db-personal-knowledge-graph) | covered (strong; db-personal-knowledge-graph) |
| Evidence-grounded personal next actions with abstention | inference, knowledge-graph | covered (strong; engine-personal-knowledge-assistance) | covered (strong; engine-personal-knowledge-assistance) | covered (strong; engine-personal-knowledge-assistance) |
| Audio record, transcribe, and reconcile | audio, transcription | covered (strong; audio-meetings-speakers-dedup, audio-transcription-pipeline) | covered (strong; audio-meetings-speakers-dedup, audio-transcription-pipeline) | covered (strong; audio-meetings-speakers-dedup, audio-transcription-pipeline) |
| Audio device and stream health | audio-device | covered (strong; audio-device-stream-health) | covered (strong; audio-device-stream-health) | covered (strong; audio-device-stream-health) |
| Meeting detection and live transcript merge | meeting | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) |
| Privacy filters, DRM guards, and redaction | privacy | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) | covered (strong; engine-meeting-privacy-integrations, engine-personal-knowledge-assistance) |
| Accessibility tree and UI event capture | accessibility, ui-events | covered (strong; a11y-core-tree-cross-platform, a11y-windows-tree) | covered (strong; a11y-core-tree-cross-platform, db-accessibility-ui-events) | covered (strong; a11y-core-tree-cross-platform, db-accessibility-ui-events) |
| Performance, backpressure, and liveness | performance | covered (strong; screen-capture-windowing, a11y-core-tree-cross-platform) | covered (strong; screen-capture-windowing, a11y-core-tree-cross-platform) | covered (strong; screen-capture-windowing, a11y-core-tree-cross-platform) |

## Critical Gaps

- windows: no critical gaps in the current manifest.
- macos: no critical gaps in the current manifest.
- linux: no critical gaps in the current manifest.

## Execution Integrity

- Every discovered integration test file in tracked crates is mapped to a suite.
- Every discovered source unit test file in tracked crates is mapped to a suite.
- Both integration and source unit test files are enforced by `--check`.
- Suites with only ignored/manual tests: screen-custom-ocr. They do not contribute weighted points until explicitly run.
- Static counts do not prove a test executed on a given CI runner. Platform `cfg` gates, ignored tests, missing devices, and skipped runtime paths still need job results or llvm-cov data.

## Suite Inventory

| Suite | Crate | Platforms | Layers | Flows | Criticality | Confidence | Kind | Files | Active | Ignored | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| a11y-core-tree-cross-platform | civitas-a11y | windows, macos, linux | accessibility, ui-events, privacy, performance | accessibility-ui-events, privacy-and-redaction, performance-liveness | high | strong | unit | 12 | 141 | 0 | Cross-platform accessibility config, tree normalization, cache, privacy title matching, events, budget, and activity feed units. |
| a11y-linux-tree | civitas-a11y | linux | accessibility, privacy | accessibility-ui-events, privacy-and-redaction | medium | partial | unit | 4 | 18 | 0 | Linux-specific accessibility/incognito normalization tests. |
| a11y-macos-tree | civitas-a11y | macos | accessibility, privacy, real-app, performance | accessibility-ui-events, privacy-and-redaction, performance-liveness | high | conditional | mixed | 6 | 64 | 11 | macOS AX unit coverage plus real TextEdit/Finder/Obsidian probes. Obsidian tests are ignored by default because they require a local app install and AX permission. |
| a11y-windows-tree | civitas-a11y | windows | accessibility, privacy, ui-events | accessibility-ui-events, privacy-and-redaction | high | partial | unit | 6 | 28 | 22 | Windows UIA/accessibility parsing and privacy matching; some UIA tests are ignored where they require a live desktop. |
| audio-device-stream-health | civitas-audio | windows, macos, linux | audio-device, audio, performance | audio-device-health, audio-record-transcribe, performance-liveness | high | strong | mixed | 12 | 78 | 4 | Device monitor, stream buffering, source lag, Bluetooth gap/hallucination regressions, and process-tap/unit coverage. |
| audio-meetings-speakers-dedup | civitas-audio | windows, macos, linux | audio, meeting, speaker, transcription | audio-record-transcribe, meeting-live-notes, performance-liveness | high | strong | mixed | 17 | 110 | 2 | Meeting streaming config/controller logic, speaker embedding state, cross-device dedupe simulations, and overlap cleanup coverage. |
| audio-models-filtering | civitas-audio | windows, macos, linux | audio, transcription, privacy | audio-record-transcribe, privacy-and-redaction | medium | partial | mixed | 5 | 17 | 10 | Model-download/TLS guards, ONNX startup smoke, and music-versus-speech filtering. |
| audio-pipeline-benchmarks | civitas-audio | windows, macos, linux | audio, transcription, performance | audio-record-transcribe, meeting-live-notes, performance-liveness | medium | partial | benchmark | 8 | 22 | 12 | Benchmark-backed regression probes for VAD, smart mode, meeting audio, quality, cross-device, and end-to-end pipeline timing. |
| audio-transcription-pipeline | civitas-audio | windows, macos, linux | audio, transcription, performance | audio-record-transcribe, meeting-live-notes, performance-liveness | high | partial | mixed | 9 | 60 | 6 | Batch deferral, cleanup, language detection, result normalization, and real recording/transcription tests. Hardware/model-heavy tests are ignored by default. |
| db-accessibility-ui-events | civitas-db | windows, macos, linux | database, configuration, accessibility, ui-events, performance | settings-to-engine-config, accessibility-ui-events, performance-liveness | medium | partial | integration | 5 | 18 | 2 | Elements bulk insert, on-screen filtering, UI event batching, DB tier config, and ignored heavy-read real-DB probes. |
| db-audio-meetings-speakers | civitas-db | windows, macos, linux | database, audio, meeting, speaker | audio-record-transcribe, audio-device-health, meeting-live-notes | high | strong | integration | 11 | 84 | 1 | Audio transcript dedupe, live meeting mirroring, open meeting invariants, liveness, and speaker reassignment coverage. |
| db-personal-knowledge-graph | civitas-db | windows, macos, linux | database, knowledge-graph, privacy | personal-knowledge-graph, grounded-next-actions, privacy-and-redaction | high | strong | mixed | 11 | 66 | 0 | In-memory and migration-backed coverage for personal graph entities and edges, project roots, evidence connectivity, candidate review, episodes, trajectories, and owner-only feedback. |
| db-search-indexing | civitas-db | windows, macos, linux | db-search, ocr, accessibility, performance | local-api-search, capture-ocr-pipeline, accessibility-ui-events, performance-liveness | high | strong | mixed | 9 | 86 | 1 | FTS, tokenizer, OCR snapshot search, query planning, ordering, accessibility search, and contention coverage. |
| db-timeline-frames | civitas-db | windows, macos, linux | database, timeline, storage, performance | timeline-streaming, performance-liveness | high | strong | mixed | 10 | 124 | 1 | Frame/audio joins, timeline query shape, suggestions frames, write queue, DB primitives, and timeline performance. |
| engine-api-routes | civitas-engine | windows, macos, linux | local-api, timeline, meeting, transcription | local-api-search, timeline-streaming, meeting-live-notes, audio-record-transcribe | high | partial | mixed | 14 | 105 | 2 | Route/unit coverage for search, health, streaming, meetings, time/timezone, and transcription. Legacy endpoint/websocket tests require local data and remain ignored. |
| engine-capture-timeline | civitas-engine | windows, macos, linux | vision-capture, timeline, storage, performance | capture-ocr-pipeline, timeline-streaming, performance-liveness | high | partial | mixed | 18 | 138 | 27 | Covers capture trigger logic, frame/audio linking, hot cache, timeline refresh regressions, fragmented MP4 extraction, and HD-mode control. Several real-data tests are intentionally ignored by default. |
| engine-config-lifecycle | civitas-engine | windows, macos, linux | configuration, engine-lifecycle, performance | settings-to-engine-config, engine-health-lifecycle, performance-liveness | high | strong | mixed | 9 | 101 | 1 | Fast logic coverage for the config bridge, tray health debounce, sleep/power policies, and queue backpressure. |
| engine-focus-os | civitas-engine | windows, macos | engine-lifecycle, os-integration | engine-health-lifecycle, performance-liveness | medium | conditional | unit | 2 | 2 | 0 | Platform focus-tracker parsing/helpers. These files are cfg-gated and only execute on their target OS. |
| engine-local-api-search-integration | civitas-engine | windows, macos, linux | local-api, db-search | local-api-search | high | strong | integration | 1 | 23 | 6 | Active /search route test builds an audio-disabled router, seeds captured-screen-shaped OCR data into an in-memory DB, and asserts the HTTP response and pagination. |
| engine-local-security-reliability | civitas-engine | windows, macos, linux | local-api, privacy, engine-lifecycle, performance | local-api-search, privacy-and-redaction, engine-health-lifecycle, performance-liveness | high | strong | unit | 5 | 14 | 0 | Fail-closed loopback authentication, workflow permission enforcement, local retention policy, crash handling, and server boundary tests. |
| engine-meeting-privacy-integrations | civitas-engine | windows, macos, linux | meeting, privacy, ui-events, pipes | meeting-live-notes, privacy-and-redaction, accessibility-ui-events, performance-liveness | medium | strong | unit | 13 | 335 | 6 | Unit-heavy coverage for meeting heuristics, UI-recorder safety, local connector memory, pipes, MCP configuration, and consumer CLI parsing. |
| engine-personal-knowledge-assistance | civitas-engine | windows, macos, linux | knowledge-graph, inference, local-api, privacy, meeting | personal-knowledge-graph, grounded-next-actions, local-api-search, privacy-and-redaction, meeting-live-notes | high | strong | mixed | 22 | 159 | 0 | Personal graph query/review, evidence lineage, inference gateway boundaries, candidate abstention, Next Actions scoring, value-event feedback, and workflow/episode extraction. |
| screen-capture-ocr-contract | civitas-screen | windows, macos, linux | vision-capture, ocr | capture-ocr-pipeline | high | partial | unit | 1 | 1 | 0 | Cross-platform cached-OCR unit coverage for RawCaptureResult to CaptureResult metadata, browser URL, focus state, and window-to-screen OCR coordinate transformation. |
| screen-capture-windowing | civitas-screen | windows, macos, linux | vision-capture, timeline, performance, privacy | capture-ocr-pipeline, timeline-streaming, privacy-and-redaction, performance-liveness | high | strong | mixed | 13 | 157 | 1 | Window filtering, empty-window regressions, retry policy, URL timing, monitor cache, OCR cache, snapshots, and image comparison. |
| screen-custom-ocr | civitas-screen | windows, macos, linux | ocr | capture-ocr-pipeline | medium | conditional | manual | 1 | 0 | 2 | Custom OCR tests are ignored by default and only contribute when explicitly run. |
| screen-macos-ocr | civitas-screen | macos | ocr, vision-capture | capture-ocr-pipeline | high | strong | mixed | 2 | 7 | 2 | Apple Vision OCR source/unit coverage and fixture OCR assertions. |
| screen-windows-ocr | civitas-screen | windows | ocr, vision-capture | capture-ocr-pipeline | high | partial | integration | 2 | 3 | 2 | Windows OCR fixture coverage plus an ignored continuous-capture probe that requires a live desktop. |

## File Inventory

| Suite | Crate | File | Scope | Active | Ignored | Declared |
| --- | --- | --- | --- | --- | --- | --- |
| a11y-core-tree-cross-platform | civitas-a11y | src/activity_feed.rs | source | 7 | 0 | 7 |
| a11y-core-tree-cross-platform | civitas-a11y | src/budget.rs | source | 9 | 0 | 9 |
| a11y-core-tree-cross-platform | civitas-a11y | src/config.rs | source | 8 | 0 | 8 |
| a11y-core-tree-cross-platform | civitas-a11y | src/events.rs | source | 4 | 0 | 4 |
| a11y-linux-tree | civitas-a11y | src/incognito/linux.rs | source | 2 | 0 | 2 |
| a11y-macos-tree | civitas-a11y | src/incognito/macos.rs | source | 7 | 0 | 7 |
| a11y-core-tree-cross-platform | civitas-a11y | src/incognito/mod.rs | source | 7 | 0 | 7 |
| a11y-core-tree-cross-platform | civitas-a11y | src/incognito/titles.rs | source | 27 | 0 | 27 |
| a11y-windows-tree | civitas-a11y | src/incognito/windows.rs | source | 2 | 0 | 2 |
| a11y-core-tree-cross-platform | civitas-a11y | src/lib.rs | source | 2 | 0 | 2 |
| a11y-linux-tree | civitas-a11y | src/platform/linux.rs | source | 4 | 0 | 4 |
| a11y-macos-tree | civitas-a11y | src/platform/macos.rs | source | 10 | 0 | 10 |
| a11y-windows-tree | civitas-a11y | src/platform/windows_uia_tests.rs | source | 0 | 12 | 12 |
| a11y-windows-tree | civitas-a11y | src/platform/windows_uia.rs | source | 6 | 10 | 16 |
| a11y-windows-tree | civitas-a11y | src/platform/windows.rs | source | 10 | 0 | 10 |
| a11y-core-tree-cross-platform | civitas-a11y | src/tree/cache.rs | source | 6 | 0 | 6 |
| a11y-core-tree-cross-platform | civitas-a11y | src/tree/electron_docs.rs | source | 17 | 0 | 17 |
| a11y-core-tree-cross-platform | civitas-a11y | src/tree/enhanced_mode_cache.rs | source | 15 | 0 | 15 |
| a11y-linux-tree | civitas-a11y | src/tree/linux_lines.rs | source | 3 | 0 | 3 |
| a11y-linux-tree | civitas-a11y | src/tree/linux.rs | source | 9 | 0 | 9 |
| a11y-macos-tree | civitas-a11y | src/tree/macos_lines.rs | source | 12 | 0 | 12 |
| a11y-macos-tree | civitas-a11y | src/tree/macos.rs | source | 35 | 0 | 35 |
| a11y-core-tree-cross-platform | civitas-a11y | src/tree/mod.rs | source | 32 | 0 | 32 |
| a11y-windows-tree | civitas-a11y | src/tree/windows_lines.rs | source | 2 | 0 | 2 |
| a11y-windows-tree | civitas-a11y | src/tree/windows.rs | source | 8 | 0 | 8 |
| a11y-core-tree-cross-platform | civitas-a11y | src/url_filter.rs | source | 7 | 0 | 7 |
| a11y-macos-tree | civitas-a11y | tests/e2e_obsidian.rs | integration | 0 | 3 | 3 |
| a11y-macos-tree | civitas-a11y | tests/e2e_tree_walker.rs | integration | 0 | 8 | 8 |
| audio-device-stream-health | civitas-audio | src/audio_manager/device_monitor.rs | source | 23 | 0 | 23 |
| audio-device-stream-health | civitas-audio | src/audio_manager/manager.rs | source | 9 | 0 | 9 |
| audio-meetings-speakers-dedup | civitas-audio | src/audio_manager/reconciliation.rs | source | 10 | 0 | 10 |
| audio-device-stream-health | civitas-audio | src/core/device_detection.rs | source | 7 | 0 | 7 |
| audio-device-stream-health | civitas-audio | src/core/device.rs | source | 4 | 0 | 4 |
| audio-device-stream-health | civitas-audio | src/core/e2e_ghost_word_silent_room.rs | source | 0 | 2 | 2 |
| audio-transcription-pipeline | civitas-audio | src/core/engine.rs | source | 9 | 0 | 9 |
| audio-device-stream-health | civitas-audio | src/core/process_tap.rs | source | 10 | 0 | 10 |
| audio-transcription-pipeline | civitas-audio | src/core/run_record_and_transcribe.rs | source | 7 | 0 | 7 |
| audio-device-stream-health | civitas-audio | src/core/source_buffer.rs | source | 6 | 0 | 6 |
| audio-device-stream-health | civitas-audio | src/core/stream.rs | source | 8 | 0 | 8 |
| audio-device-stream-health | civitas-audio | src/idle_detector.rs | source | 4 | 0 | 4 |
| audio-device-stream-health | civitas-audio | src/lib.rs | source | 3 | 0 | 3 |
| audio-meetings-speakers-dedup | civitas-audio | src/meeting_detector.rs | source | 6 | 0 | 6 |
| audio-meetings-speakers-dedup | civitas-audio | src/meeting_streaming/config.rs | source | 5 | 0 | 5 |
| audio-meetings-speakers-dedup | civitas-audio | src/meeting_streaming/controller.rs | source | 11 | 0 | 11 |
| audio-meetings-speakers-dedup | civitas-audio | src/meeting_streaming/deepgram_live.rs | source | 4 | 0 | 4 |
| audio-meetings-speakers-dedup | civitas-audio | src/meeting_streaming/selected_engine.rs | source | 2 | 0 | 2 |
| audio-models-filtering | civitas-audio | src/models/download.rs | source | 5 | 3 | 8 |
| audio-meetings-speakers-dedup | civitas-audio | src/speaker/embedding_manager.rs | source | 8 | 0 | 8 |
| audio-meetings-speakers-dedup | civitas-audio | src/speaker/mod.rs | source | 11 | 1 | 12 |
| audio-meetings-speakers-dedup | civitas-audio | src/speaker/models.rs | source | 3 | 0 | 3 |
| audio-meetings-speakers-dedup | civitas-audio | src/speaker/segment.rs | source | 1 | 0 | 1 |
| audio-transcription-pipeline | civitas-audio | src/transcription/deepgram/batch.rs | source | 5 | 0 | 5 |
| audio-transcription-pipeline | civitas-audio | src/transcription/openai_compatible/batch.rs | source | 3 | 0 | 3 |
| audio-transcription-pipeline | civitas-audio | src/transcription/transcription_result.rs | source | 8 | 0 | 8 |
| audio-transcription-pipeline | civitas-audio | src/transcription/verified_models.rs | source | 2 | 0 | 2 |
| audio-transcription-pipeline | civitas-audio | src/transcription/whisper/detect_language.rs | source | 4 | 0 | 4 |
| audio-models-filtering | civitas-audio | src/utils/audio/music_detection.rs | source | 6 | 0 | 6 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/audio_fixtures.rs | integration | 6 | 0 | 6 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/cross_device_benchmark.rs | integration | 1 | 1 | 2 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/ground_truth.rs | integration | 2 | 0 | 2 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/meeting_benchmark.rs | integration | 3 | 1 | 4 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/pipeline_benchmark.rs | integration | 1 | 2 | 3 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/quality_regression.rs | integration | 3 | 4 | 7 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/smart_mode_benchmark.rs | integration | 4 | 1 | 5 |
| audio-pipeline-benchmarks | civitas-audio | tests/audio_pipeline_benchmark/vad_benchmark.rs | integration | 2 | 3 | 5 |
| audio-transcription-pipeline | civitas-audio | tests/batch_deferral_test.rs | integration | 21 | 0 | 21 |
| audio-device-stream-health | civitas-audio | tests/bluetooth_gap_hallucination_test.rs | integration | 1 | 2 | 3 |
| audio-device-stream-health | civitas-audio | tests/channel_lag_test.rs | integration | 3 | 0 | 3 |
| audio-transcription-pipeline | civitas-audio | tests/core_tests.rs | integration | 1 | 6 | 7 |
| audio-meetings-speakers-dedup | civitas-audio | tests/dedup_benchmark/fixtures.rs | integration | 3 | 0 | 3 |
| audio-meetings-speakers-dedup | civitas-audio | tests/dedup_benchmark/integration.rs | integration | 12 | 0 | 12 |
| audio-meetings-speakers-dedup | civitas-audio | tests/dedup_benchmark/metrics.rs | integration | 3 | 0 | 3 |
| audio-meetings-speakers-dedup | civitas-audio | tests/dedup_benchmark/scenarios.rs | integration | 10 | 0 | 10 |
| audio-meetings-speakers-dedup | civitas-audio | tests/dedup_benchmark/simulation.rs | integration | 3 | 0 | 3 |
| audio-models-filtering | civitas-audio | tests/hf_tls_test.rs | integration | 0 | 2 | 2 |
| audio-models-filtering | civitas-audio | tests/music_detection_real.rs | integration | 6 | 0 | 6 |
| audio-models-filtering | civitas-audio | tests/onnx_model_test.rs | integration | 0 | 5 | 5 |
| audio-meetings-speakers-dedup | civitas-audio | tests/overlap_dedup_test.rs | integration | 16 | 0 | 16 |
| audio-meetings-speakers-dedup | civitas-audio | tests/speaker_identification.rs | integration | 2 | 1 | 3 |
| db-personal-knowledge-graph | civitas-db | src/connectivity.rs | source | 7 | 0 | 7 |
| db-timeline-frames | civitas-db | src/db.rs | source | 32 | 0 | 32 |
| db-personal-knowledge-graph | civitas-db | src/entity_kind.rs | source | 4 | 0 | 4 |
| db-personal-knowledge-graph | civitas-db | src/entity_resolver.rs | source | 9 | 0 | 9 |
| db-personal-knowledge-graph | civitas-db | src/episodes.rs | source | 11 | 0 | 11 |
| db-personal-knowledge-graph | civitas-db | src/graph.rs | source | 2 | 0 | 2 |
| db-personal-knowledge-graph | civitas-db | src/kg_access.rs | source | 4 | 0 | 4 |
| db-personal-knowledge-graph | civitas-db | src/kg.rs | source | 11 | 0 | 11 |
| db-timeline-frames | civitas-db | src/sqlite_error.rs | source | 2 | 0 | 2 |
| db-search-indexing | civitas-db | src/text_normalizer.rs | source | 21 | 0 | 21 |
| db-search-indexing | civitas-db | src/text_similarity.rs | source | 18 | 0 | 18 |
| db-personal-knowledge-graph | civitas-db | src/trajectories.rs | source | 4 | 0 | 4 |
| db-timeline-frames | civitas-db | src/types.rs | source | 3 | 0 | 3 |
| db-personal-knowledge-graph | civitas-db | src/value_events.rs | source | 11 | 0 | 11 |
| db-timeline-frames | civitas-db | src/write_queue.rs | source | 17 | 0 | 17 |
| db-audio-meetings-speakers | civitas-db | tests/audio_duplicate_test.rs | integration | 12 | 0 | 12 |
| db-personal-knowledge-graph | civitas-db | tests/candidate_review_test.rs | integration | 1 | 0 | 1 |
| db-audio-meetings-speakers | civitas-db | tests/chunk_outcome_test.rs | integration | 14 | 0 | 14 |
| db-accessibility-ui-events | civitas-db | tests/db_config_test.rs | integration | 5 | 0 | 5 |
| db-timeline-frames | civitas-db | tests/db.rs | integration | 37 | 0 | 37 |
| db-timeline-frames | civitas-db | tests/frame_offset_sync_test.rs | integration | 6 | 0 | 6 |
| db-search-indexing | civitas-db | tests/fts_contention_test.rs | integration | 4 | 0 | 4 |
| db-search-indexing | civitas-db | tests/fts_dots_test.rs | integration | 13 | 0 | 13 |
| db-accessibility-ui-events | civitas-db | tests/heavy_read_test.rs | integration | 0 | 2 | 2 |
| db-search-indexing | civitas-db | tests/keyword_search_accessibility_test.rs | integration | 8 | 0 | 8 |
| db-search-indexing | civitas-db | tests/keyword_search_order_test.rs | integration | 3 | 0 | 3 |
| db-timeline-frames | civitas-db | tests/live_coverage_marker_test.rs | integration | 7 | 0 | 7 |
| db-audio-meetings-speakers | civitas-db | tests/meeting_context_test.rs | integration | 1 | 0 | 1 |
| db-audio-meetings-speakers | civitas-db | tests/meeting_end_reason_test.rs | integration | 9 | 0 | 9 |
| db-audio-meetings-speakers | civitas-db | tests/meeting_transcript_dedup_test.rs | integration | 1 | 0 | 1 |
| db-accessibility-ui-events | civitas-db | tests/ocr_elements_bulk_test.rs | integration | 4 | 0 | 4 |
| db-accessibility-ui-events | civitas-db | tests/on_screen_filter_test.rs | integration | 6 | 0 | 6 |
| db-audio-meetings-speakers | civitas-db | tests/output_audio_liveness_test.rs | integration | 8 | 0 | 8 |
| db-personal-knowledge-graph | civitas-db | tests/project_roots_test.rs | integration | 2 | 0 | 2 |
| db-search-indexing | civitas-db | tests/query_plan_test.rs | integration | 15 | 0 | 15 |
| db-search-indexing | civitas-db | tests/search_ocr_snapshot_test.rs | integration | 4 | 0 | 4 |
| db-audio-meetings-speakers | civitas-db | tests/single_open_meeting_invariant_test.rs | integration | 3 | 0 | 3 |
| db-audio-meetings-speakers | civitas-db | tests/speaker_benchmark.rs | integration | 0 | 1 | 1 |
| db-audio-meetings-speakers | civitas-db | tests/speaker_reassignment_test.rs | integration | 13 | 0 | 13 |
| db-search-indexing | civitas-db | tests/tag_filter_bench.rs | integration | 0 | 1 | 1 |
| db-audio-meetings-speakers | civitas-db | tests/timeline_live_meeting_test.rs | integration | 9 | 0 | 9 |
| db-timeline-frames | civitas-db | tests/timeline_performance_test.rs | integration | 11 | 1 | 12 |
| db-timeline-frames | civitas-db | tests/transcribed_audio_eviction_test.rs | integration | 5 | 0 | 5 |
| db-accessibility-ui-events | civitas-db | tests/ui_events_batch_test.rs | integration | 3 | 0 | 3 |
| db-audio-meetings-speakers | civitas-db | tests/untranscribed_chunks_test.rs | integration | 14 | 0 | 14 |
| db-timeline-frames | civitas-db | tests/vacuum_test.rs | integration | 4 | 0 | 4 |
| engine-local-security-reliability | civitas-engine | src/auth_key.rs | source | 1 | 0 | 1 |
| engine-meeting-privacy-integrations | civitas-engine | src/calendar_speaker_id.rs | source | 41 | 0 | 41 |
| engine-meeting-privacy-integrations | civitas-engine | src/cli/mod.rs | source | 19 | 0 | 19 |
| engine-meeting-privacy-integrations | civitas-engine | src/cli/presets.rs | source | 9 | 0 | 9 |
| engine-meeting-privacy-integrations | civitas-engine | src/cli/search.rs | source | 7 | 0 | 7 |
| engine-meeting-privacy-integrations | civitas-engine | src/cli/store_file.rs | source | 12 | 0 | 12 |
| engine-meeting-privacy-integrations | civitas-engine | src/connections_api.rs | source | 41 | 0 | 41 |
| engine-personal-knowledge-assistance | civitas-engine | src/connectivity_pass.rs | source | 3 | 0 | 3 |
| engine-local-security-reliability | civitas-engine | src/crash_log.rs | source | 4 | 0 | 4 |
| engine-meeting-privacy-integrations | civitas-engine | src/drm_detector.rs | source | 19 | 2 | 21 |
| engine-personal-knowledge-assistance | civitas-engine | src/episode_extractor.rs | source | 24 | 0 | 24 |
| engine-personal-knowledge-assistance | civitas-engine | src/episode_miner.rs | source | 12 | 0 | 12 |
| engine-capture-timeline | civitas-engine | src/event_driven_capture.rs | source | 37 | 0 | 37 |
| engine-meeting-privacy-integrations | civitas-engine | src/external_memory_sync.rs | source | 9 | 0 | 9 |
| engine-capture-timeline | civitas-engine | src/focus_aware_controller.rs | source | 12 | 0 | 12 |
| engine-focus-os | civitas-engine | src/focus_tracker/darwin.rs | source | 1 | 0 | 1 |
| engine-focus-os | civitas-engine | src/focus_tracker/windows.rs | source | 1 | 0 | 1 |
| engine-capture-timeline | civitas-engine | src/frame_linker_actor.rs | source | 2 | 0 | 2 |
| engine-capture-timeline | civitas-engine | src/frame_linker.rs | source | 10 | 0 | 10 |
| engine-capture-timeline | civitas-engine | src/hd_recorder.rs | source | 1 | 0 | 1 |
| engine-capture-timeline | civitas-engine | src/high_fps_controller.rs | source | 25 | 0 | 25 |
| engine-capture-timeline | civitas-engine | src/hot_frame_cache.rs | source | 4 | 0 | 4 |
| engine-personal-knowledge-assistance | civitas-engine | src/inference.rs | source | 10 | 0 | 10 |
| engine-personal-knowledge-assistance | civitas-engine | src/llm.rs | source | 4 | 0 | 4 |
| engine-config-lifecycle | civitas-engine | src/logging.rs | source | 18 | 0 | 18 |
| engine-meeting-privacy-integrations | civitas-engine | src/mcp_servers_api.rs | source | 12 | 0 | 12 |
| engine-meeting-privacy-integrations | civitas-engine | src/meeting_detector.rs | source | 102 | 3 | 105 |
| engine-meeting-privacy-integrations | civitas-engine | src/meeting_export.rs | source | 7 | 1 | 8 |
| engine-personal-knowledge-assistance | civitas-engine | src/next_actions.rs | source | 5 | 0 | 5 |
| engine-local-security-reliability | civitas-engine | src/pipe_permissions_middleware.rs | source | 3 | 0 | 3 |
| engine-meeting-privacy-integrations | civitas-engine | src/pipe_store.rs | source | 21 | 0 | 21 |
| engine-config-lifecycle | civitas-engine | src/power/manager.rs | source | 2 | 0 | 2 |
| engine-config-lifecycle | civitas-engine | src/power/monitor.rs | source | 3 | 0 | 3 |
| engine-config-lifecycle | civitas-engine | src/power/profile.rs | source | 27 | 0 | 27 |
| engine-config-lifecycle | civitas-engine | src/recording_config.rs | source | 11 | 0 | 11 |
| engine-local-security-reliability | civitas-engine | src/retention.rs | source | 2 | 0 | 2 |
| engine-api-routes | civitas-engine | src/routes/activity_summary.rs | source | 51 | 0 | 51 |
| engine-api-routes | civitas-engine | src/routes/capabilities.rs | source | 1 | 0 | 1 |
| engine-api-routes | civitas-engine | src/routes/elements.rs | source | 1 | 0 | 1 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/episodes.rs | source | 10 | 0 | 10 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/graph_next.rs | source | 5 | 0 | 5 |
| engine-api-routes | civitas-engine | src/routes/health.rs | source | 4 | 0 | 4 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/inference_gateway.rs | source | 5 | 0 | 5 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/kg_access.rs | source | 7 | 0 | 7 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/kg_candidates.rs | source | 3 | 0 | 3 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/kg.rs | source | 17 | 0 | 17 |
| engine-api-routes | civitas-engine | src/routes/meetings.rs | source | 3 | 0 | 3 |
| engine-api-routes | civitas-engine | src/routes/memories.rs | source | 4 | 0 | 4 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/next_actions.rs | source | 5 | 0 | 5 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/project_roots.rs | source | 4 | 0 | 4 |
| engine-api-routes | civitas-engine | src/routes/retranscribe.rs | source | 3 | 0 | 3 |
| engine-api-routes | civitas-engine | src/routes/search.rs | source | 7 | 0 | 7 |
| engine-api-routes | civitas-engine | src/routes/streaming.rs | source | 5 | 0 | 5 |
| engine-api-routes | civitas-engine | src/routes/time.rs | source | 8 | 0 | 8 |
| engine-api-routes | civitas-engine | src/routes/timezone.rs | source | 8 | 0 | 8 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/value_events.rs | source | 2 | 0 | 2 |
| engine-personal-knowledge-assistance | civitas-engine | src/routes/workflows.rs | source | 1 | 0 | 1 |
| engine-config-lifecycle | civitas-engine | src/schedule_monitor.rs | source | 6 | 0 | 6 |
| engine-personal-knowledge-assistance | civitas-engine | src/scribe.rs | source | 18 | 0 | 18 |
| engine-local-security-reliability | civitas-engine | src/server.rs | source | 4 | 0 | 4 |
| engine-config-lifecycle | civitas-engine | src/sleep_monitor.rs | source | 8 | 1 | 9 |
| engine-capture-timeline | civitas-engine | src/snapshot_compaction.rs | source | 13 | 0 | 13 |
| engine-meeting-privacy-integrations | civitas-engine | src/ui_recorder.rs | source | 36 | 0 | 36 |
| engine-capture-timeline | civitas-engine | src/video_utils.rs | source | 6 | 0 | 6 |
| engine-capture-timeline | civitas-engine | src/vision_manager/manager.rs | source | 5 | 0 | 5 |
| engine-personal-knowledge-assistance | civitas-engine | src/work_relevance_judge.rs | source | 2 | 0 | 2 |
| engine-personal-knowledge-assistance | civitas-engine | src/workflow_utils.rs | source | 11 | 0 | 11 |
| engine-capture-timeline | civitas-engine | tests/audio_vision_integration_test.rs | integration | 0 | 1 | 1 |
| engine-config-lifecycle | civitas-engine | tests/consumer_sleep_test.rs | integration | 5 | 0 | 5 |
| engine-local-api-search-integration | civitas-engine | tests/endpoint_test.rs | integration | 23 | 6 | 29 |
| engine-capture-timeline | civitas-engine | tests/first_frames_test.rs | integration | 0 | 4 | 4 |
| engine-capture-timeline | civitas-engine | tests/frame_extraction_test.rs | integration | 0 | 6 | 6 |
| engine-capture-timeline | civitas-engine | tests/frame_linker_actor_integration.rs | integration | 7 | 0 | 7 |
| engine-config-lifecycle | civitas-engine | tests/health_debounce_test.rs | integration | 21 | 0 | 21 |
| engine-personal-knowledge-assistance | civitas-engine | tests/kg_prose_query_test.rs | integration | 3 | 0 | 3 |
| engine-personal-knowledge-assistance | civitas-engine | tests/next_actions_eval.rs | integration | 2 | 0 | 2 |
| engine-capture-timeline | civitas-engine | tests/stream_frames_test.rs | integration | 0 | 5 | 5 |
| engine-api-routes | civitas-engine | tests/tags_test.rs | integration | 5 | 0 | 5 |
| engine-capture-timeline | civitas-engine | tests/timeline_refresh_bug_test.rs | integration | 16 | 0 | 16 |
| engine-api-routes | civitas-engine | tests/transcribe_test.rs | integration | 5 | 1 | 6 |
| engine-personal-knowledge-assistance | civitas-engine | tests/value_events_test.rs | integration | 6 | 0 | 6 |
| engine-capture-timeline | civitas-engine | tests/video_cache_test.rs | integration | 0 | 8 | 8 |
| engine-capture-timeline | civitas-engine | tests/video_utils_test.rs | integration | 0 | 3 | 3 |
| engine-api-routes | civitas-engine | tests/websockets_test.rs | integration | 0 | 1 | 1 |
| screen-macos-ocr | civitas-screen | src/apple.rs | source | 7 | 0 | 7 |
| screen-capture-windowing | civitas-screen | src/browser_utils/mod.rs | source | 13 | 0 | 13 |
| screen-capture-windowing | civitas-screen | src/capture_screenshot_by_window.rs | source | 60 | 0 | 60 |
| screen-capture-ocr-contract | civitas-screen | src/core.rs | source | 1 | 0 | 1 |
| screen-capture-windowing | civitas-screen | src/frame_comparison.rs | source | 13 | 0 | 13 |
| screen-windows-ocr | civitas-screen | src/microsoft.rs | source | 3 | 0 | 3 |
| screen-capture-windowing | civitas-screen | src/monitor.rs | source | 6 | 1 | 7 |
| screen-capture-windowing | civitas-screen | src/ocr_cache.rs | source | 10 | 0 | 10 |
| screen-capture-windowing | civitas-screen | src/snapshot_writer.rs | source | 4 | 0 | 4 |
| screen-capture-windowing | civitas-screen | src/utils.rs | source | 5 | 0 | 5 |
| screen-macos-ocr | civitas-screen | tests/apple_vision_test.rs | integration | 0 | 2 | 2 |
| screen-capture-windowing | civitas-screen | tests/capture_error_test.rs | integration | 4 | 0 | 4 |
| screen-capture-windowing | civitas-screen | tests/capture_retry_test.rs | integration | 16 | 0 | 16 |
| screen-custom-ocr | civitas-screen | tests/custom_ocr_test.rs | integration | 0 | 2 | 2 |
| screen-capture-windowing | civitas-screen | tests/empty_window_name_test.rs | integration | 9 | 0 | 9 |
| screen-capture-windowing | civitas-screen | tests/frame_window_mismatch_test.rs | integration | 3 | 0 | 3 |
| screen-capture-windowing | civitas-screen | tests/monitor_cache_test.rs | integration | 7 | 0 | 7 |
| screen-capture-windowing | civitas-screen | tests/url_timing_test.rs | integration | 7 | 0 | 7 |
| screen-windows-ocr | civitas-screen | tests/windows_vision_test.rs | integration | 0 | 2 | 2 |
