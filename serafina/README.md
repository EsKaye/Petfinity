# Serafina Bot

Serafina orchestrates cross-realm communication for the **Petfinity** project.
It posts nightly council reports summarizing MCP health and recent commits, and
exposes a `/councilreportnow` slash command for manual triggers.

On boot, Serafina can optionally perform an inter-repo handshake to announce its
presence to sibling services.  Each peer exposes a `POST /handshake` endpoint
and confirms connectivity with a lightweight JSON reply.  See the shared
[Inter-Repo Handshake](../INTER_REPO_HANDSHAKE.md) spec for full details.

## Environment Variables

See [`.env.example`](./.env.example) for required configuration.  Additional
project context lives in the root [README](../README.md) and
[LAUNCH_CHECKLIST](../LAUNCH_CHECKLIST.md).

Handshake-specific variables:

- `HANDSHAKE_PEERS` – comma-separated base URLs of sibling services
- `HANDSHAKE_TOKEN` – optional bearer token shared with those services

Nightly report variables:

- `MCP_URL` – base URL for MCP endpoints (`/ask-gemini`, `/osc`)
- `CHN_COUNCIL` – Discord channel ID for report delivery
- `NAV_REPOS` – comma-separated `owner/repo` list to summarize commits
- `WH_LILYBEAR` – optional webhook URL to override channel delivery

## Development

```bash
npm install
npm run build
npm start
```

Run tests via:

```bash
npm test
```
