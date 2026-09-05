# Next Actions — algorithm, design, and implementation record

> Status: implemented in 2.7.0. This document is the engineering reference for
> the pull-based Next Actions policy: how candidates are generated, ranked,
> suppressed, and presented, what was found wrong in the previous
> implementation, and exactly what changed. It extends
> [ADR 0010](adr/0010-v1-auto-suggest-contract.md) and §7 of the
> [publication plan](publication/PUBLICATION_PLAN.md); those remain the
> product contract.

## 1. What the feature is

Next Actions turns grounded local signals into reviewable hypotheses about what
the user might do next. It never executes, never notifies, never calls a model
while computing, and abstains when the evidence is thin. The surface is
pull-based: the user asks, Civitas answers from SQLite in one request.

The pipeline in `crates/civitas-engine`:

```
GET /next-actions
  └─ routes/next_actions.rs
       ├─ candidate generators (one SQL pass each, deterministic)
       │    memories → explicit-commitment · deadline · scheduled-preparation
       │                open-loop · user-routine
       │    saved_search_queries → saved-query
       │    graph_edges + semantic_actions → work-graph
       │    kg_claims (blocker + later state) → changed-blocker
       │    kg_claims (decision, no later state) → decision-follow-up   [new]
       │    semantic_actions.artifacts → open-thread                      [new]
       ├─ next_actions::rank_candidate  (pure, deterministic, unit-tested)
       ├─ deduplicate_ranked           (same context + canonical title)
       ├─ feedback suppression          (done / never / cooldowns, series-aware)
       ├─ sort · truncate · record_run  (content-free counters)
       └─ JSON: RankedNextAction[] + honest empty-state reason
```

Everything the ranker sees is a `CandidateInput`; everything the UI sees is a
`RankedNextAction`. The ranker is a pure function of `(input, now)`; the same
local database always yields the same ranking (asserted by the eval suite).

## 2. Screening of the previous implementation (2.6.x)

The 2.6.x policy was reviewed end to end: the pure ranker, all four generators,
the feedback and quality endpoints, the migrations, the UI panel, the unit and
route tests, the synthetic eval suite, and the documentation that describes the
feature. Findings, in priority order:

### 2.1 Correctness defects

| # | Finding | Effect | Fix |
| --- | --- | --- | --- |
| C1 | `Deadline` and `ScheduledPreparation` candidates used the memory's `updated_at` as `last_seen`. The ranker rejects anything whose `last_seen` is older than 45 days as `Stale`. | A deadline or meeting saved more than 45 days ahead of its date **never surfaces**, precisely when it becomes due. Anything saved 3–6 weeks ahead was also penalised on recency while it was most urgent. | For time-anchored sources, `last_seen` is now `min(now, anchor)`: an upcoming deadline is fresh, an overdue one fades naturally until it expires (§3.2). |
| C2 | `Done` on a commitment card only wrote feedback. The memory stayed an open commitment in Memories, and its `done` state lived in a table the user cannot see or edit. | Two sources of truth; the Memories list contradicted the Next Actions list. | The feedback request may carry `completesMemoryId`; a `done` on a user-authored memory appends the `done` tag in the same transaction (§4.2). |
| C3 | `Never show this` and `Done` were one click and permanent, with no undo. | A mis-click permanently silences a series. | Feedback returns its row id and can be reverted through `DELETE /next-actions/feedback/{id}` within the UI's undo window. Undo also removes a `done` tag it added (§4.3). |
| C4 | The confidence label `High` required either an explicit commitment or three evidence items. A user-authored deadline with a single memory row could never be `High`, although it is the most explicit signal the system has. | Calibration mislabelled the strongest class. | `High` requires `score ≥ 0.82` and (`user_authored` or ≥ 3 evidence). |

### 2.2 Coverage gaps in the algorithm

| # | Finding | Fix |
| --- | --- | --- |
| G1 | The only *learned* source (`work-graph`) depends on the Scribe having run an LLM. A local-only user with no provider gets nothing except their own typed commitments, so "predict the next move" degraded to a todo list. | New deterministic `open-thread` source mined from `semantic_actions.artifacts` (§3.4). No model, no provider, no network. |
| G2 | README and the publication plan list "decision follow-ups" as a candidate class; the code had none. Decisions are the highest-value unit in the knowledge graph and the most common open loop ("we decided X — did it happen?"). | New `decision-follow-up` source mirroring the changed-blocker join (§3.5). |
| G3 | `feedbackId ≠ candidateId` was permitted only for routines and saved queries, so no other recurring class could carry durable series feedback. | The per-occurrence/per-series split is now a property of the source (`open-thread` joins the list). |

