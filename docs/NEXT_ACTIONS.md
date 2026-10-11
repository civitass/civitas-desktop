# Next Actions — algorithm, design, and implementation record

> Status: implemented in 2.7.0; extended in 2.8.0 (§2.5, §3.4, §3.6, §4.1,
> §4.5, §4.6). This document is the engineering reference for
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
       │    kg_claims (decision, no later state) → decision-follow-up
       │    semantic_actions (artifact · file · window-title contexts)
       │                                → open-thread + thread summaries   [2.8.0]
       ├─ corroborate_with_threads      (typed commitment × captured work) [2.8.0]
       ├─ next_actions::rank_candidate  (pure, deterministic, unit-tested)
       ├─ deduplicate_ranked           (same context + canonical title)
       ├─ feedback suppression          (done / never / cooldowns, series-aware)
       ├─ per-source feedback prior     (bounded ±0.08, ≥ 3 ratings)       [2.8.0]
       ├─ sort · truncate · record_run  (content-free counters + shown ledger)
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

### 2.5 Screening of 2.7.0 against real capture data (2.8.0)

The 2.7.0 policy was correct but under-powered on the data Civitas actually
collects. Profiling a real, several-week local database read-only (aggregate
shape only; nothing was copied out of SQLite) showed:

| Observation | Consequence for 2.7.0 |
| --- | --- |
| ~4,000 captured actions per day, all `clicked` / `switched_to` | The 4,000-row budget covered about one day, so the 7-day "≥ 2 sessions" gate was rarely satisfiable. |
| Structured artifacts on ~10 % of rows; URLs never populated; window titles on ~89 % | `open-thread` saw a tenth of the work; the thread a person actually left is usually named only by a window title. |
| Zero user-authored memories, zero feedback rows | The user-authored sources and the feedback loop were idle; nothing learned. |
| Four decisions, one graph edge | `decision-follow-up` and `work-graph` are correct but produce almost nothing early on. |
| Pairwise "context A then context B" probabilities of 0.05–0.20, dominated by navigation noise | A context-transition predictor would not clear the 0.72 strength gate honestly; it was **not** built (§7). |

Findings, in priority order, and the 2.8.0 change for each:

1. **Threads were invisible without artifacts** → thread contexts now come from
   artifacts, then file names, then normalised window titles (§3.4), over a
   10-day, 60,000-row budget.
2. **Typed commitments and captured work never met** → a commitment whose words
   match a thread is corroborated by the thread's captured moments and merges
   into one card with both sources (§3.6).
3. **Feedback only ever silenced** → ratings now also move later scores of the
   same source class, bounded and explained (§4.5).
4. **Confidence labels were never checked** → each pull writes a content-free
   ledger of what it showed, and the quality report measures how often `High`,
   `Supported`, and `Review` cards were kept (§4.6).
5. **Guarded terms were charged twice** → the `Review` label already flags a
   guarded (non-sensitive) domain; the score penalty is now a nudge (§4.1).

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

### 3.4 `open-thread` — where you left off (deterministic; widened in 2.8.0)

**Signal.** A piece of work the user returned to across several sessions on
several days and then stopped touching is an interrupted thread — the most
literal form of "the memory behind your next move". In 2.7.0 a thread had to be
a structured artifact. Real capture rarely carries one (§2.5), so 2.8.0 names a
thread by the strongest of three **contexts**, in order:

| Context | Key | Label | Source fields |
| --- | --- | --- | --- |
| Artifact | `artifact:{kind}:{value}` | `pull request acme/api#123`, `ticket ENG-42`, … | `artifacts` (pull request, issue, ticket, doc; confidence ≥ 0.6) |
| File | `file:{basename}` | `file main.pdf` | `document_path` basename, unless digit-heavy |
| Title | `title:{normalised}` | `“main.pdf”` | `window_title` after `normalize_window_title` |

Rows from Civitas' own windows are never contexts. Title normalisation collapses
whitespace, strips up to two trailing `" — App"` / `" - Folder"` / `" | Site"`
segments (separators `—`, `–`, `-`, `|`, `•`, `·`; tail 1–48 characters), trims
punctuation, and then **rejects** the title if it is shorter than 6 characters,
equals the app name, is a generic place (`Inbox`, `New tab`, `Settings`,
`Downloads`, `Messages`, `Calendar`, and their Chinese equivalents, with or
without a count suffix), is digit-heavy (half or more of the alphanumeric
characters are digits: ids, phone numbers, timestamps), or looks like an email
address. Titles are capped at 100 characters. Because the key is the normalised
title, the same document seen in two apps (`main.pdf — thesis` in an editor,
`main.pdf` in a viewer) is one thread, and the card names both apps.

