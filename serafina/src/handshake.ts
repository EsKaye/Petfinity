import fetch from 'node-fetch';

/**
 * Lightweight handshake utility to notify sibling services that Serafina is online.
 * Peers are defined via the HANDSHAKE_PEERS env variable as a comma-separated list
 * of base URLs. Each peer is expected to expose a POST /handshake endpoint.
 *
 * The request carries our repository identifier and timestamp, allowing services to
 * verify connectivity without blocking the boot sequence.
 */
export async function performHandshake(): Promise<void> {
  const peersRaw = process.env.HANDSHAKE_PEERS || '';
  // Bail early if no peers configured; keeps optional dependency minimal
  if (!peersRaw) return;

  const peers = peersRaw
    .split(',')
    .map((p) => p.trim())
    .filter(Boolean);
  const token = process.env.HANDSHAKE_TOKEN; // shared bearer token, optional

  const payload = {
    repo: 'Serafina',
    timestamp: new Date().toISOString(),
  };

  for (const base of peers) {
    const url = `${base.replace(/\/$/, '')}/handshake`; // normalize to avoid double slashes
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        console.error(`Handshake with ${base} failed: ${res.status}`);
      } else {
        console.log(`Handshake with ${base} succeeded`);
      }
    } catch (err) {
      // Robust logging helps surface misconfigurations without crashing startup
      console.error(`Handshake error with ${base}:`, err);
    }
  }
}
