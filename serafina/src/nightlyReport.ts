import 'dotenv/config';
import fetch from 'node-fetch';
import { EmbedBuilder, TextChannel, Client } from 'discord.js';
import cron from 'node-cron';

// Environment bindings for MCP endpoint, Discord channel, optional webhook, and repo list
const MCP = process.env.MCP_URL!;
const COUNCIL_CH = process.env.CHN_COUNCIL!;
const LILY_WEBHOOK = process.env.WH_LILYBEAR; // optional webhook override
const GH_REPOS: string[] = (process.env.NAV_REPOS || '')
  .split(',')
  .map((s: string) => s.trim())
  .filter((s: string) => s.length > 0);

// Query MCP for a one-line status summary
async function getMcpStatus(): Promise<string> {
  try {
    const r = await fetch(`${MCP}/ask-gemini`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'Summarize system health in one sentence.' }),
    });
    const j: any = await r.json().catch(() => ({ response: '(no data)' }));
    return (j.response as string) || '(no data)';
  } catch {
    return '(MCP unreachable)';
  }
}

// Lightweight digest of recent commits for a repo
async function getRepoDigest(repo: string): Promise<string> {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const url = `https://api.github.com/repos/${repo}/commits?since=${encodeURIComponent(
    since,
  )}&per_page=5`;
  try {
    const r = await fetch(url, { headers: { Accept: 'application/vnd.github+json' } });
    if (!r.ok) return `• ${repo}: no recent commits`;
    const commits = (await r.json()) as any[];
    if (!commits.length) return `• ${repo}: 0 commits in last 24h`;
    const lines = commits.map(
      (c) => `• ${repo}@${(c.sha || '').slice(0, 7)} — ${c.commit.message.split('\n')[0]}`,
    );
    return lines.join('\n');
  } catch {
    return `• ${repo}: (error fetching commits)`;
  }
}

// Forward a text snippet to the VR layer via the MCP OSC bridge
async function broadcastToVr(text: string): Promise<void> {
  try {
    await fetch(`${MCP}/osc`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ address: '/lilybear/council', value: text }),
    });
  } catch (err) {
    // Failure here shouldn't block the Discord flow; log for later diagnosis
    console.error('OSC relay failed:', err);
  }
}

// Emit the council report immediately
export async function sendCouncilReport(client: Client): Promise<void> {
  try {
    const ch = client.channels.cache.get(COUNCIL_CH) as TextChannel | undefined;
    const mcp = await getMcpStatus();
    const repoLines = GH_REPOS.length
      ? (await Promise.all(GH_REPOS.map(getRepoDigest))).join('\n')
      : '—';

    const emb = new EmbedBuilder()
      .setTitle('🌙 Nightly Council Report')
      .setDescription('Summary of the last 24h across our realm.')
      .setColor(0x9b59b6)
      .addFields(
        { name: 'System Health (MCP)', value: mcp.slice(0, 1024) || '—' },
        { name: 'Recent Commits', value: repoLines.slice(0, 1024) || '—' },
      )
      .setFooter({ text: 'Reported by Lilybear' })
      .setTimestamp(new Date());

    if (LILY_WEBHOOK) {
      await fetch(LILY_WEBHOOK, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ embeds: [emb.toJSON()] }),
      });
    } else if (ch) {
      await ch.send({ embeds: [emb] });
    }

    // Relay a condensed summary to the VR scene so guardians can react
    const condensed = `${mcp} | ${repoLines}`.slice(0, 200);
    await broadcastToVr(condensed);
  } catch (e) {
    console.error('Nightly report error:', e);
  }
}

// Schedule the nightly report at 08:00 UTC
export function scheduleNightlyCouncilReport(client: Client): void {
  cron.schedule(
    '0 8 * * *',
    () => {
      void sendCouncilReport(client);
    },
    { timezone: 'UTC' },
  );
}
