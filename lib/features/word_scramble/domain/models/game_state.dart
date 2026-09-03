import 'word.dart';

/// The current state of a single-player word scramble game.
class GameState {
  const GameState({
    required this.words,
    required this.roundIndex,
    required this.score,
    required this.streak,
    required this.maxStreak,
    required this.status,
    required this.roundStatus,
    required this.roundsWon,
    required this.roundsLost,
    this.currentScrambled = const [],
    this.foundWords = const [],
  });

  /// All words queued for this game, in order.
  final List<Word> words;

  /// Index of the round currently being played.
  final int roundIndex;

  final int score;
  final int streak;
  final int maxStreak;

  /// Overall game status.
  final GameStatus status;

  /// Status of the current round.
  final RoundStatus roundStatus;

  final int roundsWon;
  final int roundsLost;

  /// Scrambled letters for the current round.
  final List<String> currentScrambled;

  /// Words the player has solved so far.
  final List<String> foundWords;

  Word? get currentWord {
    if (roundIndex < 0 || roundIndex >= words.length) {
      return null;
    }
    return words[roundIndex];
  }

  bool get hasNextRound => roundIndex + 1 < words.length;

  bool get isFinished => status == GameStatus.won || status == GameStatus.lost;

  GameState copyWith({
    List<Word>? words,
    int? roundIndex,
    int? score,
    int? streak,
    int? maxStreak,
    GameStatus? status,
    RoundStatus? roundStatus,
    int? roundsWon,
    int? roundsLost,
    List<String>? currentScrambled,
    List<String>? foundWords,
  }) {
    return GameState(
      words: words ?? this.words,
      roundIndex: roundIndex ?? this.roundIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      status: status ?? this.status,
      roundStatus: roundStatus ?? this.roundStatus,
      roundsWon: roundsWon ?? this.roundsWon,
      roundsLost: roundsLost ?? this.roundsLost,
      currentScrambled: currentScrambled ?? this.currentScrambled,
      foundWords: foundWords ?? this.foundWords,
    );
  }
}

enum GameStatus {
  playing,
  won,
  lost,
}

enum RoundStatus {
  playing,
  solved,
  skipped,
  timedOut,
}
