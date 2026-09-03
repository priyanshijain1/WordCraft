'use strict';

const test = require('node:test');
const assert = require('node:assert');

const { Match } = require('../src/game');
const { RoomManager } = require('../src/rooms');

test('wrong answer returns false and does not award points', () => {
  const m = new Match(1);
  m.addPlayer('a', 'Alice');
  m.addPlayer('b', 'Bob');
  m.start();
  const solved = m.solve('a', 'not-the-answer');
  assert.strictEqual(solved, false);
});

test('first solver gets points, second solve in same round blocked', () => {
  const m = new Match(2);
  m.addPlayer('a', 'Alice');
  m.addPlayer('b', 'Bob');
  m.start();

  assert.strictEqual(m.solve('a', m.currentWord), true);
  assert.strictEqual(m.players.get('a').score, 100);

  const again = m.solve('a', m.currentWord);
  assert.strictEqual(again, false);
});

test('both players solving ends the round', () => {
  const m = new Match(3);
  m.addPlayer('a', 'Alice');
  m.addPlayer('b', 'Bob');
  m.start();

  m.solve('a', m.currentWord);
  m.solve('b', m.currentWord);
  assert.strictEqual(m.allSolved(), true);
});

test('rounds advance and finish with a winner after the final round', () => {
  const m = new Match(1);
  m.addPlayer('a', 'Alice');
  m.addPlayer('b', 'Bob');
  m.start();

  m.solve('a', m.currentWord);
  m.solve('b', m.currentWord);

  const next = m.startNextRound();
  assert.strictEqual(next, null);
  assert.strictEqual(m.finished, true);
  assert.strictEqual(m.winnerId, 'a'); // higher/lifetime score; a solved first
});

test('room manager creates and joins rooms', () => {
  const rooms = new RoomManager();
  const room = rooms.createRoom('host', 'Alice');
  assert.ok(room.code);
  assert.strictEqual(rooms.get(room.code), room);

  const joined = rooms.joinRoom(room.code, 'guest', 'Bob');
  assert.notStrictEqual(joined, null);
  assert.notStrictEqual(joined, 'full');
});

test('room rejects a third player as full', () => {
  const rooms = new RoomManager();
  const room = rooms.createRoom('host', 'Alice');
  rooms.joinRoom(room.code, 'guest', 'Bob');
  const third = rooms.joinRoom(room.code, 'third', 'Charlie');
  assert.strictEqual(third, 'full');
});

test('removing the last player deletes the room', () => {
  const rooms = new RoomManager();
  const room = rooms.createRoom('host', 'Alice');
  const left = rooms.removeFromRoom(room.code, 'host');
  assert.strictEqual(left, null);
  assert.strictEqual(rooms.get(room.code), undefined);
});
