import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  final String teamA;
  final String teamB;
  final DateTime date;

  const MatchCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // final today = date.isAfter(DateTime.now());
    final now = DateTime.now();

    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final isUpcoming = date.isAfter(now);

    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: isUpcoming || isToday ? Colors.green.shade100 : Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$teamA vs $teamB",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

            decoration: BoxDecoration(
              color: isUpcoming || isToday ? Colors.green : Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),

            child: isUpcoming || isToday
                ? Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: const TextStyle(color: Colors.white),
                  )
                : const Text("Closed", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            "${date.day}-${date.month}-${date.year}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