### 2.3 Interaction and design findings (panel)

Reviewed against `DESIGN.md` and the Apple/animation heuristics referenced from
it (`emilkowalski/skills`):

| # | Finding | Fix |
| --- | --- | --- |
| U1 | Forced-uppercase "TODAY" eyebrow; `DESIGN.md` forbids forced uppercase labels. | Removed; sentence-case header. |
| U2 | Boxes inside boxes: card → tinted "why now" box → bordered evidence box → bordered popover. `DESIGN.md`: hairlines and whitespace, never nested boxes. | Cards are one surface; sections divide by hairlines. |
| U3 | The dismiss menu was a `<details>` with an absolutely positioned div: no keyboard navigation, no outside-click close, no focus management. | Radix `DropdownMenu` (already in the design system). |
| U4 | Cards vanished instantly on feedback; success toasts fired for every expected outcome. | Removal animates height/opacity over 180 ms `--ease-out` (`AnimatePresence`, disabled under reduced motion); expected outcomes render an inline confirmation with **Undo** instead of a toast. Toasts remain for errors only. |
| U5 | Leaving the section and returning reset the panel to the idle state and discarded the result the user had just pulled. | The last pull is kept for the session (`sessionStorage`, 30 min) and shown with "Checked N min ago"; the surface stays pull-based. |
| U6 | Native `<select>` elements used a 2 px focus ring; buttons mixed `rounded-lg` and `rounded-md` on the same row. | One control height (36 px), `rounded-md`, 1 px offset focus ring, consistent with `Button`. |
| U7 | Five rank-factor chips plus a sentence restating them. | One sentence; factor levels listed inline in the disclosure. |

### 2.4 What was right and is preserved

Pull-only default; deterministic ranking; sensitive-domain and secret-material
abstention before ranking; evidence pointers that must resolve; series-aware
feedback; content-free quality counters; the synthetic eval suite; every
`data-testid` the publication E2E journey depends on.

## 3. Candidate generation

Each generator answers three questions with local data only: *is this due*,
*what is the evidence*, and *what would make it wrong*. Generators return
`CandidateInput`s; they never rank.

### 3.1 Common contract

- `identity_key` groups semantically equivalent candidates in the same
  project/person/artifact context; `candidate_id = sha256(identity_key, canonical(title))`.
- `feedback_identity_key` (optional) is the durable series identity for
  recurring classes. `done` and `later` bind to the occurrence; `helpful`,
  `wrong`, and `never` bind to the series.
- `evidence[]` must be non-empty and each destination must be resolvable
  (`Memories`/`WorkGraph`/`SavedSearch` need a positive record id; `Timeline`
  needs an RFC 3339 timestamp).
- `user_authored` decides whether a sensitive-domain match is a hard abstention
  (inferred) or a `Review`-labelled, `explicit-review` card (authored).

### 3.2 Memory-backed sources (user-authored)

Rows from `memories` with `source = 'user'`, a candidate tag, and no closed tag
or closed `status`. Classification is by explicit metadata only:

| Tag / field | Source | Due window | `last_seen` | Expires |
| --- | --- | --- | --- | --- |
| `routine` + `nextAt` + `cadence` | `user-routine` | −36 h … +24 h around the occurrence | occurrence | occurrence + 36 h |
| `meeting-prep` / `calendar-prep` + `scheduledAt` | `scheduled-preparation` | −4 h … +72 h | **min(now, event)** | event + 4 h |
| `commitment` + `dueAt` | `deadline` | ≤ 14 days ahead | **min(now, due)** | due + 7 d |
| `open-loop` | `open-loop` | always | `updated_at` | `updated_at` + 21 d |
| `commitment` / `next-action` | `explicit-commitment` | always | `updated_at` | `updated_at` + 21 d |

The bold cells are the C1 fix. The anchor bound keeps recency truthful: a
deadline that is coming up is fresh regardless of when it was typed, and an
overdue deadline ages from its due time until it expires.

### 3.3 Saved-query follow-ups, work-graph transitions, changed blockers

Unchanged in policy. Saved-query follow-ups are opt-in and interval-bounded;
work-graph edges require ≥ 2 observations, confidence ≥ 0.72, ≥ 2 resolvable
grounding actions, and ≥ 2 operator steps; changed blockers require a grounded
active blocker and a later grounded state for the same subject with no
unresolved contradiction.

### 3.4 `open-thread` — where you left off (new, deterministic)

