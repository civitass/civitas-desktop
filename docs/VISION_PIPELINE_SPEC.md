# Vision Pipeline v2 — Architecture Spec

> **Status**: Draft
> **Date**: 2026-02-12
> **Context**: historical issue reports APP-38/62/4D and CLI-9Z/9Y (vision restart cascade), plus fresh-install testing on Mac Mini revealing pipeline stalls, silent frame drops, and 30–60 second delays before first data appears.

## 1. Problem Statement

### 1.1 The Promise

Civitas promises: "learns how your team works and turns it into shared workflows." Users expect that anything they saw on screen is searchable later. Missing data = broken product.

### 1.2 What's Broken Today (v2.0.440)

**Bug 1: Pipeline stalls after ~30 seconds.** The capture loop processes 12-13 frames, then stops producing new frames entirely. The heartbeat keeps ticking (iterations 100→6000+) but `frames_processed` freezes. The user browses 3 websites — none captured.

Root cause: OCR runs synchronously inside the capture loop. `process_max_average_frame()` calls `perform_ocr_apple()` for every visible window, blocking the entire capture cycle for 2-5 seconds per frame. After a burst of initial frames, the hash-based frame comparison (at 320×180 downscale) starts returning false matches, and all subsequent frames are skipped.

**Bug 2: Silent frame drops.** Out of 38 frames "processed" by the capture loop, only 4 reached the database. The `frame_write_tracker` race condition drops frames that pass OCR but haven't been written to video yet. The DB writer waits 100ms, doesn't find the frame in the tracker, and silently `continue`s.

**Bug 3: Health endpoint lies.** Reports `frame_status: ok` with `last_frame_timestamp` 6+ minutes stale. The tray icon shows "recording" when no data is being captured. The user has no way to know the pipeline is stalled.

**Bug 4: Permission recovery restart spam.** The permission recovery component polls every 500ms with no single-fire guard. When permissions are granted, it fires `stopCivitas()` + `spawnCivitas()` 13 times in 10 seconds, causing cascading server restarts, orphaned process kills, and OCR channel closures.

### 1.3 User Impact

- Fresh install: timeline shows "Building your memory" for 30-60+ seconds. Users think it's broken.
- Active use: user scrolls through articles, switches tabs, browses — most content is never captured.
- Search: "I know I saw that on screen" but it's not in the database.
- 3-monitor setups: 3× the OCR load, same serial pipeline. CPU spikes, frames drop.

## 2. User Scenarios & Guarantees

### 2.1 Scenarios

| Scenario | What happens today | What should happen |
|----------|-------------------|-------------------|
| **A. First launch** | 30-60s before first frame in DB. Timeline shows loading spinner. | First frame in DB within 5 seconds. Timeline shows content immediately. |
| **B. Scrolling HN thread** | 2-3 frames captured out of 30s of scrolling. Most comments lost. | At least 1 frame per 3-5s of active scrolling. All visible text captured. |
| **C. Rapid tab switching** | Maybe 2 out of 5 tabs captured. Others lost forever. | Every tab transition captured. Each tab's content OCR'd. |
| **D. 1-hour Zoom call** | OCR burns cycles on static camera window. Misses slide transitions. | Changed windows (shared screen) OCR'd. Static windows (camera) skipped. |
| **E. 3 monitors, coding** | All 3 monitors OCR'd equally. High CPU, frames still drop. | Active monitor at full rate. Idle monitors at reduced rate. CPU scales sublinearly. |
| **F. Left desk 20 min** | Pipeline may keep comparing frames, burning CPU. | Near-zero CPU on static screen. Instant resume when user returns. |
| **G. MacBook on battery** | Same CPU as plugged in. Battery drains fast. | "Light" mode available. Meaningful capture at ~2% CPU. |

### 2.2 Guarantees

**G1: Every window/app transition is captured.**
If the focused window changes, a frame of both the old and new state MUST reach the DB within 5 seconds. This is the highest-value event — it represents context switches the user will want to search for.

**G2: Active content changes are captured.**
During active use (scrolling, typing, browsing), at least 1 frame every 5 seconds reaches the DB with OCR text. The user should be able to reconstruct what they were looking at during any 10-second window of active use.

