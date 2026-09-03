import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/multiplayer_models.dart';
import '../providers/multiplayer_providers.dart';

/// Live head-to-head battle.
///
/// Both players see the same scrambled word each round and race to solve it.
/// Scores and the winner come from the server; this screen only displays them.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(multiplayerProvider);
    final notifier = ref.read(multiplayerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.roomCode == null ? 'Battle' : 'Room ${state.roomCode}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            notifier.leave();
            context.go(AppRoutes.lobby);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _body(context, state, notifier),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    MultiplayerState state,
    MultiplayerNotifier notifier,
  ) {
    if (state.status == MultiplayerStatus.finished) {
      return _resultsView(state);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _scoreboard(state),
        if (state.opponentLeft) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text('Your opponent left the match.'),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          state.totalRounds > 0 ? 'Round ${state.round}/${state.totalRounds}' : '',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          state.scrambled.isEmpty ? '...' : state.scrambled.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _answerController,
          textCapitalization: TextCapitalization.none,
          decoration: const InputDecoration(
            labelText: 'Your answer',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(notifier),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: () => _submit(notifier),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _scoreboard(MultiplayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _scoreTile('You', state.myScore),
        _scoreTile(state.opponentName ?? 'Opponent', state.opponentScore),
      ],
    );
  }

  Widget _scoreTile(String label, int score) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          '$score',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _resultsView(MultiplayerState state) {
    final standings = state.standings;
    final winner = standings.isEmpty ? null : standings.first;
    final iWon = winner != null && winner.id == state.playerId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          iWon ? 'You win!' : '${winner?.name ?? 'Opponent'} wins',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final s in standings)
          ListTile(
            title: Text(s.id == state.playerId ? '${s.name} (you)' : s.name),
            trailing: Text('${s.score}'),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            ref.read(multiplayerProvider.notifier).leave();
            context.go(AppRoutes.lobby);
          },
          child: const Text('Back to lobby'),
        ),
      ],
    );
  }

  void _submit(MultiplayerNotifier notifier) {
    final answer = _answerController.text.trim().toLowerCase();
    if (answer.isEmpty) {
      return;
    }
    notifier.submitAnswer(answer);
    _answerController.clear();
  }
}
