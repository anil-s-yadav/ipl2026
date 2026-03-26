import 'package:flutter/material.dart';
import 'package:ipl2026/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:ipl2026/models/log_model.dart';
import 'package:ipl2026/models/match_model.dart';

class MatchLogsPage extends StatefulWidget {
  final MatchModel match;
  const MatchLogsPage({super.key, required this.match});

  @override
  State<MatchLogsPage> createState() => _MatchLogsPageState();
}

class _MatchLogsPageState extends State<MatchLogsPage> {
  final AuthService auth = AuthService();
  List<LogModel> currentMatchLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      final raw = await auth.getLogsByMatchId(widget.match.matchId);
      final crntMatchlogs = raw.map((e) => LogModel.fromMap(e)).toList();
      if (mounted) {
        setState(() {
          currentMatchLogs = crntMatchlogs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading logs: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatLogDate(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateString;
    }
  }

  String _formatMatchDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: Text(
          "${match.teamA} vs ${match.teamB}",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6200EA), Color(0xFF00E5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF00E5FF)),
            )
          : Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF14192A), Color(0xFF0B0F19)],
                  center: Alignment.topCenter,
                  radius: 1.5,
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _detailsCard(match),
                  const SizedBox(height: 16),
                  const Text(
                    "Bet Logs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (currentMatchLogs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "No bet logs found for this match.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...currentMatchLogs.map(_logTile),
                ],
              ),
            ),
    );
  }

  Widget _detailsCard(MatchModel match) {
    final bool matchOver = match.winnerTeam.isNotEmpty;

    Widget statChip(String label, String value,
        {Color valueColor = Colors.white}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    Widget usersColumn(String title, List<String> users, Color accent) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              if (users.isEmpty)
                const Text(
                  "No users",
                  style: TextStyle(color: Colors.white54),
                )
              else
                ...users.map(
                  (u) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      u,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.06),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${match.teamA} VS ${match.teamB}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatMatchDate(match.matchDate),
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          if (matchOver)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withOpacity(0.25)),
              ),
              child: Text(
                "Winner: ${match.winnerTeam}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          if (matchOver) const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              statChip("Total Pool", "₹${match.totalPoolAmount}",
                  valueColor: Colors.greenAccent),
              statChip("Total Bets", "${match.totalBetsCount}"),
              statChip("Team A Pool", "₹${match.teamABetAmount}",
                  valueColor: const Color(0xFF00E5FF)),
              statChip("Team A Votes", "${match.teamABetCount}"),
              statChip("Team B Pool", "₹${match.teamBBetAmount}",
                  valueColor: const Color(0xFFFF3D00)),
              statChip("Team B Votes", "${match.teamBBetCount}"),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              usersColumn(
                "${match.teamA} Users",
                match.teamAbetUsers,
                const Color(0xFF00E5FF),
              ),
              const SizedBox(width: 10),
              usersColumn(
                "${match.teamB} Users",
                match.teamBbetUsers,
                const Color(0xFFFF3D00),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logTile(LogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log.name.isEmpty ? 'Unknown User' : log.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3D00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "₹${log.amount}",
                  style: const TextStyle(
                    color: Color(0xFFFF3D00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                "Voted for: ",
                style: TextStyle(color: Colors.white54),
              ),
              Text(
                log.votedTeam.isEmpty ? "None" : log.votedTeam,
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatLogDate(log.dateTime),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