**G3: Static screens cost near-zero CPU.**
If the screen hasn't meaningfully changed for 30 seconds and there's no user input, the pipeline should sleep. No frame comparison, no OCR, no hash computation. Wake on input event or slow heartbeat (1 frame per 30-60s).

**G4: OCR never blocks capture.**
Screen capture must never wait for OCR. If OCR falls behind, drop OCR on older frames and process the newest one. Freshness > completeness.

**G5: First meaningful frame in DB within 5 seconds of server start.**
Skip all optimizations for the first frame: no similarity check, no cache, capture only the focused window. Get text into the DB immediately.

**G6: No silent frame drops.**
Every frame that passes similarity check and completes OCR MUST reach the DB. No "frame not found in write tracker → silently skip" behavior. If the video encoder is slow, store the OCR text with a null video offset and backfill later.

**G7: Health reflects reality.**
If `last_frame_timestamp` is >30s stale and the user is active, `frame_status` should be `stale` or `degraded`. The tray icon should reflect this. The user should never think it's working when it's not.

**G8: Multi-monitor CPU scales sublinearly.**
3 monitors should cost ~1.5-2× the CPU of 1 monitor, not 3×. Active monitor gets full capture rate. Idle monitors share a reduced budget.

## 3. Architecture

### 3.1 Current Pipeline (serial, blocking)

```
continuous_capture loop (single thread per monitor):
  capture_image()                    ~1ms
  frame_comparer.compare()           ~1ms
  if diff < 0.02 → skip
  capture_windows()                  ~50-200ms (CGWindowList per window)
  process_max_average_frame()        ~500-5000ms (Apple OCR per window) ← BLOCKS
  result_tx.send()                   ~0ms (but capture is already stalled)
  sleep(interval)                    2000ms at 0.5fps

Total cycle: 2.5-7+ seconds. Effective rate: 0.15-0.4 fps.
```

### 3.2 Target Pipeline (decoupled, event-driven)

```
                    ┌─────────────────────────────────────┐
                    │         Event Sources                │
                    │  UI events (focus, scroll, keypress) │
                    │  Periodic timer (adaptive interval)  │
                    │  First-frame trigger (server boot)   │
                    └──────────────┬──────────────────────┘
                                   │ triggers
                    ┌──────────────▼──────────────────────┐
                    │     Capture Thread (per monitor)     │
                    │                                      │
                    │  capture_monitor_image()     ~1ms    │
                    │  frame_comparer.compare()    ~1ms    │
                    │  if changed OR event-triggered:      │
                    │    capture_windows()         ~50ms   │
                    │    push to video_queue (non-block)   │
                    │    push to ocr_queue (non-block)     │
                    │                                      │
                    │  Total cycle: 2-50ms (never blocks)  │
                    └───────┬──────────────┬──────────────┘
                            │              │
                   ┌────────▼───┐   ┌──────▼──────────────┐
                   │ Video      │   │ OCR Queue            │
                   │ Encoder    │   │ (priority, bounded)  │
                   │            │   │                      │
                   │ write to   │   │ HIGH: transition     │
                   │ FFmpeg     │   │       frames         │
                   │ record in  │   │ NORMAL: periodic     │
                   │ tracker    │   │         frames       │
                   └────────┬───┘   └──────┬──────────────┘
                            │              │
                            │       ┌──────▼──────────────┐
                            │       │ OCR Worker(s)        │
                            │       │ (1-3, shared across  │
                            │       │  all monitors)       │
                            │       │                      │
                            │       │ per window:          │
                            │       │  hash → cache check  │
                            │       │  changed? → OCR it   │
                            │       │  same? → reuse cache │
                            │       └──────┬──────────────┘
                            │              │
                   ┌────────▼──────────────▼──────────────┐
                   │         DB Writer                     │
                   │                                       │
                   │  Get video offset from tracker        │
                   │  If not ready: store with NULL offset │
                   │    (backfill when encoder catches up) │
                   │  insert_frames_with_ocr_batch()       │
                   │  NEVER silently drop                  │
                   └───────────────────────────────────────┘
```

### 3.3 Capture Strategy: Event-Driven + Periodic Baseline

