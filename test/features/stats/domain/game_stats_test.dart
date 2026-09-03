import 'package:flutter_test/flutter_test.dart';
import 'package:wordcraft/features/stats/domain/models/game_stats.dart';

void main() {
  group('GameStats', () {
    test('defaults to zeros', () {
      const stats = GameStats();
      expect(stats.gamesPlayed, 0);
      expect(stats.wordsFound, 0);
      expect(stats.bestScore, 0);
      expect(stats.bestStreak, 0);
      expect(stats.totalTimeMs, 0);
    });

    test('mergeGame increments counts and accumulates time', () {
      const stats = GameStats(gamesPlayed: 1, wordsFound: 3, bestScore: 200);
      final merged = stats.mergeGame(
        score: 250,
        wordsFound: 4,
        maxStreak: 5,
        timeMs: 60000,
      );
      expect(merged.gamesPlayed, 2);
      expect(merged.wordsFound, 7);
      expect(merged.totalTimeMs, 60000);
      expect(merged.bestScore, 250);
      expect(merged.bestStreak, 5);
    });

    test('mergeGame keeps the higher best score', () {
      const stats = GameStats(bestScore: 400);
      final merged = stats.mergeGame(
        score: 150,
        wordsFound: 2,
        maxStreak: 1,
        timeMs: 0,
      );
      expect(merged.bestScore, 400);
    });

    test('mergeGame keeps the higher best streak', () {
      const stats = GameStats(bestStreak: 7);
      final merged = stats.mergeGame(
        score: 0,
        wordsFound: 1,
        maxStreak: 3,
        timeMs: 0,
      );
      expect(merged.bestStreak, 7);
    });
  });
}
