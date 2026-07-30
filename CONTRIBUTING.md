# Contributing to Civitas Desktop

Thank you for helping build a trustworthy personal work memory. Privacy,
groundedness, and user control are product requirements, not optional polish.

Start with the
[consumer publication plan](docs/publication/PUBLICATION_PLAN.md), the
[threat model](docs/THREAT_MODEL.md), and an issue before beginning a large
change.

## Development setup

Required:

- Rust `1.93.1` (pinned by `rust-toolchain.toml`);
- Bun `1.3.10`;
- platform build tools;
- FFmpeg;
- Tesseract and the platform libraries listed in [README.md](README.md).

```bash
git clone https://github.com/civitass/civitas-desktop.git
cd civitas-desktop
cargo build

cd apps/civitas-app-tauri
bun install
bun tauri dev
```

Never use real personal capture, customer data, production credentials, or
private meeting material in a test or documentation example. Use generated
synthetic fixtures and mark them as synthetic.

## Focused checks

Run the smallest relevant checks while iterating, then the broader checks
before requesting review:

```bash
# Rust formatting and focused tests
cargo fmt --all -- --check
cargo test -p <changed-crate>

# Desktop frontend
cd apps/civitas-app-tauri
bun run typecheck
bun run test

# Generated Tauri bindings
bun run bindings:check
```

Consult `AGENTS.md` and nested instructions for additional required commands.
High-risk capture, storage, provider, update, and permission changes require
platform-specific integration tests.

## Change requirements

- Preserve source/evidence provenance in knowledge features.
- Prefer abstention to an ungrounded personal-history answer.
- Keep capture and network behavior explicit.
- Do not add a new outbound host without updating the network inventory, user
  disclosure, endpoint policy, and deny-network tests.
- Do not place API keys in frontend state, settings JSON, source, fixtures,
  snapshots, logs, or issue text.
- Do not weaken Tauri capabilities, CSP, loopback authentication, update
  verification, or consent to make a test pass.
- Treat captured content as untrusted data, never as tool instructions.
- Add the repository-required Civitas header to every source file you create or
  edit.

## Pull requests

A pull request should include:

- the user problem and scope;
- privacy and network impact;
- migration and rollback behavior;
- tests run and their results;
- screenshots using synthetic data for UI changes;
- documentation updates;
- remaining risks.

Keep unrelated formatting and generated-file churn out of the change. A
maintainer may request a threat-model update or additional release testing for
security-sensitive work.

## Security

Do not disclose a suspected vulnerability in a public issue. Follow
[SECURITY.md](SECURITY.md).

By participating, you agree to [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
