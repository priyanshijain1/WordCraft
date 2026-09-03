import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Thin WebSocket wrapper for the WordCraft multiplayer server.
///
/// Only handles transport: connecting, sending JSON messages, and exposing
/// incoming messages as a broadcast stream of decoded maps.
class MultiplayerDataSource {
  MultiplayerDataSource({String? url})
      : url = url ?? 'ws://localhost:8080';

  final String url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamSubscription? _subscription;

  Stream<Map<String, dynamic>> get messages {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  bool get isConnected => _channel != null;

  void connect() {
    disconnect();
    final channel = WebSocketChannel.connect(Uri.parse(url));
    _channel = channel;
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    _subscription = channel.stream.listen(
      (raw) {
        try {
          final decoded = jsonDecode(raw as String);
          if (decoded is Map<String, dynamic>) {
            _controller?.add(decoded);
          }
        } catch (_) {
          // Ignore malformed frames; the match state stays intact.
        }
      },
      onDone: disconnect,
    );
  }

  void send(String type, Map<String, dynamic> data) {
    final channel = _channel;
    if (channel == null) {
      return;
    }
    channel.sink.add(jsonEncode({'type': type, ...data}));
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {
      // Socket already closed; nothing to clean up.
    }
    _channel = null;
  }

  void dispose() {
    disconnect();
    _controller?.close();
    _controller = null;
  }
}
