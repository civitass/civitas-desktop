---
name: civitas-cli
description: Create and manage local Civitas workflows. Use when the user asks to create, inspect, enable, disable, run, or debug a scheduled or event-driven workflow.
---

# Civitas local workflows

Workflows are private Markdown automations stored at
`~/.civitas/pipes/<name>/pipe.md`. The running desktop app manages them through
its authenticated loopback API at `http://127.0.0.1:3030`.

Do not download or execute a workflow from a URL. Do not use `bun x`, an npm
package, a hosted registry, or an account token. If the user wants to use a
third-party workflow, ask them to download and inspect it first, then install
the local file or directory.

## Authentication

Every workflow API request must include:

```bash
-H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY"
```

The local workflow runtime provides that variable. Never print it, put it in a
URL, persist it in a workflow, or copy it into logs.

## Inspect and control

Keep responses bounded; never dump every workflow's complete prompt or logs.

```bash
# Compact installed-workflow list
curl -fsS \
  -H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY" \
  "http://127.0.0.1:3030/pipes/"

# Inspect one workflow
curl -fsS \
  -H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY" \
  "http://127.0.0.1:3030/pipes/day-recap"

# Enable or disable
curl -fsS -X POST \
  -H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"enabled":true}' \
  "http://127.0.0.1:3030/pipes/day-recap/enable"

# Run once
curl -fsS -X POST \
  -H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "http://127.0.0.1:3030/pipes/day-recap/run"

# Read recent logs only
curl -fsS \
  -H "Authorization: Bearer $CIVITAS_LOCAL_API_KEY" \
  "http://127.0.0.1:3030/pipes/day-recap/logs"
```

Use `DELETE /pipes/<name>` only when the user explicitly asks to delete that
workflow. Use `POST /pipes/<name>/stop` only when the user asks to stop a
running workflow or an active run is clearly stuck.

## Create a workflow

Names must use 1–80 ASCII letters, numbers, hyphens, or underscores. Create
`~/.civitas/pipes/<name>/pipe.md` with YAML frontmatter and a plain-language
prompt:

```markdown
---
schedule: manual
enabled: false
permissions: reader
---

Summarize my verified activity from the last two hours.
Use the Civitas API skill and cite timestamps for every conclusion.
If there is too little evidence, say so rather than guessing.
```

New workflows start disabled. Show the complete source to the user and explain:

- when it runs;
- which local data and API routes it can access;
- which AI preset receives the selected context;
- whether it can write data or call a connected service.

Enable it only after the user approves. Run it manually once and inspect its
result before scheduling recurring execution.

## Schedules

- Manual: `manual`
- Interval: `every 30m`, `every 1h`
- Calendar: `every day at 9am`, `every monday at 9am`
- Cron: `*/30 * * * *`, `0 9 * * *`
- One-off: `at 2026-04-29T17:00:00-07:00`

Resolve relative times in the user's local timezone and write one-off times as
RFC 3339 with an explicit offset. A one-off workflow disables itself after it
runs. Never create a recurring workflow when the user asked for a one-time
reminder.

## Permission presets

Use the narrowest preset that works:

- `reader`: read the bounded consumer activity endpoints;
- `writer`: reader access plus the documented meeting/memory writes;
- `admin`: sensitive local control; require an explicit user request;

`none`, a missing value, and unknown or misspelled presets fail closed to
`reader` for compatibility. There is no unrestricted implicit preset; use
`admin` only after explicit owner approval. To grant less than `reader`, use
structured rules with exact `Api(...)` entries.

Prefer explicit allow/deny rules when a workflow needs less than a whole preset.
Never omit `permissions` in a newly created workflow.

## Connections and secrets

Connections are optional user-configured services. Their credentials and
personal local paths live in the operating-system credential vault. Never
print, echo, summarize, or embed them. Do not add a connection unless the user
explicitly chose it. Declaring a network connection grants only its read
surface; filesystem-backed connections grant nothing implicitly. Every local
or external write needs an exact `Api(POST|PUT|PATCH ...)` rule and clear
workflow intent.

## Reliability rules

1. Query a bounded time range and keep result limits small.
2. Ground claims in retrieved evidence; label uncertainty.
3. Test manually before enabling a schedule.
4. Check recent executions and logs before editing a failing workflow.
5. Do not recursively run the current workflow.
6. Do not install remote source, publish to a registry, or depend on a Civitas
   cloud account.
