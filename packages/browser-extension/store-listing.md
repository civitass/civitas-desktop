# Chrome Web Store submission copy

This file is the reviewed source for the Chrome Web Store listing. The
publisher must verify the final dashboard fields against it before submission.

## Name

Civitas Browser Bridge

## Short description

Share a bounded outline of one active tab with local Civitas, with approval
before every navigation.

## Detailed description

Civitas Browser Bridge is an optional companion for the Civitas desktop app.
It lets you deliberately share a compact, accessibility-style outline of the
active browser tab with Civitas on your computer.

YOU STAY IN CONTROL

- Click the extension on the exact tab you want to share.
- Chrome grants temporary access to that active tab.
- Civitas can request a bounded page outline.
- If Civitas wants to change the tab's address, the desktop app displays the
  complete HTTPS URL and asks you to Allow once or Deny.
- Navigating away or closing the tab ends Chrome's temporary page grant.

NARROW BY DESIGN

- No arbitrary JavaScript or remotely supplied code
- No cookie, password, passkey, token, or browser-history access
- No hidden-tab scanning
- No clicks, form filling, form submission, purchases, or downloads
- No `<all_urls>`, `tabs`, `debugger`, or `cookies` permission

SNAPSHOT PRIVACY

The packaged snapshot function omits form values, password and hidden inputs,
and strips URL usernames, passwords, query strings, and fragments. Page
titles and visible labels can still be sensitive, so share only the tab needed
for your task.

LOCAL CONNECTION

The extension connects only to the Civitas engine on localhost or 127.0.0.1.
Its revocable, expiring browser credential is sent in a WebSocket
authentication header, never a URL. It cannot authorize other local API
routes, and pairing never discloses the device-owner API key. The extension
contains no analytics, ads, tracking, or remote service.

If you explicitly use a remote AI profile or connected service in Civitas,
selected page context may be sent by the desktop app to that provider. Civitas
shows and documents that separate boundary.

REQUIREMENTS

- Civitas desktop app running on the same computer
- Chrome, Arc, Brave, Edge, or another compatible Chromium browser

Open source:
https://github.com/civitass/civitas-desktop/tree/main/packages/browser-extension

## Category

Productivity

## Language

English

## Privacy policy URL

https://github.com/civitass/civitas-desktop/blob/main/packages/browser-extension/PRIVACY.md

## Website

https://github.com/civitass/civitas-desktop

## Support URL

https://github.com/civitass/civitas-desktop/blob/main/SUPPORT.md

## Single-purpose statement

Share a bounded outline of a user-invoked active tab with the local Civitas
desktop app and perform only user-approved HTTPS navigation of that tab.

## Reviewer test instructions

1. Install a reviewed Civitas desktop build and start the local engine.
2. Install the submitted unpacked extension or store draft.
3. Open a normal HTTPS page and click the extension.
4. Choose **Connect Civitas** and compare the six-digit code with the desktop
   prompt.
5. Approve pairing.
6. Click the extension on the test tab again, then request
   `GET /connections/browsers/user-browser/snapshot` through the authenticated
   local API. Confirm the response omits form values and URL query/fragment
   data.
7. Request a navigation to a harmless HTTPS page. Confirm the desktop shows
   the exact URL and the extension does nothing until **Allow once** is chosen.
8. Deny a second navigation and confirm the API fails closed.

No reviewer account or remote credential is required. Use synthetic,
non-sensitive page content.

## Dashboard declarations to verify

- Remote code: No
- Analytics/tracking: No
- Advertising: No
- Data sale: No
- Authentication information: scoped Civitas browser credential, stored
  locally and used only to authenticate the loopback browser endpoints
- Website content: processed only after active-tab invocation, for the
  extension's disclosed single purpose
- Personal communications/financial/health data: not intentionally collected;
  may be visible on a user-selected page, so the reviewer declaration must
  reflect Chrome's current taxonomy and the privacy policy above
