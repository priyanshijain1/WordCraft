/// A single word used in a puzzle round.
class Word {
  const Word({
    required this.text,
    required this.category,
    required this.difficulty,
  });

  final String text;
  final String category;
  final WordDifficulty difficulty;

  int get length => text.length;

  /// The letters of the word in the correct order.
  List<String> get letters => text.split('');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          category == other.category &&
          difficulty == other.difficulty;

  @override
  int get hashCode => Object.hash(text, category, difficulty);
}

enum WordDifficulty {
  easy,
  medium,
  hard;

  /// Approximate letters used to classify difficulty.
  int get maxLetters {
    switch (this) {
      case WordDifficulty.easy:
        return 5;
      case WordDifficulty.medium:
        return 6;
      case WordDifficulty.hard:
        return 7;
    }
  }
}

enum WordCategory {
  animals,
  food,
  travel,
  sports,
  nature,
}
