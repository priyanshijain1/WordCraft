'use strict';

const { randomWord, scramble } = require('./words');

// A head-to-head word scramble match between two players.
//
// The match owns the current round, each player's score, and round progression.
// Both players are sent the same scrambled word each round and race to be first.

const DEFAULT_ROUNDS = 5;
const POINTS_PER_SOLVE = 100;

class Match {
  constructor(rounds = DEFAULT_ROUNDS) {
    this.rounds = rounds;
    this.currentRound = 0;
    this.players = new Map(); // playerId -> { name, score, solvedCurrent }
    this.currentWord = null;
    this.currentScrambled = null;
    this.finished = false;
    this.winnerId = null;
  }

  addPlayer(id, name) {
    this.players.set(id, { name, score: 0, solvedCurrent: false });
  }

  // Start the first round and return the round data.
  start() {
    return this.startNextRound();
  }

  startNextRound() {
    if (this.currentRound >= this.rounds) {
      this._finish();
      return null;
    }

    this.currentRound++;
    this.currentWord = randomWord(this.currentWord);
    this.currentScrambled = scramble(this.currentWord);
    for (const p of this.players.values()) {
      p.solvedCurrent = false;
    }
    return this.roundData();
  }

  // A player claims they solved the current word. Only the first solver per
  // round earns points.
  solve(playerId, answer) {
    if (this.finished || !this.players.has(playerId)) {
      return false;
    }
    const player = this.players.get(playerId);
    if (player.solvedCurrent || answer !== this.currentWord) {
      return false;
    }
    player.solvedCurrent = true;
    player.score += POINTS_PER_SOLVE;
    return true;
  }

  // True when both players have solved the current round.
  allSolved() {
    const values = [...this.players.values()];
    return values.every((p) => p.solvedCurrent);
  }

  // Round payload to broadcast to players (no answers leaked).
  roundData() {
    return {
      round: this.currentRound,
      totalRounds: this.rounds,
      scrambled: this.currentScrambled,
      players: [...this.players.entries()].map(([id, p]) => ({
        id,
        name: p.name,
        score: p.score,
      })),
    };
  }

  standings() {
    return [...this.players.entries()]
      .map(([id, p]) => ({ id, name: p.name, score: p.score }))
      .sort((a, b) => b.score - a.score);
  }

  _finish() {
    this.finished = true;
    const [first] = this.standings();
    this.winnerId = first ? first.id : null;
  }
}

module.exports = { Match, DEFAULT_ROUNDS, POINTS_PER_SOLVE };
