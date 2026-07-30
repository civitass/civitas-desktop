# Local search and saved queries

Civitas Desktop searches the activity library on the user's computer. Search,
facet calculation, tag suggestions, transcript-to-frame matching, and saved
queries do not require a model or a Civitas cloud service.

## Search from the desktop app

Open Search and enter at least three characters. Results can include captured
screen text, accessibility text, transcripts, keyboard/clipboard events when
those optional capture modes are enabled, and local chat history.

The result surface supports:

- content scope: all, screen, keyboard/clipboard, or chats;
- application, website hostname, and local-calendar-date facets;
- `#tag` lookup, including `project:` and `person:` namespaces;
- named people from local speaker identification;
- evidence labels that distinguish OCR and accessibility-derived text;
- source previews and navigation back to the matching point in the timeline;
  and
- saved queries that restore the query, scope, application, hostname, date,
  and tag context.

Facet counts are calculated over a bounded local sample. When more than
100,000 frames match, `truncated` is true and the counts describe that ranked
sample, not the entire library. The desktop continues to paginate result
records independently.

Website facets contain normalized hostnames only. Civitas strips `www.` and
does not return browser paths, queries, or fragments in the facet response.
The underlying capture can still contain sensitive browser context, subject to
the capture exclusions described in
[Privacy and data boundary](PRIVACY_AND_DATA_BOUNDARY.md).

## Saved queries

Use **Saved** to open local saved queries, or the adjacent bookmark button to
name the current search. Applying a saved query restores its complete recorded
scope. Editing is immediate after a successful local write. Deletion requires
a second explicit action.

Saved-search follow-ups are off by default. In the save/edit sheet, the owner
can explicitly enable **Suggest in Next Actions** and choose a 1–30 day
interval. Once due, Next Actions shows one evidence-linked, draft-only reminder
for the current interval. Opening its evidence restores the exact saved query
and filters, then schedules the next local interval. **Later** affects the
current occurrence; **Never show this** suppresses the stable saved-query
series. Civitas does not run the query in the background, notify ambiently,
contact an AI provider, or execute an action.

Saved query names, terms, filters, opt-in state, interval, and last local review
time may reveal sensitive interests or work topics. They are stored in the
local SQLite library in `saved_search_queries`; they are not stored in browser
`localStorage` and are not sent to Civitas.

Age-based source-media and derived-intelligence cleanup does not remove
owner-authored saved queries. They remain until the user deletes them or
performs a full local-library wipe. Portable export includes them so the
export accurately represents the user's search organization. As with every
portable export, the resulting copy is outside later Civitas deletion.

## Local API contract

The desktop webview calls typed, owner-only routes. It does not construct SQL
or call the general `/raw_sql` compatibility surface.

| Method | Route | Bound |
| --- | --- | --- |
| `GET` | `/search/facets` | Query up to 1,000 characters; at most 100,000 ranked frames and 50 values per ordinary facet |
| `GET` | `/search/tags` | Query up to 100 characters; at most 50 tags and 100 frames |
| `POST` | `/search/nearest-frames` | 1–100 RFC 3339 timestamps; search window 1–300 seconds |
| `GET` | `/search/saved` | At most 500 saved queries in deterministic order |
| `GET` | `/search/saved/{id}` | Retrieve one exact saved query for local evidence navigation |
| `POST` | `/search/saved` | Validated name, query, scope, filters, and opt-out follow-up metadata |
| `PATCH` | `/search/saved/{id}` | Full validated replacement; follow-up interval is bounded to 1–30 days |
| `POST` | `/search/saved/{id}/reviewed` | Advance an enabled local follow-up after explicit review; no-op when opted out |
| `DELETE` | `/search/saved/{id}` | Delete one saved query |

Every route requires the device-owner bearer key. Scoped workflow, MCP, and
agent credentials are denied because facets and saved terms can disclose broad
personal context. Database inputs are bound parameters, queries have bounded
work, and route execution has a timeout. Success responses use
`civitas-consumer-search/v1`, camel-case JSON fields, and `localOnly: true`.
Errors use a non-2xx status and a stable JSON object:

```json
{
  "error": "invalid_request",
  "message": "localDate must be a real date in YYYY-MM-DD format"
}
```

The generated operation schemas are available from the authenticated local
engine at `/openapi.yaml` and `/openapi.json`; the reviewed publication
snapshot is [`openapi.yaml`](openapi.yaml).

## Verification

Use synthetic data only:

```bash
cargo test --locked -p civitas-db --test consumer_search_test
cargo test --locked -p civitas-engine --test consumer_search_test

cd apps/civitas-app-tauri
bunx vitest run components/rewind/saved-query-controls.test.tsx \
  components/next-actions/next-actions-panel.test.tsx \
  lib/timeline-navigation.test.ts \
  --config vitest.config.ts
```

Before release, also complete the search journey and privacy checks in
[`TESTING.md`](../TESTING.md).
