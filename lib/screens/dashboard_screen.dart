import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> otherUsers = [];
  List<Map<String, dynamic>> myBetsHistory = [];
  int showResult = 0;
  @override
  void initState() {
    super.initState();
    userData();
  }

  void userData() async {
    final myData = await auth.getUserData();
    final othersData = await auth.getAllUsersExceptMe();
    final mybetshist = await auth.getMyBetsHis();
    setState(() {
      user = myData;
      otherUsers = othersData;
      myBetsHistory = mybetshist;
    });
  }

  bool isAdmin() {
    return (user?['email'] == 'anilyadav44x@gmail.com');
    // return (user?['email'] == 'anup_sharman70@yahu.co.in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 235, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 224, 255),
        elevation: 0,
        title: const Text("Dashboard"),
        centerTitle: true,
      ),

      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    if (isAdmin())
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff22C55E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: () {},

                            child: const Text(
                              "Settlement",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMatchPage(),
                                ),
                              );
                            },
                            child: Text("Add matches"),
                          ),
                        ],
                      ),

                    /// PROFILE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 146, 37, 235),
                            Color.fromARGB(255, 137, 27, 226),
                            Color(0xff1D4ED8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?['email']?[0].toUpperCase() ?? "U",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),

                          // const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['name'] ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              Text(
                                user?['email'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          // const SizedBox(width: 15),
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
                            icon: Icon(Icons.logout_rounded, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STATS ROW
                    Row(
                      children: [
                        Expanded(
                          child: statBox(
                            "Profit",
                            "₹${user?['totalProfit']}",
                            Colors.green,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: statBox(
                            "Bets",
                            "${user?['totalBets']}",
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: statBox(
                            "Wins",
                            "${user?['totalWins']}",
                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: statBox(
                            "Loss",
                            "${user?['totalLosses']}",
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// BET HISTORY
                    SizedBox(
                      height: 500,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(118, 169, 145, 255),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "My Bet History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownMenu(
                                  initialSelection: 0,
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                      value: 0,
                                      label: "My Wins",
                                    ),
                                    DropdownMenuEntry(
                                      value: 1,
                                      label: "My Losses",
                                    ),
                                  ],
                                  onSelected: (value) {
                                    setState(() {
                                      showResult = value ?? 0;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // ✅ STEP 2 → ADD HERE
                            Builder(
                              builder: (context) {
                                if (myBetsHistory.isNotEmpty) {
                                  List<Map<String, dynamic>> filteredBets =
                                      myBetsHistory.where((bet) {
                                        if (showResult == 0) {
                                          return bet['result']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "win";
                                        } else {
                                          return bet['result']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "loss";
                                        }
                                      }).toList();

                                  return Expanded(
                                    child: ListView.builder(
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
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      height: 500,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 231, 225, 255),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Other Players",
                              style: TextStyle(
                                // color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Expanded(
                              child: ListView.builder(
                                physics: ScrollPhysics(),
                                itemCount: otherUsers.length,
                                itemBuilder: (context, index) {
                                  final player = otherUsers[index];
                                  log(player.toString());
                                  return ListTile(
                                    title: Text("${player['name']}"),
                                    subtitle: FittedBox(
                                      child: Row(
                                        spacing: 2,
                                        children: [
                                          Text(
                                            "total Bets: ${player['totalBets']}",
                                          ),

                                          Text(
                                            "total Losses: ${player['totalLosses']}",
                                          ),

                                          Text(
                                            "total Wins: ${player['totalWins']}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Text(
                                      "total Profit: ₹${player["totalProfit"]}",
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // const SizedBox(height: 20),

                    /// SETTLEMENT BUTTON
                  ],
                ),
              ),
            ),
    );
  }

  /// STATS BOX
  Widget statBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color.fromARGB(41, 165, 62, 255),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 216, 233, 255),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(color: Colors.black)),
              Text(match, style: const TextStyle(color: Colors.black)),
            ],
          ),

          Text(
            bet,
            style: const TextStyle(
              // color: Colors.bl,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            result,
            style: TextStyle(
              color: result == "Win" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              color: result == "Win" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
