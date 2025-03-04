# 🐾 Petfinity

A magical pet collection and care game built with Roblox Studio.

## Features

- 🎲 Gacha roll system with unique pets
- 🐱 Adorable pets with special effects
- 🌟 Special effects for rare pets
- 🏆 Competitive leaderboards
- 🎁 Daily rewards
- 👑 VIP benefits
- 📱 Mobile-friendly UI design

## Getting Started

### Prerequisites

- Roblox Studio
- Rojo
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Petfinity.git
cd Petfinity
```

2. Connect to Rojo in Roblox Studio:
   - Open Roblox Studio
   - Click the Rojo plugin button
   - Click "Connect"
   - Enter `localhost` and port `34872`

## Project Structure

```
Petfinity/
├── src/
│   ├── Client/           # Client-side scripts
│   │   ├── UI/          # User interface components
│   │   ├── Animation/   # Animation controllers
│   │   ├── Effects/     # Visual effects
│   │   ├── Camera/      # Camera controls
│   │   └── PetInteraction/ # Pet interaction scripts
│   ├── Server/          # Server-side scripts
│   │   ├── Leaderboards/    # Leaderboard system
│   │   ├── Achievements/    # Achievement system
│   │   ├── Monetization/    # In-game purchases
│   │   ├── BiomeHandler/    # Biome management
│   │   └── PetAI/          # Pet AI system
│   └── Shared/          # Shared modules
│       ├── PetSystem/   # Pet management
│       ├── BiomeData/   # Biome configurations
│       ├── EventSystem/ # Event handling
│       └── AudioManager/ # Sound management
├── assets/             # Game assets
│   ├── Models/        # 3D models
│   ├── Sounds/        # Audio files
│   └── Textures/      # Image textures
└── config/            # Configuration files
```

## Game Systems

### GachaSystem
- Handles pet rolling mechanics
- Manages rarity tiers
- Controls drop rates

### PetSystem
- Manages pet states and behaviors
- Handles pet interactions
- Controls pet progression

### UISystem
- Manages all user interfaces
- Handles mobile responsiveness
- Controls animations and transitions

### EffectsSystem
- Manages visual effects
- Controls particle systems
- Handles special effects for rare pets

### DailyRewardSystem
- Manages daily rewards
- Tracks player streaks
- Handles reward distribution

### SeasonalEventSystem
- Manages seasonal events
- Controls event rewards
- Handles event progression

### LeaderboardSystem
- Manages player rankings
- Tracks achievements
- Handles competitive features

## Development

### Running Tests
```bash
rojo serve
```

### Building for Production
```bash
rojo build -o build/Petfinity.rbxm
```

## Documentation

- [Game Design Document](docs/GAME_DESIGN.md)
- [API Documentation](docs/API.md)
- [Contributing Guide](CONTRIBUTING.md)

## Assets

All game assets are stored in Roblox Studio. The `assets/` directory contains references and metadata.

## Performance

- Target FPS: 60
- Maximum pets per server: 100
- Memory usage limit: 1GB

## Deployment

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed deployment instructions.

## License

This project is proprietary and confidential.

## Credits

Created by Your precious kitten 💖 