Replace the fixed-FPS model with an event-driven approach:

```
EVENT-DRIVEN (immediate capture, <200ms latency):
  - Window/app focus change  → capture NOW
  - URL change in browser    → capture NOW
  - Significant scroll       → capture NOW (debounced: max 1 per 2s)

ACTIVITY-DRIVEN (adaptive rate):
  - Mouse/keyboard active    → capture at configured FPS (default 0.5)
  - No input for 5s          → slow to 0.2 fps
  - No input for 30s         → slow to 1 frame per 30s

SAFETY NET:
  - No frame for 30s         → force capture regardless of similarity
  - Server just started      → immediate first frame, skip all filters
```

The UI event feed from `civitas-accessibility` already provides app switches, keyboard activity, and mouse events. The adaptive FPS feature already reads from it. The change is: use events as **capture triggers**, not just interval hints.

### 3.4 Frame Comparison Improvements

**Problem**: Downscale factor 6 (1920→320px) causes hash collisions on real content changes. A browser tab switch may hash-match at 320×180 resolution.

**Changes**:
- Reduce downscale factor from 6 to 3 (1920→640px). Histogram comparison at 640×360 is still fast (~1ms).
- Keep hash early exit for truly static screens (user left desk), but the larger resolution makes false matches much less likely.
- Add `max_skip_duration`: if no frame has been sent for OCR in N seconds (default 10s), force-send the next capture regardless of similarity score. This is the safety net that prevents "stuck at 31 frames" forever.

### 3.5 OCR Strategy

**Per-window change detection**: When a frame arrives at the OCR worker, don't OCR every window. For each window:
1. Compute image hash
2. Check OCR cache (existing, 5-minute TTL)
3. Cache hit → reuse previous OCR text (free)
4. Cache miss → run `perform_ocr_apple()` on that window only

This means if only Safari changed (user scrolled), we OCR Safari (~500ms) and reuse cached text for VS Code, Slack, etc. (free). Total OCR time: 500ms instead of 2-3 seconds.

**This already exists in the code** (`WindowOcrCache`). The difference is that with decoupled OCR, the cache becomes much more effective because the capture loop isn't blocked waiting for cache misses to resolve.

### 3.6 Video Write Tracker Fix

**Current bug**: `record_video()` pops from `ocr_frame_queue`, checks `frame_write_tracker`, waits 100ms if not found, then silently skips.

**Fix**: Decouple DB insertion from video offset. Two approaches:

**Option A (recommended)**: Ensure video write always happens before OCR queue processing. Change the pipeline so the video encoder gets frames first, records them in the tracker, and then the OCR worker processes them. By the time the DB writer needs the offset, it's guaranteed to exist.

**Option B**: Allow NULL video offsets in DB. Insert the OCR text immediately, backfill the video offset asynchronously when the encoder catches up. This is more complex but eliminates the timing dependency entirely.

### 3.7 First-Frame Fast Path

On server start:
1. Capture focused window only (skip unfocused windows — saves CGWindowList enumeration time)
2. Skip similarity comparison (no previous frame to compare against anyway — but explicitly bypass the `max_average` buffering too)
3. Run OCR immediately (no cache to check)
4. Insert to DB
5. Target: 5 seconds from server start to searchable text in DB

After the first frame is in DB, warm up the full pipeline: start capturing all windows, populate OCR cache, etc.

### 3.8 Health Endpoint

Add new fields:
```json
{
  "frame_status": "ok" | "stale" | "degraded",
  "last_frame_timestamp": "2026-02-13T02:25:06Z",
  "last_capture_timestamp": "2026-02-13T02:31:00Z",
  "frames_in_ocr_queue": 3,
  "capture_fps_actual": 0.45,
  "capture_fps_target": 0.5,
  "ocr_queue_depth": 2,
  "frames_skipped_since_last_ocr": 15
}
```

Rules:
- `stale`: `last_frame_timestamp` > 30s ago AND `last_capture_timestamp` < 5s ago (capturing but OCR stalled)
- `degraded`: `last_frame_timestamp` > 60s ago OR `capture_fps_actual` < 50% of target
- Tray icon should reflect: green (ok), yellow (stale/degraded), red (stopped)

