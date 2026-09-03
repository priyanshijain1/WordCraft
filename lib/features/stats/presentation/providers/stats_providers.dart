import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/shared_prefs_stats_repository.dart';
import '../../domain/models/game_stats.dart';
import '../../domain/repositories/stats_repository.dart';

/// Provides the stats repository, constructed lazily once prefs are available.
final statsRepositoryProvider = FutureProvider<StatsRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPrefsStatsRepository(prefs: prefs);
});

class StatsNotifier extends AsyncNotifier<GameStats> {
  @override
  Future<GameStats> build() async {
    final repo = await ref.watch(statsRepositoryProvider.future);
    return repo.load();
  }

  /// Records a completed game's results into the persisted lifetime stats.
  Future<void> recordGame({
    required int score,
    required int wordsFound,
    required int maxStreak,
    required int timeMs,
  }) async {
    final repo = await ref.read(statsRepositoryProvider.future);
    final current = state.value ?? const GameStats();
    final merged = current.mergeGame(
      score: score,
      wordsFound: wordsFound,
      maxStreak: maxStreak,
      timeMs: timeMs,
    );
    await repo.save(merged);
    state = AsyncData(merged);
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, GameStats>(StatsNotifier.new);
