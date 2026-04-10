import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ipl2026/providers/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ipl2026/screens/match_logs_page.dart';
import 'package:ipl2026/widgets/pastmatches_card.dart';
import 'package:ipl2026/models/log_model.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Prevent double-bets while the async Firestore writes are still running.
  bool _isBetting = false;
  String? _activeBettingMatchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initHomeData();
    });
  }

  Future<void> _placeBet(
    String matchId,
    String team,
    bool isTeamA,
    String matches,
    String matchTime,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime now = DateTime.now();
        double betAmount = 10.0;
        bool isLate = false;

        if (matchTime == "afternoon") {
          // 3:30 PM = 15:30
          if (now.hour > 15 || (now.hour == 15 && now.minute >= 30)) {
            betAmount = 30.0;
            isLate = true;
          }
        } else {
          // evening: 7:30 PM = 19:30
          if (now.hour > 19 || (now.hour == 19 && now.minute >= 30)) {
            betAmount = 30.0;
            isLate = true;
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2238),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00E5FF),
                blurRadius: 10,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bet on $team",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isLate) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: const Text(
                    "⚠️ Late Bet Charge: ₹20 extra applies after cutoff",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF6200EA)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    // Prevent double-submits from fast taps while bet is running.
                    if (_isBetting) return;

                    setState(() {
                      _isBetting = true;
                      _activeBettingMatchId = matchId;
                    });

                    Navigator.pop(context);
                    try {
                      await _processBet(
                        matchId,
                        team,
                        isTeamA,
                        betAmount,
                        matches,
                      );
                    } finally {
                      if (!mounted) return;
                      setState(() {
                        _isBetting = false;
                        _activeBettingMatchId = null;
                      });
                    }
                  },
                  child: Text(
                    "CONFIRM BET OF ₹$betAmount",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processBet(
    String matchId,
    String team,
    bool isTeamA,
    double amount,
    String matches,
  ) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String? userName =
        context.read<AppProvider>().currentUserData?['name'] ?? "User";
    if (uid == null) return;

    try {
      DocumentReference matchRef = _db.collection('matches').doc(matchId);
      bool betRecorded = false;

      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(matchRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<dynamic> teamAUsers = List.from(data['teamAbetUsers'] ?? []);
        List<dynamic> teamBUsers = List.from(data['teamBbetUsers'] ?? []);

        if (teamAUsers.contains(userName) || teamBUsers.contains(userName)) {
          return;
        }

        if (isTeamA) {
          teamAUsers.add(userName);
          transaction.update(matchRef, {
            'teamAbetUsers': teamAUsers,
            'teamABetAmount': (data['teamABetAmount'] ?? 0.0) + amount,
            'teamABetCount': (data['teamABetCount'] ?? 0.0) + 1,
            'totalBetsCount': (data['totalBetsCount'] ?? 0.0) + 1,
            'totalPoolAmount': (data['totalPoolAmount'] ?? 0.0) + amount,
          });
        } else {
          teamBUsers.add(userName);
          transaction.update(matchRef, {
            'teamBbetUsers': teamBUsers,
            'teamBBetAmount': (data['teamBBetAmount'] ?? 0.0) + amount,
            'teamBBetCount': (data['teamBBetCount'] ?? 0.0) + 1,
            'totalBetsCount': (data['totalBetsCount'] ?? 0.0) + 1,
            'totalPoolAmount': (data['totalPoolAmount'] ?? 0.0) + amount,
          });
        }

        betRecorded = true;
      });

      if (!betRecorded) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You already placed a bet on this match."),
            backgroundColor: Colors.orange,
          ),
        );
        // Still refresh to reflect server state if needed.
        await context.read<AppProvider>().initHomeData();
        return;
      }

      await _db.collection('logs').doc(matchId).collection('entries').add({
        'name': userName,
        'Betd_team': team,
        'amount': amount,
        'date_time': DateTime.now().toIso8601String(),
      });

      // Use set(merge:true) so the UI refresh doesn't break if the doc doesn't exist yet.
      await _db
          .collection('users')
          .doc(uid)
          .collection('mybets')
          .doc(matchId)
          .set({
            "betted_team": team,
            "matches": matches,
            "result": "Pending",
            "profit": 0,
            "match_date": DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));

      // NOTE: Match bet already increments match totals; this is user-level stats.
      await _db.collection('users').doc(uid).update({
        "totalBets": FieldValue.increment(1),
      });

      if (mounted) {
        await context.read<AppProvider>().initHomeData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bet placed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _navigateToNext(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    String? currentUserName = provider.currentUserData?['name'];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: const Text(
          "IPL BETTING",
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
              colors: [
                Color.fromARGB(255, 64, 0, 152),
                Color.fromARGB(255, 0, 107, 153),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.initHomeData(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: provider.isLoadingHome
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
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2238),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Text(
                            "Note: Take actions carefully: actions are not reversible.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      _buildSectionTitle("Upcoming Matches 🏏"),
                      SizedBox(
                        height: 160,
                        child: provider.allMatches.isEmpty
                            ? const Center(
                                child: Text(
                                  "No upcoming matches",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: provider.allMatches.length,
                                itemBuilder: (context, index) {
                                  return MatchCard(
                                    teamA: provider.allMatches[index].teamA,
                                    teamB: provider.allMatches[index].teamB,
                                    date: provider.allMatches[index].matchDate,
                                  );
                                },
                              ),
                      ),

                      _buildSectionTitle("Today's Action 🔥"),
                      if (provider.todayMatches.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "No matches today",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ListView.builder(
                        shrinkWrap: true, // Fix nested list view issue
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.todayMatches.length,
                        itemBuilder: (context, index) {
                          final tData = provider.todayMatches[index];
                          List<String> teamAUsers = tData.teamAbetUsers;
                          List<String> teamBUsers = tData.teamBbetUsers;

                          String BetdTeam = "";
                          if (currentUserName != null) {
                            if (teamAUsers.contains(currentUserName)) {
                              BetdTeam = tData.teamA;
                            }
                            if (teamBUsers.contains(currentUserName)) {
                              BetdTeam = tData.teamB;
                            }
                          }

                          bool matchOver = tData.winnerTeam.isNotEmpty;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2238),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -30,
                                    right: -30,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFFF3D00,
                                            ).withOpacity(0.3),
                                            blurRadius: 40,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -30,
                                    left: -30,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00E5FF,
                                            ).withOpacity(0.3),
                                            blurRadius: 40,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        if (matchOver)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade400,
                                                  Colors.green.shade600,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "Winner: ${tData.winnerTeam} - ₹${tData.totalPoolAmount} 🎉",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        else if (BetdTeam.isNotEmpty) // Betd!
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF00E5FF,
                                              ).withOpacity(0.1),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF00E5FF,
                                                ).withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFF00E5FF),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "You Betd for $BetdTeam",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF00E5FF),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "${tData.matchTime.toUpperCase()} MATCH",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${tData.teamA} VS ${tData.teamB}",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        if (!matchOver &&
                                            BetdTeam.isEmpty) // Not Betd yet!
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: _buildBetButton(
                                                  tData.teamA,
                                                  const [
                                                    Color(0xFF2196F3),
                                                    Color(0xFF00B4DB),
                                                  ],
                                                  _isBetting
                                                      ? null
                                                      : () {
                                                          _placeBet(
                                                            tData.matchId,
                                                            tData.teamA,
                                                            true,
                                                            "${tData.teamA} VS ${tData.teamB}",
                                                            tData.matchTime,
                                                          );
                                                        },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildBetButton(
                                                  tData.teamB,
                                                  const [
                                                    Color(0xFFFF512F),
                                                    Color(0xFFF09819),
                                                  ],
                                                  _isBetting
                                                      ? null
                                                      : () {
                                                          _placeBet(
                                                            tData.matchId,
                                                            tData.teamB,
                                                            false,
                                                            "${tData.teamA} VS ${tData.teamB}",
                                                            tData.matchTime,
                                                          );
                                                        },
                                                ),
                                              ),
                                            ],
                                          ),

                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildStatsRow(
                                                "Total Pool",
                                                "₹${tData.teamABetAmount}",
                                                "₹${tData.teamBBetAmount}",
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                child: Divider(
                                                  color: Colors.white12,
                                                ),
                                              ),
                                              _buildStatsRow(
                                                "Bets",
                                                "${tData.teamABetCount.toInt()}",
                                                "${tData.teamBBetCount.toInt()}",
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Total Pool: ₹${tData.totalPoolAmount}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.greenAccent,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        const Text(
                                          "RECENT BetRS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white38,
                                            letterSpacing: 1.5,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Fix nested list views again by using standard elements
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: teamAUsers
                                                    .map<Widget>(
                                                      (u) => Text(
                                                        u,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: teamBUsers
                                                    .map<Widget>(
                                                      (u) => Text(
                                                        u,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Show loading overlay while the bet is being placed.
                                  if (_isBetting &&
                                      _activeBettingMatchId == tData.matchId)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.35),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 32,
                                              width: 32,
                                              child:
                                                  const CircularProgressIndicator(
                                                    color: Color(0xFF00E5FF),
                                                    strokeWidth: 3,
                                                  ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "Placing bet...",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      if (provider.match1Logs.isNotEmpty) ...[
                        _buildSectionTitle("Today's Bet Logs 📊"),
                        _buildLogsContainer(provider.match1Logs, 1),
                      ],
                      if (provider.match2Logs.isNotEmpty) ...[
                        if (provider.match1Logs.isEmpty)
                          _buildSectionTitle("Today's Bet Logs 📊"),
                        _buildLogsContainer(provider.match2Logs, 2),
                      ],

                      _buildSectionTitle("Past Matches ⏪"),
                      ListView.builder(
                        shrinkWrap: true, // Fix nested list view issue
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.pastMatches.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                splashColor: const Color(
                                  0xFF00E5FF,
                                ).withOpacity(0.2),
                                highlightColor: const Color(
                                  0xFF00E5FF,
                                ).withOpacity(0.1),
                                onTap: () => _navigateToNext(
                                  MatchLogsPage(
                                    match: provider.pastMatches[index],
                                  ),
                                ),
                                child: PastmatchesCard(
                                  pastMatche: provider.pastMatches[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBetButton(
    String label,
    List<Color> colors,
    VoidCallback? onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(String label, String valA, String valB) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                valA,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, height: 30, color: Colors.white12),
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                valB,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsContainer(List<LogModel> logs, int matchNum) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2238),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF00E5FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Match $matchNum Logs",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true, // Fix nested list view issue
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text("🎯", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(DateTime.parse(log.dateTime)),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "${log.name} Bet",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6200EA).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.BetdTeam,
                        style: const TextStyle(
                          color: Color(0xFFB388FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "₹${log.amount}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