**Generation.** One query over `semantic_actions` for the last 10 days with a
non-empty `app_name` (bounded at 60,000 rows, newest first — about two weeks of
a busy day at ~4,000 actions/day). Per context key:

1. split the actions into sessions at gaps > 45 minutes and keep only
   *substantial* sessions (≥ 2 actions or ≥ 30 seconds), so a single passing
   click does not count as a return;
2. require ≥ 2 sessions, ≥ 3 actions, a span ≥ 2 hours, and ≥ 2 distinct days;
3. require the last action to be 2–96 hours old: newer means the thread is
   still active, older means it is no longer "where you left off" (96 h rather
   than 72 h so a thread left on Friday survives to Tuesday);
4. build the label from the context (artifact, file name, or quoted title) or,
   for opaque document ids, from the most recent window title; a group without
   an honest label is rejected, never guessed.

Evidence is the actions themselves (up to 8 Timeline moments), so every card
opens the exact captured moments that produced it. Ranking inputs: strength
`0.72 + 0.02·[artifact or file] + 0.06·(sessions−2) + 0.02·min(actions−3, 5)`
capped at 0.92, explicitness 0.5, urgency 0.72/0.62/0.52 for ≤ 24 h / ≤ 48 h /
older, relevance 0.7 (1.0 when the requested context entity names the key),
effort 15 min, reversibility 1.0, occurrences = sessions, expiry `last + 5 days`.
The identity key carries the day of the last action so `done` closes this
thread while `never` silences the context for good. Output is capped at 12
candidates before ranking. On the profiled database this yields a mean of
about 2.6 thread candidates per pull (maximum 11 before the cap).

The generator also returns a **thread summary** for every named context that
has at least one substantial session, whether or not it clears the idle and
volume gates. Summaries carry only the key, label, significant tokens,
counts, last-seen time, and up to three evidence pointers; §3.6 uses them.

**Privacy.** The source reads only rows the Timeline already shows, uses
structured fields and window titles (never `text_sample`), and runs the same
secret-material and sensitive-domain filters on the label, title, summary,
and evidence labels as every other inferred source. A window title that names
a bank account, a diagnosis, or an employment decision is an abstention, not a
card. Digit-heavy and address-like titles are dropped before they can name a
person.

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

### 3.6 Corroboration — typed commitments × captured work (2.8.0)

A commitment the user typed and the work Civitas captured are two views of the
same intent. When they agree, the card should say so and carry both kinds of
evidence; when they do not, nothing changes.

For every user-authored candidate from `explicit-commitment`, `deadline`,
`scheduled-preparation`, or `open-loop`, the title and summary are reduced to
*significant tokens*: lower-cased ASCII words of ≥ 4 characters that are not
stop words (articles, pronouns, and the verbs commitments are written with —
`prepare`, `draft`, `review`, `finish`, `send`, …), plus character bigrams for
CJK text. A thread summary corroborates the candidate when the two token sets
share ≥ 2 tokens, or share one token that looks like an identifier
(`ENG-42`, `acme/api#123`, `v2.8.0`). Among matching threads the one with the
most sessions, then the most recent, wins.

