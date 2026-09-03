import '../models/game_stats.dart';

/// Abstraction over where stats are persisted.
///
/// The domain layer only knows this interface; the concrete Hive/any storage
/// implementation lives in the data layer.
abstract interface class StatsRepository {
  Future<GameStats> load();

  Future<void> save(GameStats stats);
}
