# NOTICE — Provenance and Third-Party Attribution

## Fork provenance

Civitas is a fork of **Screenpipe** (https://github.com/screenpipe/screenpipe),
taken at upstream commit `892199f742e46d0c5d9e8c06687b35ca7c2b6547`
(2026-06-10), which is the last upstream commit released under the MIT
license — Copyright (c) 2024-2026 louis030195.

Upstream commits after that point were relicensed by Mediar, Inc. under the
proprietary "Screenpipe Commercial License" and are **not** included in this
codebase. The upstream `ee/` directory ("Screenpipe Enterprise Edition",
licensed under the proprietary Screenpipe Enterprise License) has been removed
in full. The Civitas consumer build contains no enterprise control plane.

The upstream MIT copyright notice is retained in [LICENSE.md](LICENSE.md) as
required by the MIT license. "Screenpipe" and "screenpi.pe" are marks of their
respective owner; Civitas is an independent consumer product and is not
affiliated with or endorsed by Mediar, Inc.

## Other third-party software

This project depends on third-party open-source packages declared in
`Cargo.toml`, `package.json`, and lockfiles; each is governed by its own
license. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Every release
also carries an SPDX JSON SBOM generated from the exact release commit.
