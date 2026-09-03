import 'dart:math';

import '../../domain/models/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_data_source.dart';

/// Pulls words from the embedded [WordDataSource].
///
/// Synchronous and offline-capable. Uses an injectable [Random] so tests can
/// pass a seeded instance for reproducible selections.
class LocalWordRepository implements WordRepository {
  LocalWordRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  List<Word> getWords({
    required int count,
    WordCategory? category,
    int? seed,
  }) {
    final entries = category == null
        ? WordDataSource.all
        : WordDataSource.wordsFor(category.name)
            .map((w) => (w, category.name))
            .toList(growable: false);

    if (entries.isEmpty) {
      return const [];
    }

    final rng = seed == null ? _random : Random(seed);
    final shuffled = List<(String, String)>.of(entries)..shuffle(rng);
    return shuffled
        .take(count)
        .map((e) => _toWord(e.$1, e.$2))
        .toList(growable: false);
  }

  Word _toWord(String text, String category) {
    return Word(
      text: text,
      category: category,
      difficulty: _difficultyForLength(text.length),
    );
  }

  WordDifficulty _difficultyForLength(int length) {
    if (length <= WordDifficulty.easy.maxLetters) {
      return WordDifficulty.easy;
    }
    if (length <= WordDifficulty.medium.maxLetters) {
      return WordDifficulty.medium;
    }
    return WordDifficulty.hard;
  }
}
