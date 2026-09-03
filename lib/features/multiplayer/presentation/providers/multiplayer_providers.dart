import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/multiplayer_data_source.dart';
import '../../domain/models/multiplayer_models.dart';

/// Owns the WebSocket connection; disposed with the provider.
final multiplayerDataSourceProvider = Provider<MultiplayerDataSource>((ref) {
  final dataSource = MultiplayerDataSource();
  ref.onDispose(dataSource.dispose);
  return dataSource;
});

/// Interprets server messages into match state.
///
/// The server is the source of truth: this notifier never decides scores or
/// winners, it only reflects what the server broadcasts.
class MultiplayerNotifier extends Notifier<MultiplayerState> {
  StreamSubscription? _subscription;

  MultiplayerDataSource get _socket => ref.read(multiplayerDataSourceProvider);

  @override
  MultiplayerState build() {
    final socket = ref.watch(multiplayerDataSourceProvider);
    _subscription?.cancel();
    _subscription = socket.messages.listen(_handleMessage);
    ref.onDispose(() => _subscription?.cancel());
    return const MultiplayerState();
  }

  String _newPlayerId() {
    final random = Random().nextInt(1 << 32).toRadixString(16);
    return 'p_${DateTime.now().microsecondsSinceEpoch}_$random';
  }

  void createRoom(String name) {
    final socket = _socket;
    if (!socket.isConnected) {
      socket.connect();
    }
    final playerId = _newPlayerId();
    state = MultiplayerState(
      status: MultiplayerStatus.connecting,
      playerId: playerId,
      playerName: name,
    );
    socket.send('create_room', {'playerId': playerId, 'name': name});
  }

  void joinRoom(String code, String name) {
    final socket = _socket;
    if (!socket.isConnected) {
      socket.connect();
    }
    final playerId = _newPlayerId();
    state = MultiplayerState(
      status: MultiplayerStatus.connecting,
      playerId: playerId,
      playerName: name,
    );
    socket.send('join_room', {
      'playerId': playerId,
      'roomCode': code.trim().toUpperCase(),
      'name': name,
    });
  }

  void submitAnswer(String answer) {
    final roomCode = state.roomCode;
    final playerId = state.playerId;
    if (roomCode == null || playerId == null) {
      return;
    }
    _socket.send('submit_answer', {
      'roomCode': roomCode,
      'playerId': playerId,
      'answer': answer,
    });
  }

  void requestNextRound() {
    final roomCode = state.roomCode;
    if (roomCode == null) {
      return;
    }
    _socket.send('next_round', {'roomCode': roomCode});
  }

  void leave() {
    _socket.disconnect();
    state = const MultiplayerState();
  }

  void clearError() {
    state = state.copyWith();
  }

  void _handleMessage(Map<String, dynamic> msg) {
    switch (msg['type']) {
      case 'room_created':
        state = state.copyWith(
          status: MultiplayerStatus.waiting,
          roomCode: msg['roomCode'] as String?,
        );
        break;
      case 'room_joined':
        state = state.copyWith(
          status: MultiplayerStatus.waiting,
          roomCode: msg['roomCode'] as String?,
          opponentName: msg['opponent'] as String?,
        );
        break;
      case 'match_started':
      case 'new_word':
        state = state.copyWith(
          status: MultiplayerStatus.playing,
          round: (msg['round'] as num?)?.toInt() ?? 0,
          totalRounds: (msg['totalRounds'] as num?)?.toInt() ?? 0,
          scrambled: msg['scrambled'] as String? ?? '',
          players: parsePlayers(msg['players']),
        );
        break;
      case 'opponent_scored': {
        final id = msg['playerId'] as String?;
        final score = (msg['score'] as num?)?.toInt() ?? 0;
        state = state.copyWith(
          players: [
            for (final p in state.players)
              if (p.id == id)
                MatchPlayer(id: p.id, name: p.name, score: score)
              else
                p,
          ],
        );
        break;
      }
      case 'game_over':
        state = state.copyWith(
          status: MultiplayerStatus.finished,
          standings: parsePlayers(msg['standings']),
        );
        break;
      case 'player_left':
        state = state.copyWith(opponentLeft: true);
        break;
      case 'error':
        state = state.copyWith(
          status: MultiplayerStatus.disconnected,
          errorMessage: msg['message'] as String? ?? 'Something went wrong',
        );
        break;
      default:
        break;
    }
  }
}

final multiplayerProvider =
    NotifierProvider<MultiplayerNotifier, MultiplayerState>(
  MultiplayerNotifier.new,
);
