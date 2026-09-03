import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordcraft/features/word_scramble/domain/models/game_state.dart';
import 'package:wordcraft/features/word_scramble/domain/models/word.dart';
import 'package:wordcraft/features/word_scramble/domain/repositories/word_repository.dart';
import 'package:wordcraft/features/word_scramble/domain/usecases/scramble_engine.dart';
import 'package:wordcraft/features/word_scramble/presentation/providers/game_provider.dart';
import 'package:wordcraft/features/word_scramble/presentation/providers/word_scramble_providers.dart';

class _FakeWordRepo implements WordRepository {
  _FakeWordRepo(this.words);

  final List<Word> words;

  @override
  List<Word> getWords({
    required int count,
    WordCategory? category,
    int? seed,
  }) {
    return words;
  }
}

class _ReverseScramble extends ScrambleEngine {
  @override
  List<String> scramble(String word) => word.split('').reversed.toList();
}

/// For a reversed 5-letter scramble, the correct answer is found by tapping
/// indices [4,3,2,1,0].
const _solveIndices = [4, 3, 2, 1, 0];

void main() {
  late ProviderContainer container;

  ProviderContainer makeContainer(List<Word> words) {
    return ProviderContainer(
      overrides: [
        wordRepositoryProvider.overrideWithValue(_FakeWordRepo(words)),
        scrambleEngineProvider.overrideWithValue(_ReverseScramble()),
      ],
    );
  }

  setUp(() {
    container = makeContainer(const [
      Word(text: 'tiger', category: 'animals', difficulty: WordDifficulty.easy),
      Word(text: 'eagle', category: 'animals', difficulty: WordDifficulty.easy),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  void startGame() {
    container.read(gameProvider.notifier).startGame();
  }

  void solveCurrentRound() {
    final provider = container.read(gameProvider.notifier);
    for (final index in _solveIndices) {
      provider.selectLetter(index);
    }
    provider.submit();
  }

  test('starts a game with the provided words in playing state', () {
    startGame();

    final session = container.read(gameProvider);
    expect(session.game.words.length, 2);
    expect(session.game.status, GameStatus.playing);
    expect(session.input.letters, ['r', 'e', 'g', 'i', 't']);
  });

  test('submitting a correct word advances the round and scores points', () {
    startGame();
    solveCurrentRound();

    final session = container.read(gameProvider);
    expect(session.game.roundIndex, 1);
    expect(session.game.score, greaterThan(0));
    expect(session.game.roundsWon, 1);
  });

  test('submitting a wrong word resets the streak but keeps the round', () {
    startGame();

    final provider = container.read(gameProvider.notifier);
    provider.selectLetter(0);
    provider.submit();

    final session = container.read(gameProvider);
    expect(session.game.streak, 0);
    expect(session.game.roundIndex, 0);
    expect(session.game.status, GameStatus.playing);
  });

  test('finishes the game as won after solving every round', () {
    startGame();
    solveCurrentRound();
    expect(container.read(gameProvider).game.roundIndex, 1);
    solveCurrentRound();

    final session = container.read(gameProvider);
    expect(session.game.isFinished, isTrue);
    expect(session.game.status, GameStatus.won);
  });
}