## 4. Configuration

### 4.1 User-Facing Presets

Users see a simple choice, not knobs:

| Preset | Description | Target CPU | Capture | OCR Workers |
|--------|------------|-----------|---------|-------------|
| **Light** | Key moments, minimal battery impact | ~2% | Events + 0.2fps baseline, 30s max skip | 1 |
| **Balanced** | Most activity, moderate resources | ~5% | Events + 0.5fps baseline, 10s max skip | 2 |
| **Thorough** | Everything, higher resources | ~10% | Events + 1fps baseline, 5s max skip | 3 |

Default: **Balanced**.

On battery (MacBook): automatically downshift to Light.
On 3+ monitors: automatically cap OCR workers at 2 unless Thorough.

### 4.2 Advanced Settings (collapsed by default)

For power users who want fine control:

| Setting | Default (Balanced) | Range | Description |
|---------|-------------------|-------|-------------|
| `fps` | 0.5 | 0.1 - 2.0 | Base capture rate during active use |
| `max_skip_duration_secs` | 10 | 5 - 60 | Force capture after this many seconds of skips |
| `skip_threshold` | 0.015 | 0.005 - 0.05 | Frame similarity threshold (lower = more sensitive) |
| `downscale_factor` | 3 | 2 - 6 | Frame comparison resolution divisor |
| `max_ocr_workers` | 2 | 1 - 4 | Parallel OCR workers |
| `capture_unfocused_windows` | true | bool | Whether to capture/OCR non-focused windows |

### 4.3 Multi-Monitor Behavior

- Active monitor (has focus): full capture rate
- Background monitor (no focus, recent activity <60s): 50% capture rate
- Idle monitor (no activity >60s): 10% capture rate, skip OCR (video-only capture for timeline scrubbing)
- All monitors share the OCR worker pool — active monitor frames get priority

## 5. Implementation Plan

### Phase 0: Bug Fixes (no architecture change)

These can ship immediately on the current architecture:

1. **Fix frame write tracker race** — change the DB writer to retry for up to 2 seconds (not 100ms) before giving up, and log at WARN level (not debug) when frames are dropped. Or: ensure video queue is consumed before OCR queue.

2. **Fix permission recovery restart spam** — add `useRef(false)` guard so `stopCivitas` + `spawnCivitas` fires exactly once.

3. **Add `max_skip_duration`** — in `continuous_capture`, track `last_ocr_send_time`. If elapsed > 10 seconds, bypass similarity check and send current frame. Simple 5-line change that prevents "stuck at N frames forever."

4. **Reduce downscale factor from 6 to 3** — one-line change in `FrameComparisonConfig::default()`.

5. **Fix health endpoint** — add `stale` status when `last_frame_timestamp` > 30s and capture loop is still running.

### Phase 1: Decouple OCR from Capture

Move OCR processing out of `continuous_capture` and into a separate tokio task.

**Changes**:
- `continuous_capture` sends raw `CaptureResult` (with window images but WITHOUT OCR text) through `result_tx`
- New `ocr_worker` task receives from a dedicated channel, runs OCR per window, sends results to the existing `ocr_frame_queue`
- `process_ocr_task` / `process_max_average_frame` move from being called inside the capture loop to being called inside the OCR worker

**Files**: `crates/civitas-vision/src/core.rs`, `crates/civitas-server/src/video.rs`

**Risk**: Medium. Changes the data flow but the OCR logic itself doesn't change. Existing OCR cache, Apple Native engine, window capture all stay the same.

### Phase 2: Event-Driven Capture Triggers

Wire UI events (from `civitas-accessibility`) as capture triggers.

**Changes**:
- `continuous_capture` listens on a secondary channel for "capture now" signals
- `ActivityFeed` (adaptive FPS) emits trigger events for: app switch, window focus change, significant scroll
- When triggered, the capture loop runs immediately instead of waiting for the periodic interval
- Debounce: max 2 captures per second from event triggers

**Files**: `crates/civitas-vision/src/core.rs`, `crates/civitas-accessibility/` (if the ActivityFeed needs new event types)

**Risk**: Low. Additive change — the periodic capture still runs as a fallback.

