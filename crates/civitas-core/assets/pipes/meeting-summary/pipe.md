---
schedule: manual
enabled: false
trigger:
  events:
    - meeting_ended
template: true
title: Meeting Summary
description: "Turn a completed local meeting transcript into decisions, actions, and durable notes"
icon: "🤝"
featured: false
permissions:
  allow:
    - Api(GET /meetings)
    - Api(GET /meetings/*)
    - Api(GET /search)
    - Api(PATCH /meetings/*)
---

Summarize the meeting identified by the trusted local trigger metadata and save
the result back to that same local meeting record.

Keep these instructions aligned with `buildMeetingSummarizeInstructions` in
`apps/civitas-app-tauri/lib/utils/meeting-context.ts`, which powers the in-app
“Summarize with AI” action.

Read the civitas skill first and use only the typed `civitas_api` tool. This
template remains disabled until the user reviews its local transcript access,
meeting-note write, event trigger, and selected AI provider boundary.

## 1. Select the exact meeting

- When trigger metadata includes `meeting_id`, use that ID. Do not substitute
  the newest meeting.
- On a manual run without an ID, GET `/meetings?limit=1` and use the most recent
  completed meeting.
- GET `/meetings/<ID>` and preserve its current `title`, `note`,
  `meeting_start`, `meeting_end`, `meeting_app`, and `attendees`.
- If the record is missing or still active, stop without writing.

## 2. Build an evidence-grounded summary

Primary source: GET `/meetings/<ID>/transcript`. Sort rows by `capturedAt` and
use `transcript`, `speakerName`, `source`, and timestamps.

Fallback: if the meeting transcript is empty, call `/search` with
`content_type=audio`, `start_time=<meeting_start>`, `end_time=<meeting_end>`,
and a bounded limit. Audio text is `content.transcription`, not `content.text`.

Ignore empty fragments, obvious transcription hallucinations, and unrelated
audio. Never infer a decision, owner, deadline, attendee, or action from weak
evidence. Use this concise structure:

```markdown
### Overview
Two or three sentences on the verified purpose and outcome.

### Decisions
- A concrete decision, or “No explicit decisions captured.”

### Action items
- [ ] Owner — action — due date, but only when each detail was explicit.
- [ ] Unassigned — action, when the action is clear but no owner was named.

### Open questions
- A clearly unresolved question, or “None captured.”
```

Omit transcript quotations unless a short quote is necessary to preserve a
decision. Do not include sensitive text unrelated to the meeting.

## 3. Preserve the user's notes and save idempotently

Wrap the generated section exactly:

```markdown
<!-- civitas-summary:start -->
## Summary
...structured summary...
<!-- civitas-summary:end -->
```

- If those markers already exist, replace only the marked block.
- Otherwise append the block after the existing note with one blank line.
- Never erase, rewrite, or reorder user-authored text outside the markers.
- If there is no useful transcript, return “No reliable transcript to
  summarize” and skip PATCH. Do not write a placeholder.

PATCH `/meetings/<ID>` with the complete preserved note. Refresh the title only
when the current title is empty, generic (“untitled”, “meeting”, or just the
meeting app), or demonstrably inaccurate. A generated title must be plain
English, five to eight words, and based on the main verified topic. Otherwise
omit `title` so a user title remains untouched.

Pass the complete note as the typed tool's JSON `body`; do not build JSON with
a shell command. After PATCH, confirm the returned meeting ID matches the
selected ID and report what was saved without repeating the full transcript.
