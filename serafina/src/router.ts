import 'dotenv/config';
import {
  Client,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder,
  Interaction,
} from 'discord.js';
import {
  scheduleNightlyCouncilReport,
  sendCouncilReport,
} from './nightlyReport.js';
import { performHandshake } from './handshake.js';

// Basic Discord client with minimal intents
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// Use async ready handler so we can await the handshake without blocking logs
client.once('ready', async () => {
  console.log(`Serafina connected as ${client.user?.tag}`);
  scheduleNightlyCouncilReport(client); // start the nightly scheduler
  await performHandshake(); // notify sibling repos that we're online
});

// Register slash command for manual council reports
const commands = [
  new SlashCommandBuilder()
    .setName('councilreportnow')
    .setDescription('Manually send the council report'),
].map((c) => c.toJSON());

const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_TOKEN!);
(async () => {
  try {
    if (process.env.APP_ID && process.env.GUILD_ID) {
      await rest.put(
        Routes.applicationGuildCommands(process.env.APP_ID, process.env.GUILD_ID),
        { body: commands },
      );
    }
  } catch (err) {
    console.error('Failed to register commands:', err);
  }
})();

// Handle incoming slash commands
client.on('interactionCreate', async (interaction: Interaction) => {
  if (!interaction.isChatInputCommand()) return;
  if (interaction.commandName === 'councilreportnow') {
    await interaction.reply('Summoning the council report...');
    await sendCouncilReport(client);
    await interaction.followUp('Report dispatched.');
  }
});

client.login(process.env.DISCORD_TOKEN);
