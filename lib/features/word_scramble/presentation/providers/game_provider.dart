import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/game_state.dart';
import '../../domain/models/word.dart';
import '../../domain/usecases/scoring_engine.dart';
import '../../domain/usecases/scramble_engine.dart';
import '../providers/round_input.dart';
import '../providers/word_scramble_providers.dart';

/// A single play session's combined state: the domain game state plus the
/// player's letter selection and remaining time. Kept separate from the raw
/// [GameState] so the provider exposes exactly what the UI needs.
class GameSession {
  const GameSession({
    required this.game,
    required this.input,
    required this.secondsLeft,
  });

  final GameState game;
  final RoundInput input;
  final int secondsLeft;

  GameSession copyWith({
    GameState? game,
    RoundInput? input,
    int? secondsLeft,
  }) {
    return GameSession(
      game: game ?? this.game,
      input: input ?? this.input,
      secondsLeft: secondsLeft ?? this.secondsLeft,
    );
  }
}

class GameProvider extends Notifier<GameSession> {
  @override
  GameSession build() {
    return const GameSession(
      game: GameState(
        words: [],
        roundIndex: 0,
        score: 0,
        streak: 0,
        maxStreak: 0,
        status: GameStatus.playing,
        roundStatus: RoundStatus.playing,
        roundsWon: 0,
        roundsLost: 0,
      ),
      input: RoundInput(),
      secondsLeft: 0,
    );
  }

  WordRepository get _repo => ref.read(wordRepositoryProvider);
  ScrambleEngine get _scrambler => ref.read(scrambleEngineProvider);
  ScoringEngine get _scoring => ref.read(scoringEngineProvider);

  /// Starts a new game from the given category (or any).
  void startGame({WordCategory? category, int words = 0}) {
    final count = words > 0 ? words : 8;
    final wordsList = _repo.getWords(count: count, category: category);
    final game = GameState(
      words: wordsList,
      roundIndex: 0,
      score: 0,
      streak: 0,
      maxStreak: 0,
      status: GameStatus.playing,
      roundStatus: RoundStatus.playing,
      roundsWon: 0,
      roundsLost: 0,
      currentScrambled: wordsList.isEmpty ? const [] : _scrambler.scramble(wordsList.first.text),
    );
    state = GameSession(
      game: game,
      input: RoundInput(letters: game.currentScrambled),
      secondsLeft: 30,
    );
  }

  /// Taps a scrambled letter by its index.
  void selectLetter(int index) {
    if (!_isPlaying) {
      return;
    }
    final input = state.input;
    if (input.selected.contains(index)) {
      return;
    }
    state = state.copyWith(input: input.withSelectedIndex(index));
  }

  /// Removes the last tapped letter.
  void undoLetter() {
    if (!_isPlaying) {
      return;
    }
    state = state.copyWith(input: state.input.removingLast());
  }

  /// Checks the currently formed word.
  void submit() {
    if (!_isPlaying) {
      return;
    }
    final word = state.input.currentText;
    final currentWord = state.game.currentWord;
    if (word.isEmpty || currentWord == null) {
      return;
    }

    if (word == currentWord.text) {
      _onSolved();
    } else {
      _onWrong();
    }
  }

  /// Skips the current word.
  void skip() {
    if (!_isPlaying) {
      return;
    }
    final game = state.game;
    final afterPenalty = game.score - _scoring.skipPenalty;
    final newScore = afterPenalty < 0 ? 0 : afterPenalty;
    _advanceRound(
      game.copyWith(
        score: newScore,
        streak: 0,
        roundStatus: RoundStatus.skipped,
        roundsLost: game.roundsLost + 1,
      ),
    );
  }

  /// Called when the round timer reaches zero.
  void onTimeout() {
    if (!_isPlaying) {
      return;
    }
    final game = state.game;
    _advanceRound(
      game.copyWith(
        streak: 0,
        roundStatus: RoundStatus.timedOut,
        roundsLost: game.roundsLost + 1,
      ),
    );
  }

  /// Updates the current round's remaining time.
  void tick(int secondsLeft) {
    state = state.copyWith(secondsLeft: secondsLeft);
  }

  bool get _isPlaying =>
      !state.game.isFinished && state.game.roundStatus == RoundStatus.playing;

  void _onSolved() {
    final game = state.game;
    final newStreak = game.streak + 1;
    final points = _scoring.pointsForRound(
      secondsLeft: state.secondsLeft,
      streak: newStreak,
    );
    final newScore = game.score + points;
    final nextWord = game.currentWord;

    final updated = game.copyWith(
      score: newScore,
      streak: newStreak,
      maxStreak: newStreak > game.maxStreak ? newStreak : game.maxStreak,
      roundStatus: RoundStatus.solved,
      roundsWon: game.roundsWon + 1,
      foundWords: nextWord == null ? game.foundWords : [...game.foundWords, nextWord.text],
    );

    _advanceRound(updated);
  }

  void _onWrong() {
    // Wrong answers reset the streak but keep the round running.
    final game = state.game;
    state = state.copyWith(game: game.copyWith(streak: 0));
  }

  void _advanceRound(GameState updated) {
    final hasNext = updated.hasNextRound;
    if (!hasNext) {
      final won = updated.roundsWon >= updated.roundsLost;
      final finished = updated.copyWith(status: won ? GameStatus.won : GameStatus.lost);
      state = GameSession(
        game: finished,
        input: RoundInput(),
        secondsLeft: 0,
      );
      return;
    }

    final nextIndex = updated.roundIndex + 1;
    final nextWord = updated.words[nextIndex];
    final scrambled = _scrambler.scramble(nextWord.text);
    final advanced = updated.copyWith(
      roundIndex: nextIndex,
      roundStatus: RoundStatus.playing,
      currentScrambled: scrambled,
    );
    state = GameSession(
      game: advanced,
      input: RoundInput(letters: scrambled),
      secondsLeft: 30,
    );
  }
}

final gameProvider =
    NotifierProvider<GameProvider, GameSession>(GameProvider.new);
