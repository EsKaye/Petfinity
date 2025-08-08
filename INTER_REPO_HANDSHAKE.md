# Inter-Repo Handshake Protocol

This document defines a lightweight HTTP-based handshake used by Petfinity's
sibling repositories to announce their presence and verify connectivity.  The
protocol keeps services loosely coupled while enabling cross-repo discovery in
the broader MKWW/GameDin ecosystem.

## Endpoint

Each participating service exposes a `POST /handshake` endpoint.

### Request

```json
{
  "repo": "Serafina",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

- `repo` – identifier of the calling repository.
- `timestamp` – ISO string indicating when the handshake was sent.

The client may include an `Authorization: Bearer <token>` header when
`HANDSHAKE_TOKEN` is configured.

### Response

Successful handshakes reply with JSON:

```json
{ "status": "ok", "repo": "RemoteRepo" }
```

Services should log failed or missing handshakes for later diagnostics but
should not crash during startup.  This non-blocking design preserves stability
while still surfacing network issues.

## Environment Variables

The Serafina implementation consumes:

- `HANDSHAKE_PEERS` – comma-separated list of peer base URLs.
- `HANDSHAKE_TOKEN` – optional shared bearer token.

## Related Documents

- [Serafina Bot](serafina/README.md) – contains runtime handshake
  implementation and configuration notes.
- [LAUNCH_CHECKLIST](LAUNCH_CHECKLIST.md) – includes launch tasks referencing
  this protocol.
- [Project Overview](README.md) – broader context for the Petfinity project.

---

This protocol is a starting point; future revisions may add mutual authentication
or signed payloads for stronger trust guarantees across the network.