### Phase 3: Multi-Monitor Priority & OCR Pool

Share OCR workers across monitors with priority scheduling.

**Changes**:
- Single OCR worker pool (configurable 1-4 workers) instead of implicit 1-per-monitor
- Priority queue: transition frames (from event triggers) > active monitor frames > idle monitor frames
- Per-monitor adaptive rate: focused monitor at full FPS, background monitors at reduced rate

**Files**: `crates/civitas-server/src/video.rs` (VideoCapture setup), `crates/civitas-server/src/core.rs` (worker pool), `crates/civitas-server/src/vision_manager/`

**Risk**: Medium-high. Changes the threading model. Needs careful testing with 1, 2, and 3 monitors.

### Phase 4: Presets & Polish

- Add preset UI (Light / Balanced / Thorough)
- Auto-detect battery state on MacBook, downshift when on battery
- First-frame fast path
- Health endpoint improvements
- Tray icon status colors

**Files**: Frontend settings UI, `embedded_server.rs` (config), `permissions.rs` (health)

**Risk**: Low. Mostly configuration plumbing and UI.

## 6. Success Metrics

After implementation, measure on real user setups:

| Metric | Current | Target |
|--------|---------|--------|
| Time to first frame in DB (cold start) | 30-60s | <5s |
| Frames reaching DB vs frames captured | ~10% (4/38) | >95% |
| Capture FPS actual vs target | 0.10 (target 0.5) | >0.40 |
| CPU usage, 1 monitor, Balanced | ~15% (spiky) | ~5% (steady) |
| CPU usage, 3 monitors, Balanced | ~40%+ | ~10% |
| Pipeline stall duration | 60s+ (indefinite) | 0s (never stalls) |
| Health accuracy | reports "ok" when stalled | reflects actual state |

## 7. Local-Device Identity and Legacy Schema Compatibility

### 7.1 Consumer Boundary

The consumer application has no cross-device synchronization, hosted archive,
remote-media retrieval, or Civitas control-plane dependency. Each installation
writes capture and derived knowledge to its own local SQLite database and media
directory. Moving data between computers requires an explicit user export and is
outside the capture pipeline.

### 7.2 Pipeline Invariants

The pipeline produces three linked local data types:

```text
video_chunks  ←  frames  ←  ocr_text
  (file_path)    (video_chunk_id,     (frame_id,
   device_name)   offset_index,        text,
                  timestamp,           app_name,
                  device_name)         window_name)
```

A frame row and its OCR rows must reference the same local video chunk and
offset. Decoupled OCR preserves that relationship by carrying `frame_number`
through the frame-write tracker. `device_name` identifies a monitor or audio
capture source on this computer; it does not identify a network peer.

Local media paths must resolve beneath the configured Civitas data directory.
A database row never authorizes a network fetch. Missing, evicted, or historic
non-local media references are reported as unavailable rather than dereferenced.

### 7.3 Historical Columns

Immutable SQLx migrations from earlier private builds may create columns such as
`sync_id`, `synced_at`, `sync_uuid`, or `cloud_blob_id`, and an upgraded database
may contain a historic `cloud://` placeholder. They are inert compatibility
artifacts: the consumer runtime does not populate or upload them, exposes no sync
route, and excludes non-filesystem placeholders from local media processing.
Previously shipped migrations are not rewritten because SQLx verifies their
checksums. Any future schema removal must use a forward migration after an
explicit upgrade-compatibility review.

### 7.4 Same-Computer Deduplication

Microphone, system-audio, and multiple-monitor capture can observe the same event
on one computer. Similarity and timestamp deduplication may combine those local
capture-source duplicates. This is local pipeline hygiene, not device-to-device
synchronization.

## 8. Non-Goals

- Changing the OCR engine (Apple Native is correct for macOS)
- Changing the video encoding format (FFmpeg H.265 is correct)
- Real-time streaming OCR (not needed — 0.5-1fps is sufficient for search)
- Cross-platform changes (this spec is macOS-focused; Windows pipeline may differ)
- Cross-device/cloud synchronization, hosted archive, and remote media retrieval
- Changing the DB schema beyond what's needed for pipeline correctness (sync columns already exist)
