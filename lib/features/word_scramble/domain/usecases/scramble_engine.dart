import 'dart:math';

/// Produces scrambled letter arrangements from a source word.
///
/// Kept as pure Dart with no Flutter imports so the exact same logic can be
/// reused by the Node.js server if needed (or mirrored there).
class ScrambleEngine {
  ScrambleEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Scrambles the letters of [word] into a shuffled list.
  ///
  /// Guarantees the result differs from the original order so the puzzle is
  /// never trivially solved.
  List<String> scramble(String word) {
    final letters = word.split('');
    var attempts = 0;
    List<String> shuffled;

    do {
      shuffled = List.of(letters)..shuffle(_random);
      attempts++;
    } while (attempts < 20 && shuffled.join() == word);

    return shuffled;
  }
}
