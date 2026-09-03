/// Persisted lifetime statistics for a player.
class GameStats {
  const GameStats({
    this.gamesPlayed = 0,
    this.wordsFound = 0,
    this.bestScore = 0,
    this.bestStreak = 0,
    this.totalTimeMs = 0,
  });

  final int gamesPlayed;
  final int wordsFound;
  final int bestScore;
  final int bestStreak;
  final int totalTimeMs;

  GameStats copyWith({
    int? gamesPlayed,
    int? wordsFound,
    int? bestScore,
    int? bestStreak,
    int? totalTimeMs,
  }) {
    return GameStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wordsFound: wordsFound ?? this.wordsFound,
      bestScore: bestScore ?? this.bestScore,
      bestStreak: bestStreak ?? this.bestStreak,
      totalTimeMs: totalTimeMs ?? this.totalTimeMs,
    );
  }

  /// Merges a completed game's results into these lifetime stats.
  GameStats mergeGame({
    required int score,
    required int wordsFound,
    required int maxStreak,
    required int timeMs,
  }) {
    return copyWith(
      gamesPlayed: gamesPlayed + 1,
      wordsFound: this.wordsFound + wordsFound,
      bestScore: score > bestScore ? score : bestScore,
      bestStreak: maxStreak > bestStreak ? maxStreak : bestStreak,
      totalTimeMs: totalTimeMs + timeMs,
    );
  }
}
