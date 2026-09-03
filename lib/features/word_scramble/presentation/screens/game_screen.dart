import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/letter_tile_widget.dart';
import '../../../shared/widgets/timer_display.dart';
import '../providers/game_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(gameProvider).game.words.isEmpty) {
        ref.read(gameProvider.notifier).startGame();
      }
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final provider = ref.read(gameProvider.notifier);
      final secondsLeft = ref.read(gameProvider).secondsLeft;
      if (secondsLeft <= 0) {
        provider.onTimeout();
        return;
      }
      provider.tick(secondsLeft - 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);

    ref.listen<bool>(
      gameProvider.select((s) => s.game.isFinished),
      (prev, isFinished) {
        if (isFinished && !(prev ?? false)) {
          context.go(AppRoutes.results);
        }
      },
    );

    if (session.game.isFinished) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(session),
            const Spacer(),
            _buildScrambleGrid(session),
            const SizedBox(height: AppSpacing.lg),
            _buildInputStrip(session),
            const SizedBox(height: AppSpacing.xl),
            _buildControls(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          TimerDisplay(
            secondsLeft: session.secondsLeft,
            totalSeconds: GameConstants.timePerWord.inSeconds,
          ),
          const Spacer(),
          _ScorePill(label: 'Score', value: '${session.game.score}'),
          const SizedBox(width: AppSpacing.sm),
          _ScorePill(label: 'Streak', value: '${session.game.streak}'),
        ],
      ),
    );
  }

  Widget _buildScrambleGrid(GameSession session) {
    final letters = session.input.letters;
    final selected = session.input.selected;
    if (letters.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: List.generate(letters.length, (index) {
          return LetterTile(
            letter: letters[index],
            size: 64,
            isSelected: selected.contains(index),
            onTap: selected.contains(index)
                ? null
                : () => ref.read(gameProvider.notifier).selectLetter(index),
          );
        }),
      ),
    );
  }

  Widget _buildInputStrip(GameSession session) {
    final selectedLetters = session.input.selectedLetters;
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: selectedLetters.isEmpty
            ? const [Text('Tap letters to form a word')]
            : List.generate(selectedLetters.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: LetterTile(
                    letter: selectedLetters[index],
                    size: 48,
                    isSelected: true,
                  ),
                );
              }),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.backspace_outlined,
            label: 'Undo',
            onTap: () => ref.read(gameProvider.notifier).undoLetter(),
          ),
          _ControlButton(
            icon: Icons.check,
            label: 'Submit',
            onTap: () => ref.read(gameProvider.notifier).submit(),
          ),
          _ControlButton(
            icon: Icons.skip_next,
            label: 'Skip',
            onTap: () => ref.read(gameProvider.notifier).skip(),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.tileDark : AppColors.tileLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.tileDark : AppColors.tileLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}
