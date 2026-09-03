import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/game_stats.dart';
import '../../domain/repositories/stats_repository.dart';

/// Persists [GameStats] using shared_preferences.
///
/// Chosen for the project because it works reliably on Android, iOS, and
/// Flutter Web without extra setup. Values are serialized as a JSON string.
class SharedPrefsStatsRepository implements StatsRepository {
  SharedPrefsStatsRepository({required this.prefs});

  final SharedPreferences prefs;

  static const _key = 'stats';

  @override
  Future<GameStats> load() async {
    final raw = prefs.getString(_key);
    if (raw == null) {
      return const GameStats();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GameStats(
        gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
        wordsFound: (map['wordsFound'] as num?)?.toInt() ?? 0,
        bestScore: (map['bestScore'] as num?)?.toInt() ?? 0,
        bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
        totalTimeMs: (map['totalTimeMs'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return const GameStats();
    }
  }

  @override
  Future<void> save(GameStats stats) async {
    final map = {
      'gamesPlayed': stats.gamesPlayed,
      'wordsFound': stats.wordsFound,
      'bestScore': stats.bestScore,
      'bestStreak': stats.bestStreak,
      'totalTimeMs': stats.totalTimeMs,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
