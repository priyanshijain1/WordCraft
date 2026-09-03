import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_word_repository.dart';
import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/scoring_engine.dart';
import '../../domain/usecases/scramble_engine.dart';

/// Dependency injection for the word scramble feature.
///
/// Only the presentation layer constructs these concrete implementations and
/// exposes them as providers; the rest of the app depends on the interfaces.

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => LocalWordRepository(),
);

final scrambleEngineProvider = Provider<ScrambleEngine>(
  (ref) => ScrambleEngine(),
);

final scoringEngineProvider = Provider<ScoringEngine>(
  (ref) => const ScoringEngine(),
);
