import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                                  onPressed: () {
                                    // _settlement();
                                  },
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

  void _settlement(String team, String matchId) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    String? userName =
        context.read<AppProvider>().currentUserData?['name'] ?? "User";
    if (uid == null) return;
    // DocumentReference matchRef = _db.collection('matches').doc(matchId);

    await _db.collection('matches').doc(matchId).update({
      "winAmt": 0,
      "winnerTeam": team,
    });

    await _db
        .collection('users')
        .doc(uid)
        .collection('mybets')
        .doc(matchId) //I added this may contains errors
        .update({"result": "win", "profit": 0});

    await _db.collection('users').doc(uid).update({
      "totalBets": FieldValue.increment(1),
    });
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
