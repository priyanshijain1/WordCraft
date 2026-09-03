import 'package:flutter_test/flutter_test.dart';
import 'package:wordcraft/features/word_scramble/domain/usecases/scoring_engine.dart';
import 'package:wordcraft/features/word_scramble/domain/usecases/scramble_engine.dart';

void main() {
  group('ScoringEngine', () {
    const engine = ScoringEngine();

    test('awards base points with no speed bonus', () {
      final points = engine.pointsForRound(secondsLeft: 0, streak: 0);
      expect(points, 100);
    });

    test('adds speed bonus per second left', () {
      final points = engine.pointsForRound(secondsLeft: 5, streak: 0);
      expect(points, 150);
    });

    test('applies 1.5x multiplier at streak 3', () {
      final points = engine.pointsForRound(secondsLeft: 0, streak: 3);
      expect(points, 150);
    });

    test('applies 2x multiplier at streak 5', () {
      final points = engine.pointsForRound(secondsLeft: 0, streak: 5);
      expect(points, 200);
    });

    test('skip penalty is positive', () {
      expect(engine.skipPenalty, greaterThan(0));
    });
  });

  group('ScrambleEngine', () {
    test('returns the same number of letters', () {
      final engine = ScrambleEngine();
      expect(engine.scramble('tiger').length, 5);
    });

    test('contains the same letters as the source word', () {
      final engine = ScrambleEngine();
      final scrambleSorted = [...engine.scramble('tiger')]..sort();
      final sourceSorted = 'tiger'.split('')..sort();
      expect(scrambleSorted, sourceSorted);
    });

    test('eventually produces a different order from the original', () {
      final engine = ScrambleEngine();
      var differCount = 0;
      for (var i = 0; i < 50; i++) {
        if (engine.scramble('abcdef').join() != 'abcdef') {
          differCount++;
        }
      }
      expect(differCount, greaterThan(0));
    });
  });
}
