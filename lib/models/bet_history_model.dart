class BetHistoryModel {
  final String matchId;
  final String bettedTeam;
  final String matches;
  final String result;
  final double profit;
  final String matchDate;

  BetHistoryModel({
    required this.matchId,
    required this.bettedTeam,
    required this.matches,
    required this.result,
    required this.profit,
    required this.matchDate,
  });

  factory BetHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return BetHistoryModel(
      matchId: id,
      bettedTeam: map['betted_team'] ?? '',
      matches: map['matches'] ?? '',
      result: map['result'] ?? '',
      profit: (map['profit'] ?? 0).toDouble(),
      matchDate: map['match_date'] ?? '',
    );
  }
}
