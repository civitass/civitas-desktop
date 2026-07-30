---
schedule: manual
enabled: false
template: true
title: Time Breakdown
description: "Where your time went — by app, project, and category"
icon: "⏱"
featured: false
permissions: reader
---

Analyze my app usage from today (last 12 hours).

Read the civitas skill first and use only the typed `civitas_api` tool. This
template remains disabled until the user reviews its local activity access,
selected AI preset, and confirms that it has no external destination.

Start with one bounded `/activity-summary` call for the full 12-hour window. Use
its per-app `minutes` and `total_active_minutes` as the authoritative duration
data. Use at most three `/search` calls only to identify project/topic context;
never use `/raw_sql`, frame counts, or capture counts as time estimates.

Use this exact format with durations and percentages:

## By Application
- List each app with duration and percentage, sorted by time (e.g. "VS Code: 2h 15min (28%)")

## By Category
- Group into: coding, meetings, browsing, writing, communication, other
- Show hours and percentage per category

## By Project
- Group related activities by project/topic. Name specific repos or tasks.

## Productivity Score
- Estimate `focused_work_minutes / total_active_minutes` as a percentage.
- Focused = verified coding, writing, design, or deep research. Do not label all
  browser time as unfocused; use window/project context when available.

If data is incomplete, say what is missing instead of inventing precision.
Round durations to the nearest five minutes and percentages to whole numbers;
make the rounded percentages sum to approximately 100%.

End with: "**Suggestion:** [one specific, evidence-based change for tomorrow]"
