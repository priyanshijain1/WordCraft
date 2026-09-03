'use strict';

const http = require('http');
const { WebSocketServer } = require('ws');
const { RoomManager } = require('./rooms');

const PORT = process.env.PORT || 8080;

const manager = new RoomManager();
const players = new Map(); // playerId -> { socket, name }

function send(socket, type, data = {}) {
  if (socket && socket.readyState === 1 /* OPEN */) {
    socket.send(JSON.stringify({ type, ...data }));
  }
}

function broadcast(room, type, data) {
  for (const socket of room.sockets.values()) {
    send(socket, type, data);
  }
}

function startMatch(room) {
  const round = room.match.start();
  broadcast(room, 'match_started', round);
}

function nextRound(room) {
  const round = room.match.startNextRound();
  if (!round) {
    broadcast(room, 'game_over', { standings: room.match.standings() });
    return;
  }
  broadcast(room, 'new_word', round);
}

function hostName(room, guestId) {
  const hostId = [...room.sockets.keys()].find((id) => id !== guestId);
  const meta = players.get(hostId);
  return meta ? meta.name : 'Opponent';
}

function registerPlayer(playerId, socket, name) {
  const cleanName = name || 'Player';
  players.set(playerId, { socket, name: cleanName });
  return cleanName;
}

function handleMessage(socket, raw) {
  let msg;
  try {
    msg = JSON.parse(raw);
  } catch (_err) {
    return;
  }

  switch (msg.type) {
    case 'create_room': {
      const playerId = msg.playerId;
      const name = registerPlayer(playerId, socket, msg.name);
      const room = manager.createRoom(playerId, name);
      manager.attachSocket(room.code, playerId, socket);
      send(socket, 'room_created', {
        roomCode: room.code,
        playerId,
        opponent: null,
      });
      break;
    }

    case 'join_room': {
      const playerId = msg.playerId;
      const code = String(msg.roomCode).toUpperCase();
      const result = manager.joinRoom(code, playerId, msg.name || 'Player');
      if (result === null) {
        send(socket, 'error', { message: 'Room not found' });
        break;
      }
      if (result === 'full') {
        send(socket, 'error', { message: 'Room is full' });
        break;
      }
      const room = result;
      const name = registerPlayer(playerId, socket, msg.name);
      manager.attachSocket(code, playerId, socket);
      send(socket, 'room_joined', {
        roomCode: code,
        playerId,
        opponent: hostName(room, playerId),
      });
      startMatch(room);
      break;
    }

    case 'submit_answer': {
      const room = manager.get(msg.roomCode);
      if (!room || !msg.playerId) {
        return;
      }
      const solved = room.match.solve(msg.playerId, msg.answer);
      if (!solved) {
        return;
      }
      broadcast(room, 'opponent_scored', {
        playerId: msg.playerId,
        score: room.match.players.get(msg.playerId).score,
      });
      if (room.match.allSolved()) {
        setTimeout(() => {
          if (room.match.finished) {
            broadcast(room, 'game_over', { standings: room.match.standings() });
          } else {
            nextRound(room);
          }
        }, 600);
      }
      break;
    }

    case 'next_round': {
      const room = manager.get(msg.roomCode);
      if (room && !room.match.finished) {
        nextRound(room);
      }
      break;
    }

    default:
      break;
  }
}

function handleClose(socket) {
  let playerId = null;
  for (const [id, entry] of players.entries()) {
    if (entry.socket === socket) {
      playerId = id;
      break;
    }
  }
  if (!playerId) {
    return;
  }
  players.delete(playerId);
  for (const room of manager.rooms.values()) {
    if (room.sockets.has(playerId)) {
      broadcast(room, 'player_left', { playerId });
      manager.removeFromRoom(room.code, playerId);
      break;
    }
  }
}

const server = http.createServer((_req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('WordCraft multiplayer server\n');
});

const wss = new WebSocketServer({ server });

wss.on('connection', (socket) => {
  socket.on('message', (raw) => handleMessage(socket, raw.toString()));
  socket.on('close', () => handleClose(socket));
  socket.on('error', () => {});
});

server.listen(PORT, () => {
  console.log(`WordCraft server listening on ws://localhost:${PORT}`);
});
