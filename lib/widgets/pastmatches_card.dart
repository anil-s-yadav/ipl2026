import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastmatchesCard extends StatelessWidget {
  // final String teamA;
  // final String teamB;
  // final String wonTeam;
  // final String totalBetsAmt;
  // final String wonBetsAnt;
  // final DateTime date;
  final Map<String, dynamic> pastMatche;

  const PastmatchesCard({
    super.key,
    required this.pastMatche,
    //   required this.teamA,
    //   required this.teamB,
    //   required this.wonTeam,
    //   required this.totalBetsAmt,
    //   required this.wonBetsAnt,
    //   required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // final today = date.isAfter(DateTime.now());
    // final now = DateTime.now();

    // final isToday =
    //     date.year == now.year && date.month == now.month && date.day == now.day;

    // final isUpcoming = date.isAfter(now);

    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${pastMatche['teamA']} vs ${pastMatche['teamB']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              DateFormat('dd MMM yyyy').format(pastMatche['matchDate']),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            "Total Bet Amt: ${pastMatche['teamABetAmount']} ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Won team ${pastMatche['winnerTeam']} ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Price per head: ${(pastMatche['totalPoolAmount']) / (pastMatche['tetotalBetsCount'])} ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
