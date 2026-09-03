/// Synchronous, embedded word database.
///
/// Keeping the list as a Dart constant (rather than an async asset load) makes
/// the repository simple, offline-capable, and trivially testable.
class WordDataSource {
  WordDataSource._();

  static const Map<String, List<String>> _byCategory = {
    'animals': ['tiger', 'eagle', 'snake', 'whale', 'panda', 'horse', 'camel', 'zebra', 'raven', 'koala'],
    'food': ['pizza', 'salad', 'sushi', 'bread', 'tacos', 'meatloaf', 'muffin', 'burger', 'noodle', 'curry'],
    'travel': ['plane', 'hotel', 'beach', 'cruise', 'train', 'trunk', 'sunset', 'passport', 'luggage'],
    'sports': ['tennis', 'golf', 'rugby', 'soccer', 'boxing', 'cricket', 'rowing', 'archery', 'jogging'],
    'nature': ['river', 'mountain', 'forest', 'ocean', 'valley', 'canyon', 'meadow', 'stream', 'glacier'],
  };

  /// All raw word strings with their category, in the form (text, category).
  static List<(String, String)> get all {
    final result = <(String, String)>[];
    _byCategory.forEach((category, words) {
      for (final word in words) {
        result.add((word, category));
      }
    });
    return result;
  }

  /// Raw words for a single category.
  static List<String> wordsFor(String category) =>
      _byCategory[category] ?? const [];
}