**Signal.** The mining crate already extracts structured artifact references
(`pull_request`, `issue`, `ticket`, `doc`, `file_path`, `branch`) from window
titles, URLs, and document paths, without a model and without reading typed
text. An artifact the user returned to across several sessions and then stopped
touching is an interrupted thread of work — the most literal form of "the
memory behind your next move".

**Generation.** One query over `semantic_actions` for the last 7 days with a
non-empty `artifacts` column (bounded at 4,000 rows, newest first). Artifacts
are parsed with the mining crate's own types. Per `(kind, value)` group:

1. keep artifacts with extraction confidence ≥ 0.6 and kind in
   {pull request, issue, ticket, doc, file path, branch}; `repo`, `url`,
   `channel`, and `email_thread` are excluded as too coarse or too personal;
2. split the group's actions into sessions at gaps > 45 minutes;
3. require ≥ 2 sessions, ≥ 3 actions, and a span ≥ 2 hours;
4. require the last action to be 2–72 hours old: newer means the thread is
   still active, older means it is no longer "where you left off";
5. build the label from the artifact itself (`pull request acme/api#123`,
   `ticket ENG-42`, the file name) or, for opaque document ids, from the most
   recent window title; a group without any usable label is rejected, never
   guessed.

Evidence is the actions themselves (up to 8 Timeline moments), so every card
opens the exact captured moments that produced it. Ranking inputs: strength
`0.72 + 0.06·(sessions−2) + 0.02·min(actions−3, 5)` capped at 0.92,
explicitness 0.5, urgency 0.72/0.62/0.52 by age bucket, relevance 0.7 (1.0
when the requested context entity names the artifact), effort 15 min,
reversibility 1.0, occurrences = sessions, expiry `last + 5 days`. The identity
key carries the day of the last action so `done` closes this thread while
`never` silences the artifact for good. Output is capped at 12 candidates
before ranking.

**Privacy.** The source reads only rows the Timeline already shows, uses
structured fields (never `text_sample`), and runs the same secret-material and
sensitive-domain filters on the label, title, and evidence labels as every
other inferred source. A window title that names a bank account, a diagnosis,
or an employment decision is an abstention, not a card.

### 3.5 `decision-follow-up` — a decision without recorded follow-through (new)

**Signal.** `kg_claims` rows with `claim_type = 'decision'` recorded 1–14 days
ago for a resolved subject, with no later `state` claim for that subject. This
is the mirror image of `changed-blocker` (blocker **with** a later state).

