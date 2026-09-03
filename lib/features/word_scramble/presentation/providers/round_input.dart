/// Tracks the letters a player has selected while forming a word.
///
/// This is ephemeral UI state owned by the game provider. The provider decides
/// whether a completed selection is a valid word; this class only stores the
/// current selection.
class RoundInput {
  const RoundInput({
    this.letters = const [],
    this.selected = const [],
  });

  /// All scrambled letters available this round, in display order.
  final List<String> letters;

  /// Indices into [letters] that the player has tapped, in tap order.
  final List<int> selected;

  bool get isEmpty => selected.isEmpty;

  /// The word currently formed by the selected letters.
  String get currentText {
    final buffer = StringBuffer();
    for (final index in selected) {
      if (index >= 0 && index < letters.length) {
        buffer.write(letters[index]);
      }
    }
    return buffer.toString();
  }

  /// The letters the player has tapped so far, in order.
  List<String> get selectedLetters =>
      selected.map((i) => letters[i]).toList(growable: false);

  RoundInput withSelectedIndex(int index) {
    return RoundInput(
      letters: letters,
      selected: [...selected, index],
    );
  }

  RoundInput removingLast() {
    if (selected.isEmpty) {
      return this;
    }
    return RoundInput(
      letters: letters,
      selected: selected.sublist(0, selected.length - 1),
    );
  }

  RoundInput cleared() {
    return RoundInput(letters: letters);
  }
}
