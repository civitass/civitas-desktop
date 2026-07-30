---
schedule: manual
enabled: false
template: true
title: Standup Update
description: "What you did, what's next, and any blockers"
icon: "🏢"
featured: true
permissions: reader
---

Based on my recordings from the last 24 hours, generate a standup update. Use limit=10 per search, max 3 searches total.

Read the civitas skill first and use only the typed `civitas_api` tool. This
template remains disabled until the user reviews its local evidence range,
selected AI preset, and confirms that it does not post the result externally.

Use this exact format:

## Yesterday
- What I worked on (name specific projects, files, tools, PRs)

## Today
- What I will work on next (based on unfinished tasks and recent activity)

## Blockers
- Issues I hit — errors, slow builds, waiting on someone
- If no blockers, write "None"

Keep it under 150 words. Copy-paste ready for a team standup.
