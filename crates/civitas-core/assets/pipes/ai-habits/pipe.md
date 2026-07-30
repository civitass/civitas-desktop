---
schedule: manual
enabled: false
template: true
title: AI Habits
description: "How you use AI tools — patterns and insights"
icon: "🤖"
featured: true
permissions: reader
---

Review my recordings from the last 24 hours for AI-tool usage. Make at most six
bounded searches total. For native apps, use a matching `app_name`; for tools
used in a browser, use an AI-specific `window_name` such as ChatGPT, Claude,
Gemini, or Perplexity. Request `content_type=accessibility` first and use OCR
only when accessibility evidence is absent. Use `limit=8`.

Read the civitas skill first and use only the typed `civitas_api` tool. This
template remains disabled until the user reviews its time range, local data
access, selected AI preset, and confirms that it has no external destination.

Use this exact format:

## AI Tools Used
- List each verified tool. Estimate a time range only from timestamped activity
  intervals, split sessions at gaps longer than five minutes, and label the
  result approximate. If evidence is too sparse, say “duration unavailable.”

## What I Used Them For
- For each tool: coding, writing, research, or brainstorming

## Usage Patterns
- Do I switch between tools? Use them in bursts or steadily?

## Effectiveness
- Which tool appeared alongside verified completed work vs. unfinished work.
  Do not infer that a task was abandoned merely because the recording ended.

If no AI usage is found, say so clearly. End with: "**Tip:** [one suggestion to use AI tools more effectively]"
