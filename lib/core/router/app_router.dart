import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/word_scramble/presentation/screens/game_screen.dart';
import '../../features/word_scramble/presentation/screens/results_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const game = '/game';
  static const results = '/results';
  static const stats = '/stats';
  static const settings = '/settings';
}

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.stats,
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