**Gating.** confidence ≥ 0.72; not invalidated, superseded, or under review;
attributed to a transcript (`transcript_speaker` / `transcript`) — decisions the
user was party to — or to the screen only when a verbatim rationale was captured
and confidence ≥ 0.8; an evidence pointer must exist; no unresolved
contradiction may involve the claim. Evidence is the claim plus the captured
moment (the source episode's start, or the grounding actions); a claim whose
moment cannot be resolved is rejected.

Ranking inputs: strength = claim confidence, explicitness 0.6, urgency 0.58 /
0.66 / 0.60 for ≤ 3 d / ≤ 7 d / ≤ 14 d, relevance 0.72 (1.0 on context match),
effort 15 min, reversibility 1.0, expiry `recorded_at + 21 d`. The identity key
is the subject entity, so a decision and a blocker with the same canonical
title collapse into one card with two supporting sources.

## 4. Ranking, suppression, and feedback

### 4.1 Score

Unchanged weights, all interpretable and shown in the card's disclosure:

```
score = 0.25·evidence + 0.20·explicitness + 0.14·urgency + 0.13·relevance
      + 0.10·recency + 0.08·effort_fit + 0.06·reversibility
      + 0.04·(1 − interruption_cost) − ambiguity_penalty − risk_penalty
```

Hard gates before scoring: title ≥ 5 chars and not a stock vague phrase; no
secret material anywhere in the text; sensitive domain ⇒ abstain unless
user-authored; `last_seen` ≤ 45 days; not expired; per-source evidence minima
(§3). `score < 0.60` ⇒ `LowConfidence` rejection. Labels: `High` at ≥ 0.82
with a user-authored or ≥ 3-evidence candidate, `Supported` at ≥ 0.64,
otherwise `Review`; a sensitive user-authored candidate is always `Review`.

Inferred sources (`work-graph`, `changed-blocker`, `open-thread`,
`decision-follow-up`) all require strength ≥ 0.72 and ≥ 2 evidence items;
`work-graph` and `open-thread` additionally require ≥ 2 observations, and
`work-graph` ≥ 2 operator steps.

### 4.2 Feedback

`POST /next-actions/feedback` accepts `candidateId`, optional `feedbackId`
(series), `source`, `action`, and optional `completesMemoryId`. Cooldowns:
`later` 1 day, `dismiss`/`not-useful` 30 days, `wrong` 90 days, `done`/`never`
permanent. `helpful` adds +0.08 to later scores of the same series.

When `action = done` and `completesMemoryId` names a user-authored memory that
carries a candidate tag, the `done` tag is appended inside the same immediate
transaction and the feedback row records `completed_memory_id`. The Memories
list and Next Actions therefore agree.

### 4.3 Undo

`DELETE /next-actions/feedback/{id}` removes exactly one feedback row and, if
that row completed a memory, removes the `done` tag it added. The response
carries the feedback row id so the UI can offer a bounded undo. Nothing else
about a row can be edited; there is no bulk delete.

### 4.4 Schema

Migration `20260904000000_next_action_feedback_v4.sql` rebuilds
`next_action_feedback` with the two new `source_kind` values and a nullable
`completed_memory_id` column, preserving every existing row. The quality
endpoint and its counters are unchanged.

## 5. Interface

The panel (`components/next-actions/next-actions-panel.tsx`) is one continuous
surface in the app shell; nothing floats except the Radix menu.

- **Header.** "Next actions", one sentence, and two controls: *Add commitment*
  (outline) and *Show next actions* / *Refresh* (primary). A quiet trust line
  states: evaluated locally · ambient off · nothing executes · checked N min
  ago.
- **Idle.** A single centered statement that nothing runs until asked. Once
  the user has pulled, the result persists for the session (30 min) and the
  panel reopens on it instead of the idle state.
- **Card.** Rank ordinal in a 32 px well; title (17 px semibold, −0.018 em);
  one-line summary; a meta line (source · confidence · effort). "Why now" is a
  labelled paragraph, not a box. Steps are a numbered list. *Evidence and
  limits* is a disclosure separated by a hairline: evidence rows open their
  exact local surface, followed by the uncertainty sentence and the rank
  explanation with factor levels inline. The footer row holds quiet feedback
  controls (Done · Later · More ▾ → Not useful now / Wrong inference / Never
  show this) and the primary *Prepare in Ask*.
- **Motion.** Enter: 150 ms opacity. Remove: 180 ms height + opacity,
  `--ease-out`, interruptible; under `prefers-reduced-motion` state changes are
  immediate. Press feedback is the design-system 150 ms scale response. No
  scale-from-zero, no `transition-all`.
- **Feedback affordance.** Done/Later/Dismiss replace the card with a slim
  inline row ("Marked done · Undo") for six seconds, then collapse. Helpful
  stays inline on the card. Errors use the destructive toast and restore the
  card.
- **Composer.** Same fields and test ids as before, on one 36 px control
  height with a 1 px offset focus ring; native `<select>` retained for the
  E2E driver.

## 6. Evaluation

- `crates/civitas-engine/src/next_actions.rs` unit tests: determinism,
  sensitive/secret abstention, staleness, expiry, and the new
  time-anchored freshness case (deadline saved 50 days ahead, due tomorrow).
- `crates/civitas-engine/src/routes/next_actions.rs` unit tests: source
  classification, series identities, the open-thread sessioniser and label
  rules, decision follow-up gating.
- `crates/civitas-engine/tests/next_actions_eval.rs` route tests on a migrated
  in-memory database: cold abstention, contradiction abstention and recovery,
  never-feedback across occurrences, saved-query opt-in, dedup/safety/latency
  gates, and new cases for `open-thread`, `decision-follow-up`, `done` memory
  completion, and undo.
- `components/next-actions/next-actions-panel.test.tsx`: pull-only default,
  exact data boundaries, evidence navigation, saved-query reopen, composer
  request shape, optimistic restore on failure, undo, empty state.
- The publication E2E journey (`e2e/specs/publication-demo.spec.ts`) drives the
  real panel with synthetic commitments and is unchanged.

Release budgets remain: route latency < 2 s cold on the synthetic database,
zero duplicate titles, zero sensitive-surface violations, low-risk precision
≥ 0.90.

## 7. Non-goals in this release

- Ambient delivery stays off and unimplemented in the consumer build.
- No LLM participates in candidate generation or ranking.
- No new network destination, permission, or downloaded asset.
- Meeting transcripts are not mined for action items by regex; commitments
  spoken in meetings reach Next Actions only through grounded knowledge-graph
  claims (decisions) with the gating above.
