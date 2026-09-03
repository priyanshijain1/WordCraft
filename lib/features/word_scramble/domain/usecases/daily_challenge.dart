/// Daily challenge: everyone gets the same puzzle each calendar day.
///
/// The puzzle is derived from a date-based seed passed to the word
/// repository, so no server or extra storage is needed.
class DailyChallenge {
  DailyChallenge._();

  /// Words per daily puzzle. Shorter than a classic game.
  static const int wordCount = 5;

  /// Deterministic seed for [date] (defaults to today). Same date on any
  /// device yields the same seed, hence the same puzzle.
  static int seedFor([DateTime? date]) {
    final day = date ?? DateTime.now();
    final dayOfYear = day.difference(DateTime(day.year, 1, 1)).inDays;
    return day.year * 1000 + dayOfYear;
  }

  /// Short label like "Sep 4" for display on the home screen.
  static String labelFor([DateTime? date]) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = date ?? DateTime.now();
    return '${months[day.month - 1]} ${day.day}';
  }
}
