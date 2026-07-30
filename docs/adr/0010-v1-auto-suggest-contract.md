# ADR 0010 — Next actions are grounded hypotheses

## Status

Accepted

## Context

An earlier predictive-action implementation mixed useful pattern recognition
with interruption and execution machinery. For a personal memory product,
confident but weakly grounded suggestions are worse than silence.

## Decision

The public feature is **Next actions**:

- It is pull-based by default. Ambient suggestions require a separate opt-in.
- Deterministic local signals generate candidates before any model ranks or
  rewrites them.
- Each suggestion includes “why now,” source evidence, confidence, and the
  conditions that would make it wrong.
- Low-confidence, stale, duplicate, sensitive, or unsupported candidates are
  suppressed.
- The model may summarize or rank evidence but cannot invent a task outside the
  candidate/evidence set.
- No suggestion executes automatically. External communication, file mutation,
  credential use, purchase, or deletion requires a fresh preview and explicit
  approval in the surface that performs the action.
- Dismissals, corrections, and outcomes stay local and influence later ranking.
- Launch-quality reporting uses only local aggregate counters, counts the latest
  rating for each stable candidate once, and does not expose candidate content
  or identifiers.
- Evaluation prioritizes precision, calibration, evidence coverage, and
  interruption cost over suggestion volume.

## Consequences

The restored historical code is design evidence rather than a wholesale
revert. Operator and background computer-control code are not part of the
consumer publication. When no grounded action clears the threshold, the correct
result is an empty state that explains Civitas is waiting for stronger evidence.
