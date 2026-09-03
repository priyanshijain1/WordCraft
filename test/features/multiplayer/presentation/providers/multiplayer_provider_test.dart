import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordcraft/features/multiplayer/data/multiplayer_data_source.dart';
import 'package:wordcraft/features/multiplayer/domain/models/multiplayer_models.dart';
import 'package:wordcraft/features/multiplayer/presentation/providers/multiplayer_providers.dart';

class FakeSocket extends MultiplayerDataSource {
  FakeSocket() : super(url: 'ws://test');

  final controller = StreamController<Map<String, dynamic>>.broadcast();
  final sent = <Map<String, dynamic>>[];

  @override
  Stream<Map<String, dynamic>> get messages => controller.stream;

  @override
  bool get isConnected => true;

  @override
  void connect() {}

  @override
  void send(String type, Map<String, dynamic> data) {
    sent.add({'type': type, ...data});
  }

  @override
  void disconnect() {}

  @override
  void dispose() {
    controller.close();
  }

  void emit(Map<String, dynamic> msg) => controller.add(msg);
}

ProviderContainer makeContainer(FakeSocket socket) {
  return ProviderContainer(
    overrides: [
      multiplayerDataSourceProvider.overrideWithValue(socket),
    ],
  );
}

Future<void> settle() => Future.delayed(const Duration(milliseconds: 20));

void main() {
  test('createRoom sends a create_room message', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);

    container.read(multiplayerProvider.notifier).createRoom('Alice');
    expect(socket.sent.single['type'], 'create_room');
    expect(socket.sent.single['name'], 'Alice');
  });

  test('room_created moves to waiting with the room code', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);

    container.read(multiplayerProvider.notifier).createRoom('Alice');
    socket.emit({'type': 'room_created', 'roomCode': 'ABC123'});
    await settle();

    final state = container.read(multiplayerProvider);
    expect(state.status, MultiplayerStatus.waiting);
    expect(state.roomCode, 'ABC123');
  });

  test('match_started moves to playing with the scrambled word', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);
    container.read(multiplayerProvider);

    socket.emit({
      'type': 'match_started',
      'round': 1,
      'totalRounds': 5,
      'scrambled': 'elppa',
      'players': [
        {'id': 'a', 'name': 'Alice', 'score': 0},
        {'id': 'b', 'name': 'Bob', 'score': 0},
      ],
    });
    await settle();

    final state = container.read(multiplayerProvider);
    expect(state.status, MultiplayerStatus.playing);
    expect(state.scrambled, 'elppa');
    expect(state.players, hasLength(2));
  });

  test('opponent_scored updates that player score', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);
    container.read(multiplayerProvider);

    socket.emit({
      'type': 'match_started',
      'round': 1,
      'totalRounds': 5,
      'scrambled': 'elppa',
      'players': [
        {'id': 'a', 'name': 'Alice', 'score': 0},
        {'id': 'b', 'name': 'Bob', 'score': 0},
      ],
    });
    await settle();
    socket.emit({'type': 'opponent_scored', 'playerId': 'b', 'score': 100});
    await settle();

    final state = container.read(multiplayerProvider);
    expect(state.players.last.score, 100);
  });

  test('game_over moves to finished with standings', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);
    container.read(multiplayerProvider);

    socket.emit({
      'type': 'game_over',
      'standings': [
        {'id': 'a', 'name': 'Alice', 'score': 300},
        {'id': 'b', 'name': 'Bob', 'score': 200},
      ],
    });
    await settle();

    final state = container.read(multiplayerProvider);
    expect(state.status, MultiplayerStatus.finished);
    expect(state.standings.first.name, 'Alice');
  });

  test('error message disconnects with the message', () async {
    final socket = FakeSocket();
    final container = makeContainer(socket);
    addTearDown(container.dispose);
    container.read(multiplayerProvider);

    socket.emit({'type': 'error', 'message': 'Room not found'});
    await settle();

    final state = container.read(multiplayerProvider);
    expect(state.status, MultiplayerStatus.disconnected);
    expect(state.errorMessage, 'Room not found');
  });
}