On a match the commitment gains: a sentence appended to *why now* ("Captured
work matching this: 2 sessions on 2 days recently, last 6 h ago (“atlas launch
brief.md”)."), up to three `captured-work` evidence rows that open the exact
Timeline moments, relevance 1.0, and +0.05 strength. If the matching thread is
itself an `open-thread` candidate this pull, it takes the commitment's identity
key and title so the deduplicator merges the two into **one** card whose
`supportingSources` lists both; the merged card keeps the commitment's series
identity, so `done` still completes the memory the user wrote.

Corroboration never creates a card, never lowers a score, and never runs on
inferred sources (a thread cannot corroborate itself).

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

`risk_penalty` is 0.30 for a sensitive domain (only user-authored candidates
survive to be scored) and, since 2.8.0, 0.06 rather than 0.12 for a *guarded*
term (`production`, `deploy`, `payment`, `contract`, …). A guarded candidate is
already forced to the `Review` label, so the previous penalty charged the same
signal twice and pushed ordinary engineering commitments ("Prepare the
production deploy checklist") under the 0.60 gate. The label, not the score,
is the safety control, and it is unchanged.

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
`completed_memory_id` column, preserving every existing row.

Migration `20260919000000_next_action_shown.sql` (2.8.0) adds
`next_action_shown(run_id → next_action_runs, candidate_id, source_kind,
confidence_label, score, rank, created_at)`: one row per card a pull actually
returned. It stores no title, evidence, prompt, or captured content; candidate
ids are already deterministic hashes of local ids. Rows cascade with their run.
Shadow pulls write no ledger rows.

### 4.5 Per-source feedback prior (2.8.0)

Before 2.8.0 feedback could only silence: a cooldown or a permanent stop on one
candidate or series, plus a fixed +0.08 for `helpful`. Nothing generalised. Now,
after feedback suppression and before sorting, each remaining card receives a
bounded shift from the owner's record on its **source class**:

```
latest rating per candidate_id, grouped by source_kind
positive = helpful + done          negative = dismiss + not-useful + wrong + never
rated    = positive + negative     (skip the class while rated < 3)
kept_rate = (positive + 2) / (rated + 4)             # Beta(2,2) posterior mean
shift     = clamp((kept_rate − 0.5) · 2 · 0.08, −0.08, +0.08)
score     = clamp(score + shift, 0, 1)
```

Properties, all asserted by tests: no effect below three ratings; a class the
owner keeps 30 of 30 times gains ≈ +0.07, one dismissed 3 of 3 times loses
≈ −0.05, and no record can move a score by more than 0.08 — never enough to
turn a rejected candidate into a card (rejection happens before this step) or
to change a label's meaning. The shift is transparent: the rank explanation
gains "· your feedback on this kind: kept 28 of 31". `done` and `never` remain
permanent suppressions; the prior only reorders what survives.

### 4.6 Calibration (2.8.0)

`GET /next-actions/quality` now also returns `calibration[]`: for each label
shown at least once — `High`, `Supported`, `Review` — the number of distinct
candidates shown, how many the owner later rated, how many of those were kept
(`helpful`/`done`), and `keptRate`. The counts join `next_action_shown` with
the latest rating per candidate, so the report answers the question the label
implies: *are `High` cards actually kept more often than `Supported` ones?* If
they are not, the thresholds in §4.1 are wrong for this owner and the numbers
say so locally. The response remains free of candidate ids, titles, and
content, and the existing `insufficient-data` / 80 % helpfulness gate is
unchanged.

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
  sensitive/secret abstention, staleness, expiry, and the time-anchored
  freshness case (deadline saved 50 days ahead, due tomorrow). All ranker tests
  run against a fixed clock (`fixture_now`, 2026-07-26) so the July fixtures
  cannot age into `Stale` and fail on a later date.
- `crates/civitas-engine/src/routes/next_actions.rs` unit tests: source
  classification, series identities, the open-thread sessioniser and label
  rules, window-title normalisation (segment stripping, generic and
  digit-heavy rejection, cross-app merging, Civitas' own windows ignored),
  corroboration (shared tokens, identifiers, CJK bigrams, merged card with two
  sources), the bounded and transparent feedback prior, and decision follow-up
  gating.
- `crates/civitas-engine/tests/next_actions_eval.rs` route tests on a migrated
  in-memory database: cold abstention, contradiction abstention and recovery,
  never-feedback across occurrences, saved-query opt-in, dedup/safety/latency
  gates, `open-thread` from artifacts and from bare window titles across two
  apps, a commitment corroborated by captured work merging into one card,
  `decision-follow-up`, `done` memory completion, undo, and the feedback prior
  plus calibration report (shown ledger written, class prior lowers a score by
  ≤ 0.08 with the reason shown, `High` bucket kept 1 of 1, no ids disclosed).
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
- **No context-transition predictor** ("after A you usually open B"). It was
  designed and measured against real capture before 2.8.0 and rejected: with
  ~4,000 clicks and switches a day, the conditional probability of any
  specific next context after a given one was 0.05–0.20 and dominated by
  navigation noise (launcher, browser chrome, messaging). A source that cannot
  reach the 0.72 strength gate honestly would either be rejected on every pull
  or need its gate lowered, and the second option is exactly the kind of guess
  this feature promises not to make. Thread contexts (§3.4) capture the
  useful part of the same signal — what the user keeps returning to — with
  evidence the card can show.
- No text embeddings or semantic similarity in corroboration (§3.6); token
  overlap is deterministic, explainable, and needs no model or download.
