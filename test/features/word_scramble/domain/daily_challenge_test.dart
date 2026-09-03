import 'package:flutter_test/flutter_test.dart';
import 'package:wordcraft/features/word_scramble/domain/usecases/daily_challenge.dart';

void main() {
  test('same date yields the same seed', () {
    final a = DailyChallenge.seedFor(DateTime(2026, 9, 4));
    final b = DailyChallenge.seedFor(DateTime(2026, 9, 4, 23, 59));
    expect(a, b);
  });

  test('different dates yield different seeds', () {
    final a = DailyChallenge.seedFor(DateTime(2026, 9, 4));
    final b = DailyChallenge.seedFor(DateTime(2026, 9, 5));
    expect(a, isNot(b));
  });

  test('label shows short month and day', () {
    expect(DailyChallenge.labelFor(DateTime(2026, 9, 4)), 'Sep 4');
  });
}
