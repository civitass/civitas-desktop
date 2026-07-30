# AI Prompt Journal

An opt-in workflow that finds high-confidence prompts sent in supported AI-chat
windows and appends them to a private Obsidian journal.

It is installed **disabled**. Enable it only after reviewing the data boundary:
Civitas reads its local capture database, but the selected AI provider receives
the bounded candidate text needed to classify prompts. With a local inference
provider, that processing stays on the computer. With OpenAI, Anthropic,
OpenRouter, or Amazon Bedrock, those candidates are sent directly to that
provider under the user's account and the provider's terms. Civitas does not
relay the request or provide credits.

## What it does

- Searches only explicitly named AI-chat window titles over the previous hour.
- Uses input/accessibility captures; broad screen, audio, and raw-SQL access are
  outside this workflow's permission scope.
- Keeps only high-confidence submitted user prompts and favors false negatives
  over accidentally journaling an assistant response or unrelated input.
- Preserves exact prompt wording and adds tool, topic, category, and length.
- Appends through a narrow local Obsidian API. The workflow never receives the
  vault's absolute path and cannot write arbitrary files.
- Uses a server-generated digest marker so reruns do not append the same prompt
  twice.

## Setup

1. In Civitas Settings, configure an AI provider. Choose a local provider if
   prompt text must not leave the computer.
2. Connect an Obsidian vault in Settings → Connections.
3. Open Workflows → AI Prompt Journal, review its permissions, and enable it.
4. New entries appear under
   `civitas/ai-prompts/YYYY-MM-DD.md` in the connected vault.

There is deliberately no fallback to an arbitrary home-directory path. If the
Obsidian connection is unavailable, the workflow stays in setup mode and does
not run.

## Accuracy contract

A candidate is journaled only when it appears in a recognized AI window and is
either captured as input or clearly identified as the user's submitted message
by accessibility structure. Partial typing is collapsed into the most complete
version. Low-confidence candidates, visible assistant responses, placeholders,
URLs, credentials, and unrelated window content are omitted.

No heuristic can be perfect across every application version. Review initial
entries before relying on the journal as an audit record.

## Output

```markdown
## 09:15 — ChatGPT — React auth flow
**Category**: coding | **Length**: medium

> How do I implement OAuth 2.0 with PKCE in a React app?

---
```

## Privacy and control

- Disabled by default and scheduled only after explicit user opt-in.
- Local capture data remains in Civitas' local database.
- Obsidian output remains in the selected local vault.
- The configured model provider receives only the text selected for this run.
- API credentials and vault paths remain in the OS credential vault and are
  never inserted into the workflow prompt.
- Disable or delete the workflow at any time. Existing journal files remain
  under the user's control in Obsidian.
