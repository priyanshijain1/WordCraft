import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../stats/presentation/providers/stats_providers.dart';
import '../providers/game_provider.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordStats());
  }

  Future<void> _recordStats() async {
    if (_recorded) {
      return;
    }
    _recorded = true;
    final game = ref.read(gameProvider).game;
    // Only record when a real game was played and finished.
    if (!game.isFinished) {
      return;
    }
    await ref.read(statsProvider.notifier).recordGame(
          score: game.score,
          wordsFound: game.roundsWon,
          maxStreak: game.maxStreak,
          timeMs: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider).game;
    final won = game.status == GameStatus.won;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 96,
                color: won
                    ? const Color(0xFFFFC107)
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                won ? 'You Win!' : 'Better luck next time!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _StatRow(label: 'Final Score', value: '${game.score}'),
              const SizedBox(height: AppSpacing.md),
              _StatRow(label: 'Words Found', value: '${game.roundsWon}'),
              const SizedBox(height: AppSpacing.md),
              _StatRow(label: 'Best Streak', value: '${game.maxStreak}'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.read(gameProvider.notifier).startGame();
                  context.go(AppRoutes.game);
                },
                child: const Text('Play Again'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.tileDark : AppColors.tileLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
