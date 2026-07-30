# Claude contributor guide

Follow [AGENTS.md](AGENTS.md) as the canonical engineering instructions for
this repository.

Before product or visual changes, also read [DESIGN.md](DESIGN.md). Before
changing capture, storage, AI providers, connectors, telemetry, MCP, or any
network path, read:

- [Privacy and data boundary](docs/PRIVACY_AND_DATA_BOUNDARY.md)
- [Network boundary](docs/NETWORK_BOUNDARY.md)
- [Threat model](docs/THREAT_MODEL.md)

Do not add private control-plane details, deployment identifiers, credentials,
customer data, enterprise fleet features, entitlement gates, or remote-sync
code to this consumer repository. Keep Civitas account-free, local-first, BYOK,
and read-only at external boundaries unless the user explicitly opts into a
narrower capability.
