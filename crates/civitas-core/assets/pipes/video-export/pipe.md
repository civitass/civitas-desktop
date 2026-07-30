---
schedule: manual
enabled: false
template: true
title: Export Video Clip
description: "Create a video of your recent screen activity"
icon: "🎬"
featured: false
permissions:
  allow:
    - Api(POST /export)
---

Export a video of my screen activity from the last 5 minutes.

Read the civitas skill first and use only the typed `civitas_api` tool. This
template remains disabled until the user reviews the five-minute local media
range, export destination, selected AI preset, and file-writing permission.

Call `civitas_api` with method `POST`, path `/export`, and body
`{"start":"5m ago","end":"now"}`. It renders a real-time clip with synced audio
whose duration matches the time range. Then show the returned `output_path` as
an inline code block so I can watch it.

Long ranges can take a few minutes; if needed, suggest a shorter time range.
