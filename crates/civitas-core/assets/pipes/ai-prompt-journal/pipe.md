---
schedule: every 1h
enabled: false
template: true
title: AI Prompt Journal
description: "Opt-in: save high-confidence AI prompts to a private Obsidian journal"
icon: "🧠"
featured: true
connections: [obsidian]
permissions:
  allow:
    - Api(GET /search)
    - Api(POST /connections/obsidian/notes)
    - Window(*ChatGPT*, *chatgpt.com*, *Claude*, *claude.ai*, *Gemini*, *gemini.google.com*, *Perplexity*, *Grok*, *DeepSeek*, *Copilot*, *HuggingChat*, *Mistral*, *OpenRouter*, *Poe*, *AI Studio*, *Cursor*, *LM Studio*, *Jan*)
    - Content(input, accessibility)
---

Create a private journal of AI prompts the user sent during the last hour.
This workflow is intentionally disabled until the user opts in because prompts
can contain sensitive text.

Read the civitas skill first and use only the typed `civitas_api` tool. Never
use raw SQL, shell commands, direct filesystem commands, browser automation, or
external network requests. Before enabling, the user must review the one-hour
input/accessibility window, selected AI provider boundary, private Obsidian
destination, and append permission.

## 1. Find narrowly scoped candidates

Run bounded `/search` requests with `start_time=1h ago`, `end_time=now`,
`limit=20`, and `content_type=input` for the AI window titles below. Make at
most eight searches total:

- ChatGPT / chatgpt.com
- Claude / claude.ai
- Gemini / gemini.google.com
- Perplexity
- Copilot
- Grok or DeepSeek
- Mistral, OpenRouter, or Poe
- native AI apps such as ChatGPT, Claude, Cursor, LM Studio, or Jan

Every request must include an AI-specific `window_name` matching the permission
list. For a native AI app, add `app_name` only as a second narrowing filter.
Do not run a broad input search without an AI-specific window filter.

If needed, use a matching `content_type=accessibility` search for the same
window and time range to verify that an input candidate appeared in an AI chat.
Do not collect text from unrelated windows.

## 2. Keep only submitted user prompts

Accuracy is more important than recall:

- Include text only when it is an input capture in a verified AI-chat window,
  or accessibility structure clearly labels it as the user's submitted message.
- Exclude assistant responses, menus, placeholder text, search bars, URLs,
  passwords, API keys, and text that was merely visible but not submitted.
- Exclude partial typing when a more complete version of the same prompt exists.
- Deduplicate by normalized prompt text plus AI tool. Keep the earliest verified
  submission time and the most complete exact text.
- If confidence is below high, omit the candidate. Never add an “uncertain”
  entry and never prefer false positives.

If no high-confidence new prompts exist, finish silently.

## 3. Classify without rewriting

For each prompt keep the exact wording and determine:

- Tool: the verified AI product.
- Category: `coding`, `writing`, `research`, `brainstorming`, `analysis`,
  `conversation`, `image-gen`, or `other`.
- Topic: a neutral two-to-five-word label.
- Length: `short` (<50 words), `medium` (50–200), or `long` (>200).

Do not paraphrase, correct, or complete the prompt.

## 4. Append through the safe local note API

For each unique prompt, call `civitas_api` with method `POST`, path
`/connections/obsidian/notes`, and this JSON object as `body`:

```json
{
  "relative_path": "civitas/ai-prompts/YYYY-MM-DD.md",
  "mode": "append",
  "create_header": "---\ndate: YYYY-MM-DD\ntags: [ai-prompts, civitas]\n---\n\n# AI Prompts — YYYY-MM-DD",
  "dedupe_key": "Tool\n<exact prompt text>",
  "content": "## HH:MM — Tool — Topic\n**Category**: category | **Length**: length\n\n> exact prompt text, with every line blockquoted\n\n---"
}
```

Use the user's local date and time. JSON-escape all dynamic text correctly.
The endpoint resolves the configured vault internally, accepts only relative
`.md` paths, blocks traversal and symlinks, and returns `duplicate: true`
without appending when the dedupe key was already written. Never request or
print the vault's absolute path.

## 5. Report conservatively

Return a short run result with counts by tool and how many candidates were
skipped for low confidence. Do not repeat prompt text in the result. If every
candidate was already present, finish silently.
