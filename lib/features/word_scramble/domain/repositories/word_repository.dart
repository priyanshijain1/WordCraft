import '../models/word.dart';

/// Abstraction over where word lists come from.
///
/// Implementations can pull words from an asset bundle, an API, or a local
/// database. The domain layer only depends on this interface.
abstract interface class WordRepository {
  /// Returns a random batch of [count] words from [category].
  ///
  /// Words are selected deterministically when [seed] is provided, which powers
  /// the daily challenge mode.
  List<Word> getWords({
    required int count,
    WordCategory? category,
    int? seed,
  });
}
