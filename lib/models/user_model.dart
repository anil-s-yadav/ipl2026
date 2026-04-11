class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final double totalWins;
  final double totalLosses;
  final double totalProfit;
  final double totalBets;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalWins,
    required this.totalLosses,
    required this.totalProfit,
    required this.totalBets,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      totalWins: (map['totalWins'] ?? 0).toDouble(),
      totalLosses: (map['totalLosses'] ?? 0).toDouble(),
      totalProfit: (map['totalProfit'] ?? 0).toDouble(),
      totalBets: (map['totalBets'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalProfit': totalProfit,
      'totalBets': totalBets,
    };
  }
}
