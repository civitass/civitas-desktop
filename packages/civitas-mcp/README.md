<p align="center">
  <img src="https://raw.githubusercontent.com/civitass/civitas-desktop/main/apps/civitas-app-tauri/public/civitas.svg" width="84" alt="Civitas circle mark">
</p>

<h1 align="center">Civitas MCP</h1>

<p align="center">
  A permissioned bridge from an AI client to your personal, local Civitas memory.
</p>

Civitas MCP lets clients such as Claude Desktop, Codex, Cursor, and other
Model Context Protocol hosts search the work history and knowledge graph stored
by Civitas on your computer. The bridge connects only to the loopback Civitas
API. It does not discover credentials from files, execute a second package to
find a token, or contact a Civitas account service.

> [!IMPORTANT]
> MCP results leave the Civitas process and enter the client you connect.
> That client may send the results to its own model provider. Connect only
> clients you trust, keep the default read scope, and review the client’s data
> policy.

## Safe setup

The easiest setup is in **Civitas → Settings → Connections**. Select your MCP
client and choose **Connect**. Civitas writes a configuration containing:

- the exact `civitas-mcp@0.18.10` package version;
- a dedicated, per-client credential as `CIVITAS_MCP_CREDENTIAL`;
- the default, server-enforced `read` scope.

For a manual stdio configuration, use the client’s **Copy configuration**
action in **Settings → Connections**. Civitas issues the credential only when
you copy, and shows the client under **AI client access** so you can inspect its
expiry and last use, rotate it, or revoke it:

```json
{
  "mcpServers": {
    "civitas": {
      "command": "npx",
      "args": ["-y", "civitas-mcp@0.18.10"],
      "env": {
        "CIVITAS_MCP_CREDENTIAL": "<issued-by-civitas>",
        "CIVITAS_MCP_SCOPES": "read"
      }
    }
  }
}
```

Do not commit this configuration or paste it into chat: the client credential
is a bearer secret. It expires after 90 days by default and can access only the
engine routes authorized by its stored scopes. It is not the device-owner API
key and cannot reach credential management, raw SQL, connections, retention,
vault, workflow-install, or knowledge-graph administration routes. Reconnecting
the same named client revokes its previous credential.

Requirements:

- Civitas running on `127.0.0.1:3030`;
- a supported Node.js 22 or newer release when using `npx`;
- an MCP client that supports stdio.

## Permission scopes

`CIVITAS_MCP_SCOPES` is a comma-separated allowlist. Unknown values fail
closed. If it is omitted, Civitas exposes only `read`.

| Scope     | Access                                                                       | Default |
| --------- | ---------------------------------------------------------------------------- | ------- |
| `read`    | bounded search, meeting lookup, and provenance-aware knowledge-graph queries | yes     |
| `inspect` | local health and device metadata plus legacy read helpers                    | no      |
| `manage`  | memories, tags, speaker labels, and meeting metadata                         | no      |
| `capture` | start or stop audio capture                                                  | no      |
| `media`   | allow screenshots in stdio search results when `include_frames=true`         | no      |

State-changing tools are both hidden and rejected unless their scope is
enabled. The Civitas engine independently enforces the same scope on every
request, so editing `CIVITAS_MCP_SCOPES` in a client configuration cannot
escalate the credential. Raw screenshots are unavailable by default. The HTTP
transport is the canonical read-focused surface and never returns raw media.

The consumer setup UI currently issues read-only credentials. The other scope
names are documented so reviewed deployments can recognize and deny them
consistently; changing `CIVITAS_MCP_SCOPES` in a client configuration does not
grant additional server access. Civitas must issue a credential with that
stored scope before the corresponding tool can run.

## What the read scope can query

The canonical read surface contains five timeline/search tools and eleven
knowledge-graph tools:

- `search-content`, `list-meetings`, `activity-summary`,
  `search-elements`, and `frame-context`;
- `query_decisions`, `get_entity`, `find_procedure`, `who_knows`,
  `find_blockers`, `find_precedent`, `list_recent_decisions`,
  `find_decision_options`, `trace_provenance`, `find_contradictions`,
  and `get_context_pack`.

Knowledge-graph responses are size-bounded and include provenance and honesty
fields. Captured text is treated as untrusted evidence, not as instructions to
the MCP server.

## HTTP transport

HTTP mode is loopback-only:

```bash
CIVITAS_MCP_HTTP_KEY="<separate-inbound-mcp-key>" \
CIVITAS_MCP_CREDENTIAL="<issued-by-civitas>" \
  npx -y civitas-mcp@0.18.10 --http --port 3031
```

The MCP endpoint is `http://127.0.0.1:3031/mcp`; the minimal health endpoint is
`http://127.0.0.1:3031/health`. Both require
`Authorization: Bearer <separate-inbound-mcp-key>`.

LAN binding is intentionally unsupported. `CIVITAS_MCP_HTTP_KEY` is mandatory,
including on loopback, must be a separate random secret of 32–4096 printable
ASCII characters without whitespace, and must be different from the upstream
client credential. The inbound secret is never forwarded to Civitas. Device
owner keys (`CIVITAS_LOCAL_API_KEY`) and knowledge-graph grants
(`CIVITAS_KG_AGENT_TOKEN`) are deliberately rejected by this package.
`CIVITAS_MCP_SCOPES` is enforced for both tool listing and execution, while the
credential’s persisted scope is authoritative at the engine boundary. HTTP
sessions are bounded (32 by default) and expire after ten idle minutes;
deployments may lower those ceilings with `CIVITAS_MCP_MAX_SESSIONS` and
`CIVITAS_MCP_SESSION_IDLE_MS`.

## Build and test

From the repository root:

```bash
bun install --frozen-lockfile
bun --cwd packages/civitas-mcp run build
bun --cwd packages/civitas-mcp run test
```

To inspect a local build:

```bash
npx @modelcontextprotocol/inspector \
  env CIVITAS_MCP_CREDENTIAL="<issued-by-civitas>" \
  env CIVITAS_MCP_SCOPES="read" \
  node packages/civitas-mcp/dist/index.js
```

## Privacy boundary

The bridge has no analytics and does not persist tool results. Its normal
outbound connection is the authenticated Civitas loopback API at
`127.0.0.1:3030`. Stdio responses go to the MCP host; HTTP responses go to the
authenticated HTTP client. Those clients define what happens next.

Civitas recordings and derived indexes remain in the Civitas data directory.
Delete or rotate data through the app so source media, database rows, derived
graph records, and credentials follow the same lifecycle; avoid deleting the
directory manually while Civitas is running.

See the repository’s
[privacy and data boundary](../../docs/PRIVACY_AND_DATA_BOUNDARY.md),
[network boundary](../../docs/NETWORK_BOUNDARY.md), and
[threat model](../../docs/THREAT_MODEL.md) for the complete public contract.
