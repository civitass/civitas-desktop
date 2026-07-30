# ADR 0001 — Fork Provenance and Licensing

## Status

Accepted

## Context

Civitas is derived from Screenpipe, an open-source screen capture and local AI memory application. Screenpipe was released under the MIT license through upstream commit `892199f742e46d0c5d9e8c06687b35ca7c2b6547` (2026-06-10). After that commit, the upstream repository was relicensed by Mediar, Inc. under a proprietary "Screenpipe Commercial License." Upstream commits after `892199f7` are not MIT and cannot be incorporated.

The upstream codebase included an `ee/` directory ("Screenpipe Enterprise Edition") licensed under a separate proprietary "Screenpipe Enterprise License." This directory is not MIT and cannot be forked or adapted.

The Civitas project needs:
1. A clear, factual statement of where the codebase comes from and what license it carries.
2. A clean boundary between MIT-licensed upstream code, removed proprietary code, and original Civitas implementation.
3. Compliance with the upstream MIT license (attribution requirement).

## Decision

- The Civitas codebase is an MIT snapshot of Screenpipe at commit `892199f7`. All code in this repository at or before that commit was MIT-licensed.
- The upstream `ee/` directory has been removed in its entirety. No code from `ee/` is present in this repository.
- The consumer publication tree excludes the former operator, fleet,
  enterprise-policy, team-memory, hosted control-plane, and remote-sync
  implementations. Their private archives are not a source for public code.
- The upstream MIT copyright notice (Copyright (c) 2024-2026 louis030195) is retained verbatim in `LICENSE.md` as required by the MIT license.
- `NOTICE.md` documents fork provenance, the upstream commit, and third-party attribution including the open-codex-computer-use algorithm adapted for the operator engine.
- The product is rebranded as Civitas. Crates are prefixed `civitas-*` where new crates are introduced. The data directory is `~/.civitas`. Environment variables use `CIVITAS_*`. The domain is `civitas.team`. The app identifier is `team.civitas.app`.
- "Screenpipe" and "screenpi.pe" are marks of Mediar, Inc. Civitas is not affiliated with or endorsed by Mediar, Inc.

## Consequences

- Any future incorporation of upstream Screenpipe code must verify it originates from a commit at or before `892199f7`.
- The `ee/` directory must not be recovered via git history for any purpose. Clean-room boundary is enforced by policy.
- Contributors must not copy code from post-relicense Screenpipe or from the removed `ee/` directory.
- The `LICENSE.md` and `NOTICE.md` files must not be modified except to add required new third-party attribution.
- When the upstream MIT codebase is referenced in documentation or comments, use the upstream commit hash and the upstream repo URL (`https://github.com/screenpipe/screenpipe`). Do not imply affiliation.
