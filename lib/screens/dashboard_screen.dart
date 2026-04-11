import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipl2026/models/bet_history_model.dart';
import 'package:ipl2026/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:ipl2026/providers/app_provider.dart';
import 'package:ipl2026/screens/addmatchpage.dart';
import 'package:ipl2026/screens/login_screen.dart';
import 'package:ipl2026/services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int showResult = 0;

  double _round2(num value) => (value * 100).round() / 100;

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v.trim()) ?? 0;
    return 0;
  }

  String _money(dynamic value) => _round2(_toNum(value)).toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initDashboardData();
    });
  }

  bool isAdmin(UserModel? user) {
    return (user?.email == 'anilyadav44x@gmail.com');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUserData;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: const Text(
          "DASHBOARD",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
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
        actions: [
          IconButton(
            onPressed: () => provider.initDashboardData(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: provider.isLoadingDashboard || user == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF14192A), Color(0xFF0B0F19)],
                  center: Alignment.topCenter,
                  radius: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAdmin(user))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  onPressed: () => _handleSettlementPressed(),
                                  child: const Text(
                                    "Settlement",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6200EA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddMatchPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Add matches",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// PROFILE
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6200EA), Color(0xFF00E5FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6200EA).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Text(
                                user.email[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: Color(0xFF6200EA),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                auth.logout();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.power_settings_new_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// STATS ROW
                      Row(
                        children: [
                          Expanded(
                            child: statBox(
                              "Profit",
                              "₹${_money(user.totalProfit)}",
                              const Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: statBox(
                              "Bets",
                              "${user.totalBets.toInt()}",
                              const Color(0xFFFF3D00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: statBox(
                              "Won",
                              "${user.totalWins.toInt()}",
                              Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: statBox(
                              "Lost",
                              "${user.totalLosses.toInt()}",
                              Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// BET HISTORY
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14192A),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "My Bet History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                DropdownMenu<int>(
                                  initialSelection: showResult,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                      value: 0,
                                      label: "won / Pending",
                                    ),
                                    DropdownMenuEntry(
                                      value: 1,
                                      label: "Lost matches",
                                    ),
                                  ],
                                  onSelected: (value) {
                                    setState(() => showResult = value ?? 0);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Builder(
                              builder: (context) {
                                if (provider.myBetsHistory.isNotEmpty) {
                                  List<BetHistoryModel> filteredBets = provider
                                      .myBetsHistory
                                      .where((bet) {
                                        String res = bet.result.toLowerCase();
                                        if (showResult == 0) {
                                          return res == "win" ||
                                              res == "pending";
                                        } else {
                                          return res == "loss";
                                        }
                                      })
                                      .toList();

                                  if (filteredBets.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text(
                                          "No records found",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredBets.length,
                                    itemBuilder: (context, index) {
                                      final data = filteredBets[index];
                                      return BetTile(
                                        date: data.matchDate,
                                        match: data.matches,
                                        bet: data.bettedTeam,
                                        result: data.result,
                                        amount: _money(data.profit),
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "No bets formulated yet",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// PLAYERS LEADERBOARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14192A),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Players Leaderboard",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            provider.allPlayers.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "No players found",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                          color: Colors.white10,
                                          height: 20,
                                        ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: provider.allPlayers.length,
                                    itemBuilder: (context, index) {
                                      final player = provider.allPlayers[index];
                                      final bool isMe =
                                          player.email == user.email;

                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        onTap: () =>
                                            _showOtherUserStatesDialog(player),
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: isMe
                                              ? const Color(
                                                  0xFF00E5FF,
                                                ).withOpacity(0.2)
                                              : const Color(
                                                  0xFF6200EA,
                                                ).withOpacity(0.2),
                                          child: Text(
                                            player.name[0].toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isMe
                                                  ? Colors.white
                                                  : const Color(0xFF00E5FF),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          "${player.name}${isMe ? ' (Me)' : ''}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isMe
                                                ? const Color(0xFF00E5FF)
                                                : Colors.white,
                                          ),
                                        ),
                                        subtitle: const Text(
                                          "Taps to view stats",
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              "Profit",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "₹${_money(player.totalProfit)}",
                                              style: const TextStyle(
                                                color: Color(0xFF00E5FF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showOtherUserStatesDialog(UserModel player) {
    final String name = player.name;
    final String email = player.email;

    final String totalProfit = '₹${_money(player.totalProfit)}';
    final String totalBets = '${player.totalBets.toInt()}';
    final String totalWins = '${player.totalWins.toInt()}';
    final String totalLosses = '${player.totalLosses.toInt()}';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF14192A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (email.isNotEmpty)
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              if (email.isNotEmpty) const SizedBox(height: 10),
              Text(
                "Profit: $totalProfit",
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Bets: $totalBets",
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Won: $totalWins",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lost: $totalLosses",
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// STATS BOX
  Widget statBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSettlementPressed() async {
    if (!mounted) return;

    final matches = await _getSettlablePendingMatches();

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No pending settlements (past or today). Future matches are not shown.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedMatchId = matches.first.id;
    String? selectedWinnerTeam;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isBusy = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedDoc = matches.firstWhere(
              (d) => d.id == selectedMatchId,
            );
            final data = selectedDoc.data();
            final String teamA = (data['teamA'] ?? 'Team A').toString();
            final String teamB = (data['teamB'] ?? 'Team B').toString();

            return AlertDialog(
              backgroundColor: const Color(0xFF14192A),
              title: const Text(
                "Settlement - Select One Match",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Match (teamA vs teamB)",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMatchId,
                        dropdownColor: const Color(0xFF1E2238),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                          labelText: "Select Match",
                          labelStyle: TextStyle(color: Colors.white54),
                        ),
                        items: matches.map((m) {
                          final d = m.data();
                          final a = (d['teamA'] ?? 'Team A').toString();
                          final b = (d['teamB'] ?? 'Team B').toString();
                          final dateLabel = _formatMatchDateLabel(
                            d['matchDate'],
                          );
                          return DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              dateLabel.isEmpty
                                  ? "$a vs $b"
                                  : "$a vs $b · $dateLabel",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: isBusy
                            ? null
                            : (value) {
                                if (value == null) return;
                                setDialogState(() {
                                  selectedMatchId = value;
                                  selectedWinnerTeam = null;
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Select winner team",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedWinnerTeam,
                        dropdownColor: const Color(0xFF1E2238),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                          labelText: "Winner Team",
                          labelStyle: TextStyle(color: Colors.white54),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: teamA,
                            child: Text(
                              teamA,
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: teamB,
                            child: Text(
                              teamB,
                              style: const TextStyle(
                                color: Color(0xFFFF3D00),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        onChanged: isBusy
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedWinnerTeam = value;
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      if (isBusy)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () async {
                          if (selectedWinnerTeam == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Select winner team first."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isBusy = true);
                          try {
                            await _settlement(
                              selectedWinnerTeam!,
                              selectedMatchId,
                            );
                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            await context
                                .read<AppProvider>()
                                .initDashboardData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Settlement completed."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Settlement failed: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text(
                    "Settle",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Past + today only; excludes future-dated matches. Pending = no winner set.
  String _formatMatchDateLabel(dynamic matchDate) {
    if (matchDate is Timestamp) {
      final dt = matchDate.toDate();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
    return '';
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getSettlablePendingMatches() async {
    final now = DateTime.now();
    final startOfTomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    // All matches on or before today: matchDate < start of tomorrow.
    // Future matches are excluded. Pending filtered in memory.
    final QuerySnapshot<Map<String, dynamic>> snap = await _db
        .collection('matches')
        .where('matchDate', isLessThan: Timestamp.fromDate(startOfTomorrow))
        .orderBy('matchDate', descending: false)
        .get();

    return snap.docs.where((doc) {
      final data = doc.data();
      final w = data['winnerTeam'];
      return w == null || (w is String && w.trim().isEmpty);
    }).toList();
  }

  Future<void> _settlement(String team, String matchId) async {
    final matchRef = _db.collection('matches').doc(matchId);
    final matchSnap = await matchRef.get();
    if (!matchSnap.exists) return;

    final matchData = matchSnap.data() as Map<String, dynamic>;

    final double totalPoolAmount = (matchData['totalPoolAmount'] ?? 0)
        .toDouble();
    final double teamACount = (matchData['teamABetCount'] ?? 0).toDouble();
    final double teamBCount = (matchData['teamBBetCount'] ?? 0).toDouble();

    final List<String> teamAUsers = List<String>.from(
      (matchData['teamAbetUsers'] ?? const <dynamic>[]).toList(),
    );
    final List<String> teamBUsers = List<String>.from(
      (matchData['teamBbetUsers'] ?? const <dynamic>[]).toList(),
    );

    final String teamA = (matchData['teamA'] ?? 'Team A').toString();

    final bool isTeamAWinner = team == teamA;
    final double winnerCount = isTeamAWinner ? teamACount : teamBCount;
    final List<String> winnerUsers = isTeamAWinner ? teamAUsers : teamBUsers;
    final List<String> loserUsers = isTeamAWinner ? teamBUsers : teamAUsers;

    // Divide total pool equally among winning bettors.
    // If no one betted on the winner, profit is 0.
    final double perWinnerAmt = winnerCount > 0
        ? _round2(totalPoolAmount / winnerCount)
        : 0.0;

    // Map bettor name -> user document id (uid) by querying `users` where `name` matches.
    final Map<String, String> nameToUid = await _getUserIdsByNames([
      ...winnerUsers,
      ...loserUsers,
    ]);

    final WriteBatch batch = _db.batch();

    // Update match settlement data.
    batch.update(matchRef, {"winnerTeam": team});

    // Update winning bettors.
    for (final bettorName in winnerUsers) {
      final String? uid = nameToUid[bettorName];
      if (uid == null) continue;

      final userRef = _db.collection('users').doc(uid);
      final myBetsRef = userRef.collection('mybets').doc(matchId);

      batch.set(myBetsRef, {
        "profit": perWinnerAmt,
        "result": "win",
      }, SetOptions(merge: true));

      batch.set(userRef, {
        "totalWins": FieldValue.increment(1),
        "totalProfit": FieldValue.increment(perWinnerAmt),
        // totalBets is already incremented at bet time in HomeScreen.
      }, SetOptions(merge: true));
    }

    // Update losing bettors.
    for (final bettorName in loserUsers) {
      final String? uid = nameToUid[bettorName];
      if (uid == null) continue;

      final userRef = _db.collection('users').doc(uid);
      final myBetsRef = userRef.collection('mybets').doc(matchId);

      batch.set(myBetsRef, {
        "profit": _round2(-10),
        "result": "loss",
      }, SetOptions(merge: true));

      batch.set(userRef, {
        "totalLosses": FieldValue.increment(1),
        // totalProfit is not changed for losers (profit = 0).
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<Map<String, String>> _getUserIdsByNames(List<String> names) async {
    final uniqueNames = names
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList();
    final Map<String, String> out = {};

    // Firestore whereIn supports up to 10 values per query.
    const int chunkSize = 10;
    for (var i = 0; i < uniqueNames.length; i += chunkSize) {
      final chunk = uniqueNames.sublist(
        i,
        i + chunkSize > uniqueNames.length ? uniqueNames.length : i + chunkSize,
      );

      final QuerySnapshot<Map<String, dynamic>> snap = await _db
          .collection('users')
          .where('name', whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        final docData = doc.data();
        final name = docData['name'];
        if (name is String && name.trim().isNotEmpty) {
          out[name] = doc.id;
        }
      }
    }

    return out;
  }
}

/// BET HISTORY TILE
class BetTile extends StatelessWidget {
  final String date;
  final String match;
  final String bet;
  final String result;
  final String amount;
  const BetTile({
    super.key,
    required this.date,
    required this.match,
    required this.bet,
    required this.result,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    bool isWin = result.toLowerCase() == "win";
    bool isPending = result.toLowerCase() == "pending";

    Color statusColor = isWin
        ? Colors.greenAccent
        : (isPending ? Colors.orangeAccent : Colors.pinkAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Bet: $bet",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    result,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "₹$amount",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
