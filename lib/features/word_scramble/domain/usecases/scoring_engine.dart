import '../../../core/constants/app_constants.dart';

/// Calculates scores for a word scramble game.
///
/// Pure Dart, no Flutter imports, so it is trivially unit-testable.
class ScoringEngine {
  const ScoringEngine();

  /// Points awarded for solving the current round.
  ///
  /// Base points plus a speed bonus for finishing before the timer ends, then
  /// scaled by the current streak multiplier.
  int pointsForRound({
    required int secondsLeft,
    required int streak,
  }) {
    final speedBonus = secondsLeft > 0
        ? secondsLeft * GameConstants.pointsPerSecondLeft
        : 0;
    final base = GameConstants.basePoints + speedBonus;
    final multiplier = streakMultiplier(streak);
    return (base * multiplier).round();
  }

  /// Streak multiplier: x1.5 at 3+ streak, x2 at 5+ streak.
  double streakMultiplier(int streak) {
    if (streak >= 5) {
      return 2;
    }
    if (streak >= 3) {
      return 1.5;
    }
    return 1;
  }

  /// Points deducted when the player skips a word.
  int get skipPenalty => GameConstants.skipPenalty;
}
