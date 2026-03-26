import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ipl2026/providers/app_provider.dart';
import 'package:ipl2026/screens/addmatchpage.dart';
import 'package:ipl2026/screens/login_screen.dart';
import 'package:ipl2026/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int showResult = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initDashboardData();
    });
  }

  bool isAdmin(Map<String, dynamic>? user) {
    return (user?['email'] == 'anilyadav44x@gmail.com');
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
                                user['email']?[0].toUpperCase() ?? "U",
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
                                    user['name'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['email'],
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
                              "₹${user['totalProfit']}",
                              const Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: statBox(
                              "Bets",
                              "${user['totalBets']}",
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
                              "Wins",
                              "${user['totalWins']}",
                              Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: statBox(
                              "Loss",
                              "${user['totalLosses']}",
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
                                      label: "Win / Pending",
                                    ),
                                    DropdownMenuEntry(
                                      value: 1,
                                      label: "My Losses",
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
                                  List<Map<String, dynamic>> filteredBets =
                                      provider.myBetsHistory.where((bet) {
                                        String res = bet['result']
                                            .toString()
                                            .toLowerCase();
                                        if (showResult == 0) {
                                          return res == "win" ||
                                              res == "pending";
                                        } else {
                                          return res == "loss";
                                        }
                                      }).toList();

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
                                        date: "${data['match_date']}",
                                        match: "${data['matches']}",
                                        bet: "${data['betted_team']}",
                                        result: "${data['result']}",
                                        amount: "${data['profit']}",
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

                      /// OTHER PLAYERS
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
                              "Other Players",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            provider.otherUsers.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "No other players",
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
                                    itemCount: provider.otherUsers.length,
                                    itemBuilder: (context, index) {
                                      final player = provider.otherUsers[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        onTap: () =>
                                            _showOtherUserStatesDialog(player),
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color(
                                            0xFF6200EA,
                                          ).withOpacity(0.2),
                                          child: Text(
                                            (player['name'] ?? "U")[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF00E5FF),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          "${player['name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                                              "₹${player["totalProfit"] ?? 0}",
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

  void _showOtherUserStatesDialog(Map<String, dynamic> player) {
    final String name = player['name'] ?? 'Unknown';
    final String email = player['email'] ?? '';

    final String totalProfit = '₹${player['totalProfit'] ?? 0}';
    final String totalBets = '${player['totalBets'] ?? 0}';
    final String totalWins = '${player['totalWins'] ?? 0}';
    final String totalLosses = '${player['totalLosses'] ?? 0}';

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
                "Wins: $totalWins",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Losses: $totalLosses",
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
    // Pick the latest pending match (winnerTeam == '') so admin doesn't need to choose matchId.
    final DocumentSnapshot<Map<String, dynamic>>? matchSnap =
        await _getLatestPendingMatch();

    if (matchSnap == null || !matchSnap.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No pending matches found for settlement."),
            backgroundColor: Colors.orange,
          ),
        );
      }

      return;
    }

    final data = matchSnap.data()!;
    final String teamA = (data['teamA'] ?? 'Team A').toString();
    final String teamB = (data['teamB'] ?? 'Team B').toString();

    // Show popup to choose the winner team.
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isBusy = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF14192A),
              title: const Text(
                "Choose Winner Team",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: isBusy
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${teamA} vs ${teamB}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Total Pool will be distributed equally among winners.",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
              actions: isBusy
                  ? []
                  : [
                      TextButton(
                        onPressed: () async {
                          setState(() => isBusy = true);
                          try {
                            await _settlement(teamA, matchSnap.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              await context
                                  .read<AppProvider>()
                                  .initDashboardData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Settlement completed successfully.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Settlement failed: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          teamA,
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() => isBusy = true);
                          try {
                            await _settlement(teamB, matchSnap.id);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              await context
                                  .read<AppProvider>()
                                  .initDashboardData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Settlement completed successfully.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Settlement failed: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          teamB,
                          style: const TextStyle(
                            color: Color(0xFFFF3D00),
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

  Future<DocumentSnapshot<Map<String, dynamic>>?>
  _getLatestPendingMatch() async {
    final QuerySnapshot<Map<String, dynamic>> pending = await _db
        .collection('matches')
        .where('winnerTeam', isEqualTo: '')
        .get();

    if (pending.docs.isEmpty) return null;

    // Pick the latest matchDate (matchDate is stored as Timestamp).
    final docs = pending.docs.toList();
    docs.sort((a, b) {
      final ad = a.data()['matchDate'];
      final bd = b.data()['matchDate'];

      final at = ad is Timestamp ? ad : null;
      final bt = bd is Timestamp ? bd : null;

      final aMillis = at?.toDate().millisecondsSinceEpoch ?? 0;
      final bMillis = bt?.toDate().millisecondsSinceEpoch ?? 0;
      return bMillis.compareTo(aMillis);
    });
    return docs.first;
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

    if (winnerCount <= 0) {
      throw Exception("Winner bet count is zero; cannot distribute pool.");
    }

    // Divide total pool equally among winning bettors.
    final double perWinnerAmt = totalPoolAmount / winnerCount;

    // Map bettor name -> user document id (uid) by querying `users` where `name` matches.
    final Map<String, String> nameToUid = await _getUserIdsByNames([
      ...winnerUsers,
      ...loserUsers,
    ]);

    final WriteBatch batch = _db.batch();

    // Update match settlement data.
    batch.update(matchRef, {"winAmt": perWinnerAmt, "winnerTeam": team});

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
        "profit": 0,
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
                    amount,
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
