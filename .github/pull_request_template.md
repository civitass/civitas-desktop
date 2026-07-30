## Outcome

What user problem does this change solve? Describe the observable result.

Closes #

## Scope

- Included:
- Deliberately excluded:

## Trust boundary

- [ ] No new capture, network host, credential, model, permission, MCP scope,
      update path, local API route, or external action.
- [ ] Or: every new boundary is listed below, tested, and documented in the
      network/privacy/model/threat documentation.

Boundary changes:

## Local-first and safety review

- [ ] Works without a Civitas account, hosted gateway, or bundled credits.
- [ ] Credentials never enter source, settings JSON, logs, URLs, fixtures,
      screenshots, exports, or frontend persistence.
- [ ] Captured content is treated as untrusted data.
- [ ] Answers and Next Actions preserve evidence, uncertainty, and abstention.
- [ ] No action executes without an explicit user request and review.
- [ ] Retention, deletion, migration, and rollback behavior is described.

## Verification

List exact commands and results:

```text
command
result
```

For Tauri commands or exported Rust types:

- [ ] `bun run bindings:generate` was run when required.
- [ ] `bun run bindings:check` passes.
- [ ] `bun run typecheck` passes.

## Visual evidence

For UI changes, attach only screenshots or recordings generated from explicit
synthetic fixtures. Include keyboard, reduced-motion, contrast, narrow-window,
empty, loading, error, and permission-denied states when relevant.

## Publication hygiene

- [ ] No personal/customer capture, real meeting material, credential, raw
      database, model weight, build output, or unredacted log is included.
- [ ] Third-party code, models, fonts, icons, datasets, and media have approved
      provenance, license, notice, immutable source, and checksum where needed.
- [ ] Source-file Civitas headers and public documentation are current.
- [ ] Remaining risks and follow-up work are stated below.

## Remaining risks

None / describe:
