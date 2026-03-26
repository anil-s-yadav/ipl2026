class LogModel {
  final String logId;
  final String name;
  final String BetdTeam;
  final double amount;
  final String dateTime;

  LogModel({
    required this.logId,
    required this.name,
    required this.BetdTeam,
    required this.amount,
    required this.dateTime,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      logId: map['log_id'] ?? '',
      name: map['name'] ?? '',
      BetdTeam: map['Betd_team'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      dateTime: map['date_time'] ?? '',
    );
  }
}
