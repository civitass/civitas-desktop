# Civitas Coverage

Civitas tracks coverage at two complementary layers:

- Tauri/WebDriver E2E coverage: real product UX and local API behavior by platform.
- Core engine coverage: Rust behavioral flow coverage across capture, audio, DB, accessibility, and engine crates.

These dashboards are behavioral maps, not a replacement for line or branch coverage.
Use them to see which product risks are represented, then layer runtime job
results and `cargo llvm-cov` data on top when judging release confidence.

## Dashboards

- E2E dashboard: [apps/civitas-app-tauri/e2e/COVERAGE.md](apps/civitas-app-tauri/e2e/COVERAGE.md)
- Core engine dashboard: [coverage/CORE.md](coverage/CORE.md)

## Current Snapshot

### Tauri E2E

- Mapped specs: 41
- Declared test blocks: 153
- Weighted coverage points: 120.9

| Platform | Specs | Declared tests | Weighted points | Layers | Features | Critical score |
| --- | --- | --- | --- | --- | --- | --- |
| windows | 35 | 143 | 117.7 | 14 | 44 | 92% |
| macos | 38 | 120 | 94.5 | 13 | 45 | 86% |
| linux | 32 | 110 | 91.3 | 12 | 42 | 86% |

### Core Engine

- Mapped suites: 27
- Mapped Rust files: 228
- Active test blocks: 1961
- Ignored/manual test blocks: 121
- Weighted coverage points: 1681.9

| Platform | Suites | Active tests | Ignored tests | Weighted points | Layers | Flows | Critical score |
| --- | --- | --- | --- | --- | --- | --- | --- |
| windows | 24 | 1872 | 108 | 1640.5 | 22 | 13 | 100% |
| macos | 24 | 1912 | 97 | 1651.4 | 23 | 13 | 100% |
| linux | 22 | 1857 | 84 | 1627.0 | 21 | 13 | 100% |

## Refresh

From `apps/civitas-app-tauri`:

```bash
bun run coverage:all
bun run coverage:all:check
```

For core line coverage, install/use `cargo llvm-cov` and feed its JSON
summary into `coverage:core`; the core dashboard documents the exact command.
