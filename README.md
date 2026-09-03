# WordCraft

A word puzzle game built with Flutter. Unscramble letters to form words against the clock, build streaks, and chase your best score.

## Features

- **Word Scramble** - Tap scrambled letters to form the correct word before time runs out
- **Timer + scoring** - Speed bonuses and streak multipliers reward quick, consistent play
- **Stats tracking** - Lifetime games, words found, best score, and best streak
- **Dark / Light theme** - Toggleable appearance
- **Daily Challenge** - Same 5-word puzzle for everyone each day
- **Multiplayer battles** - Host or join a room, race a friend in real time
- **Flutter Web** - Runs on Android, iOS, and web

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| State management | Riverpod 2.x |
| Navigation | go_router |
| Persistence | shared_preferences |
| Typography | google_fonts |

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0)
- Chrome (for Flutter Web)

### Run the app

```bash
flutter pub get
flutter run
```

### Run on web

```bash
flutter run -d chrome
```

### Build for web

```bash
flutter build web
```

### Run tests

```bash
flutter test
```

## Multiplayer Server

Real-time matches run on a Node.js WebSocket server. The server is the
source of truth for words, scoring, and winners.

### Prerequisites

- Node.js (>= 18)

### Run the server

```bash
cd server
npm install
npm start
```

The server listens on `ws://localhost:8080` by default. Set the `PORT`
environment variable to use a different port.

### Run server tests

```bash
cd server
npm test
```

### How to play multiplayer

1. Start the server and the Flutter app.
2. On one device, tap **Multiplayer**, enter a name, and tap **Create room**.
3. Share the 6-letter room code with a friend.
4. On the other device, tap **Multiplayer**, enter the code, and tap **Join room**.
5. Both players get the same scrambled word each round and race to solve it.

## Project Structure

```
lib/
├── core/                    # Shared utilities
│   ├── theme/               # Custom light/dark theme
│   ├── constants/           # Colors, spacing, game rules
│   └── router/              # go_router configuration
├── features/                # Feature-first modules
│   ├── word_scramble/       # Core gameplay
│   │   ├── data/            # Word data source + repository
│   │   ├── domain/          # Models, scoring, scramble logic
│   │   └── presentation/    # Providers, screens, widgets
│   ├── home/                # Landing screen
│   ├── multiplayer/         # Online battles (lobby + battle screens)
│   ├── stats/               # Lifetime statistics
│   └── settings/            # Theme preference
├── shared/                  # Shared widgets
└── main.dart
```

## Testing

- `test/features/word_scramble/domain/game_logic_test.dart` - scoring + scramble
- `test/features/word_scramble/presentation/providers/game_provider_test.dart` - game flow
- `test/features/stats/domain/game_stats_test.dart` - stats merging
