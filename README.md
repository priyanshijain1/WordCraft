# WordCraft

**Play live: https://priyanshijain1.github.io/WordCraft/** (multiplayer server: `wss://wordcraft-9oni.onrender.com`)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-22-339933?logo=node.js)
![Platform](https://img.shields.io/badge/platform-Web-blue)
![Multiplayer](https://img.shields.io/badge/multiplayer-WebSocket-orange)

A real-time multiplayer word scramble game. Unscramble letters against the
clock, build streaks, take on the daily puzzle, or battle a friend live over
WebSockets.

## Features

| Mode | Description |
|------|-------------|
| **Classic** | 8 words, 30 seconds each. Speed bonuses + streak multipliers |
| **Daily Challenge** | Same 5-word puzzle for everyone, every day (date-seeded) |
| **Multiplayer** | Host or join a room with a 6-letter code, race in real time |
| **Stats** | Lifetime games, words found, best score, best streak |
| **Theme** | Dark / light toggle |

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x (Web) |
| State management | Riverpod 2.x |
| Navigation | go_router |
| Persistence | shared_preferences |
| Typography | google_fonts |
| Multiplayer server | Node.js + `ws` |
| Realtime protocol | JSON over WebSocket |

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0) + Chrome for web
- Node.js (>= 18) for the multiplayer server

### Run the app

```bash
flutter pub get
flutter run -d chrome
```

### Build for web

```bash
flutter build web
```

### Run the multiplayer server

```bash
cd server
npm install
npm start
```

Listens on `ws://localhost:8080` by default (`PORT` env var overrides it).
The app connects to the server only for multiplayer battles; single-player,
daily, and stats all work offline.

### How to play multiplayer

1. Start the server and the app.
2. Device A: **Multiplayer** → name → **Create room** → share the code.
3. Device B: **Multiplayer** → name + code → **Join room**.
4. Both players get the same scrambled word each round and race to solve it.
   Scores and the winner come from the server.

## Protocol

Client → server: `create_room`, `join_room`, `submit_answer`, `next_round`

Server → client: `room_created`, `room_joined`, `match_started`, `new_word`,
`opponent_scored`, `game_over`, `player_left`, `error`

## Project Structure

```
lib/
├── core/                    # Theme, constants, router
├── features/
│   ├── word_scramble/       # Classic + daily gameplay
│   ├── multiplayer/         # Lobby + battle screens, socket layer
│   ├── home/                # Landing screen
│   ├── stats/               # Lifetime statistics
│   └── settings/            # Theme preference
└── shared/                  # Shared widgets
server/
├── src/
│   ├── index.js             # WebSocket entry + message handling
│   ├── rooms.js             # Room matchmaking
│   ├── game.js              # Match + round logic
│   └── words.js             # Word database
└── test/
    └── rooms.test.js
```

## Testing

```bash
flutter test   # 25 tests: scoring, scramble, game flow, multiplayer, daily
cd server && npm test   # 7 tests: match logic, rooms
```
