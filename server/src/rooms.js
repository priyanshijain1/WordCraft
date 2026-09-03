'use strict';

const { Match } = require('./game');

// Manages rooms. A room holds two connected players and one live Match.
// The room is the server-side source of truth for who is in a game.

const ROOM_CODE_LENGTH = 6;
const CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // no confusing chars

class RoomManager {
  constructor() {
    this.rooms = new Map(); // code -> room
  }

  // Create a room with a unique code and the host's socket.
  createRoom(hostId, hostName) {
    const code = this._uniqueCode();
    const room = {
      code,
      match: new Match(),
      sockets: new Map(), // playerId -> socket
    };
    room.match.addPlayer(hostId, hostName);
    this.rooms.set(code, room);
    return room;
  }

  // Join an existing room as the guest. Returns the room when full.
  joinRoom(code, guestId, guestName) {
    const room = this.rooms.get(code);
    if (!room) {
      return null;
    }
    if (room.match.players.size >= 2) {
      return 'full';
    }
    room.match.addPlayer(guestId, guestName);
    return room;
  }

  // Store a player's socket in their room (for direct sends).
  attachSocket(code, playerId, socket) {
    const room = this.rooms.get(code);
    if (room) {
      room.sockets.set(playerId, socket);
    }
  }

  get(code) {
    return this.rooms.get(code);
  }

  // Remove a player; delete the room when it becomes empty.
  removeFromRoom(code, playerId) {
    const room = this.rooms.get(code);
    if (!room) {
      return null;
    }
    room.sockets.delete(playerId);
    if (room.sockets.size === 0) {
      this.rooms.delete(code);
      return null;
    }
    return room;
  }

  _uniqueCode() {
    let code;
    do {
      code = this._generateCode();
    } while (this.rooms.has(code));
    return code;
  }

  _generateCode() {
    let code = '';
    for (let i = 0; i < ROOM_CODE_LENGTH; i++) {
      const idx = Math.floor(Math.random() * CODE_ALPHABET.length);
      code += CODE_ALPHABET[idx];
    }
    return code;
  }
}

module.exports = { RoomManager, ROOM_CODE_LENGTH };
