import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/multiplayer_models.dart';
import '../providers/multiplayer_providers.dart';

/// Create or join a head-to-head match.
///
/// The host creates a room and shares the 6-letter code; the guest joins with
/// it. Both players are moved to the battle screen once the match starts.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _name =>
      _nameController.text.trim().isEmpty ? 'Player' : _nameController.text.trim();

  @override
  Widget build(BuildContext context) {
    ref.listen<MultiplayerState>(multiplayerProvider, (previous, next) {
      if (next.status == MultiplayerStatus.playing) {
        context.go(AppRoutes.battle);
      }
    });
    final state = ref.watch(multiplayerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _body(context, state),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MultiplayerState state) {
    if (state.status == MultiplayerStatus.waiting && state.roomCode != null) {
      return _waitingView(state);
    }
    return ListView(
      children: [
        Text(
          'Play a friend',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Host a room and share the code, or join with a code.'),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: state.status == MultiplayerStatus.connecting
              ? null
              : () => ref.read(multiplayerProvider.notifier).createRoom(_name),
          icon: const Icon(Icons.add),
          label: const Text('Create room'),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Room code',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: state.status == MultiplayerStatus.connecting
              ? null
              : () => ref
                  .read(multiplayerProvider.notifier)
                  .joinRoom(_codeController.text, _name),
          icon: const Icon(Icons.login),
          label: const Text('Join room'),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _waitingView(MultiplayerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          'Room ${state.roomCode}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Share this code with your friend.\nThe match starts when they join.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Center(child: CircularProgressIndicator()),
        const Spacer(),
        OutlinedButton(
          onPressed: () => ref.read(multiplayerProvider.notifier).leave(),
          child: const Text('Leave room'),
        ),
      ],
    );
  }
}
