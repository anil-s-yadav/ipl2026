import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final DateTime matchDate;
  final String teamA;
  final double teamABetAmount;
  final double teamABetCount;
  final List<String> teamAbetUsers;
  final String teamB;
  final double teamBBetAmount;
  final double teamBBetCount;
  final List<String> teamBbetUsers;
  final double totalBetsCount;
  final double totalPoolAmount;
  final String winnerTeam;

  MatchModel({
    required this.matchId,
    required this.matchDate,
    required this.teamA,
    required this.teamABetAmount,
    required this.teamABetCount,
    required this.teamAbetUsers,
    required this.teamB,
    required this.teamBBetAmount,
    required this.teamBBetCount,
    required this.teamBbetUsers,
    required this.totalBetsCount,
    required this.totalPoolAmount,
    required this.winnerTeam,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      matchId: id,
      matchDate: map['matchDate'] is Timestamp ? (map['matchDate'] as Timestamp).toDate() : (map['matchDate'] as DateTime? ?? DateTime.now()),
      teamA: map['teamA'] ?? '',
      teamABetAmount: (map['teamABetAmount'] ?? 0).toDouble(),
      teamABetCount: (map['teamABetCount'] ?? 0).toDouble(),
      teamAbetUsers: List<String>.from(map['teamAbetUsers'] ?? []),
      teamB: map['teamB'] ?? '',
      teamBBetAmount: (map['teamBBetAmount'] ?? 0).toDouble(),
      teamBBetCount: (map['teamBBetCount'] ?? 0).toDouble(),
      teamBbetUsers: List<String>.from(map['teamBbetUsers'] ?? []),
      totalBetsCount: (map['totalBetsCount'] ?? map['tetotalBetsCount'] ?? 0).toDouble(),
      totalPoolAmount: (map['totalPoolAmount'] ?? 0).toDouble(),
      winnerTeam: map['winnerTeam'] ?? '',
    );
  }
}
