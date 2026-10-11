# Local knowledge quality and performance evaluation

Civitas evaluates its personal knowledge graph with synthetic data only. The
public release gate never requires a user's capture, transcript, screenshot,
credential, or database.

The evaluation exercises the same migrated SQLite database, write methods, FTS
triggers, CJK shadow tokens, and read methods used by the desktop application.
It is a regression gate for system behavior, not a claim that synthetic
fixtures predict every person's workflow.

## Quality gates

Run the non-timing quality gate on every release candidate:

```bash
cargo test --locked -p civitas-db --test knowledge_quality_eval \
  synthetic_graph_quality_meets_release_gates -- --exact
```

Every fixture declares `synthetic_fixture: true`. The test currently requires:

- 100% top-one recall for the deliberately unambiguous labeled queries;
- 100% provenance completeness for provider, model, runtime, prompt/schema and
  extractor versions, evidence pointer/type/count, attribution source,
  confidence, recorded time, validation status, and provenance state;
- invalidated claims never appearing in active results;
- claims below `0.6` confidence being marked for review;
- people who share a first name remaining distinct without an explicit
  correction;
- Simplified Chinese, Traditional Chinese, and configured aliases resolving
  through the local FTS path.

These are minimum safety and contract gates. A passing result does not justify
silently merging ambiguous people or presenting an ungrounded answer. New
languages, entity types, extraction versions, and retrieval strategies should
add labeled cases before their behavior is advertised.

## Reproducible performance gate

Run the explicit timing/storage gate on each supported release architecture:

```bash
cargo test --locked -p civitas-db --test knowledge_quality_eval \
  synthetic_graph_latency_and_storage_meet_release_budgets \
  -- --exact --ignored --nocapture --test-threads=1
```

The harness creates an isolated, migrated temporary database, inserts 1,000
synthetic claims through the production repository method, warms the FTS read
path, measures 100 bounded queries, checkpoints SQLite, and reports:

- operating system and architecture;
- logical CPU count;
- cold-start migration time;
- p50 and p95 local query latency;
- database bytes and bytes per synthetic claim.

It removes the temporary database when the test exits. It does not write a
benchmark report into the repository.

The initial release budgets are:

| Measure | Budget |
| --- | ---: |
| Migrated cold start | at most 5 seconds |
| Local FTS query p50 | at most 50 ms |
| Local FTS query p95 | at most 150 ms |
| SQLite storage per synthetic claim | at most 48 KiB |

Record the emitted line with the release evidence for each architecture.
Compare like-for-like builds and hardware; do not hide outliers by discarding
runs. If the result fails, investigate query plans, migration work, WAL growth,
and index duplication before changing a budget. Any budget change needs an
explanation in the pull request and a corresponding update to this document and
the test constants.

## Interpreting results

Quality metrics must be considered together with the grounded Ask contract,
correction tests, deletion propagation, and adversarial Next Actions corpus.
Latency alone is not success if a result loses its source, crosses a privacy
boundary, or collapses two people. Recall alone is not success if invalidated
or unrelated claims are returned.

For a publication candidate, retain the command, commit, platform, build
profile, hardware summary, and emitted metrics in the private release evidence.
Do not commit personal databases or ad hoc audit output.
