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
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isUpcoming = date.isAfter(now) || isToday;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 16, bottom: 12, top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUpcoming ? const Color(0xFF1E2238) : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isUpcoming ? [BoxShadow(color: const Color(0xFF6200EA).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))] : [],
        border: Border.all(color: isUpcoming ? const Color(0xFF6200EA).withOpacity(0.5) : Colors.white10, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$teamA vs $teamB",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isUpcoming ? Colors.white : Colors.white54, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isUpcoming ? const LinearGradient(colors: [Color(0xFF6200EA), Color(0xFF00E5FF)]) : const LinearGradient(colors: [Colors.grey, Colors.black]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isUpcoming ? [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
            ),
            child: Text(
              isUpcoming ? DateFormat('dd MMM').format(date) : "Closed",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}
