/// Server-driven multiplayer match state.
///
/// Field names mirror the WebSocket protocol in PROJECT_PLAN.md so JSON
/// parsing stays trivial. The server is the source of truth for scoring.
enum MultiplayerStatus {
  disconnected,
  connecting,
  waiting,
  playing,
  finished,
}

class MatchPlayer {
  const MatchPlayer({
    required this.id,
    required this.name,
    required this.score,
  });

  final String id;
  final String name;
  final int score;

  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      score: (json['score'] as num).toInt(),
    );
  }
}

class MultiplayerState {
  const MultiplayerState({
    this.status = MultiplayerStatus.disconnected,
    this.roomCode,
    this.playerId,
    this.playerName,
    this.opponentName,
    this.round = 0,
    this.totalRounds = 0,
    this.scrambled = '',
    this.players = const [],
    this.standings = const [],
    this.errorMessage,
    this.opponentLeft = false,
  });

  final MultiplayerStatus status;
  final String? roomCode;
  final String? playerId;
  final String? playerName;
  final String? opponentName;
  final int round;
  final int totalRounds;
  final String scrambled;
  final List<MatchPlayer> players;
  final List<MatchPlayer> standings;
  final String? errorMessage;
  final bool opponentLeft;

  int get myScore {
    for (final p in players) {
      if (p.id == playerId) {
        return p.score;
      }
    }
    return 0;
  }

  int get opponentScore {
    for (final p in players) {
      if (p.id != playerId) {
        return p.score;
      }
    }
    return 0;
  }

  MultiplayerState copyWith({
    MultiplayerStatus? status,
    String? roomCode,
    String? playerId,
    String? playerName,
    String? opponentName,
    int? round,
    int? totalRounds,
    String? scrambled,
    List<MatchPlayer>? players,
    List<MatchPlayer>? standings,
    String? errorMessage,
    bool? opponentLeft,
  }) {
    return MultiplayerState(
      status: status ?? this.status,
      roomCode: roomCode ?? this.roomCode,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      opponentName: opponentName ?? this.opponentName,
      round: round ?? this.round,
      totalRounds: totalRounds ?? this.totalRounds,
      scrambled: scrambled ?? this.scrambled,
      players: players ?? this.players,
      standings: standings ?? this.standings,
      errorMessage: errorMessage,
      opponentLeft: opponentLeft ?? this.opponentLeft,
    );
  }
}

/// Parses a round payload (match_started / new_word) into player list + fields.
List<MatchPlayer> parsePlayers(dynamic json) {
  final list = json as List<dynamic>? ?? [];
  return list
      .map((e) => MatchPlayer.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}
