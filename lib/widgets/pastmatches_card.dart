import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipl2026/models/match_model.dart';

class PastmatchesCard extends StatelessWidget {
  final MatchModel pastMatche;

  const PastmatchesCard({super.key, required this.pastMatche});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2238),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white10, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${pastMatche.teamA} VS ${pastMatche.teamB}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  DateFormat('dd MMM yy').format(pastMatche.matchDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Winner: ${pastMatche.winnerTeam.isEmpty ? 'Pending' : pastMatche.winnerTeam}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      double perUserWin = 0;
                      if (pastMatche.winnerTeam.isNotEmpty) {
                        double winCount = pastMatche.winnerTeam == pastMatche.teamA
                            ? pastMatche.teamABetCount
                            : pastMatche.teamBBetCount;
                        if (winCount > 0) {
                          perUserWin = (pastMatche.totalPoolAmount / winCount);
                        }
                      }
                      return Text(
                        "  won ₹${perUserWin.toStringAsFixed(2)} (each user)",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  "Pool: ₹${pastMatche.totalPoolAmount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
