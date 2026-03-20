import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ipl2026/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService auth = AuthService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    userData();
  }

  void userData() async {
    final data = await auth.getUserData();
    setState(() {
      user = data;
    });
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

                          const SizedBox(width: 15),

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Bet History",
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownMenu(
                                  dropdownMenuEntries: [
                                    DropdownMenuEntry(value: 0, label: "wins"),
                                    DropdownMenuEntry(value: 0, label: "loss"),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Expanded(
                              child: ListView.builder(
                                physics: ScrollPhysics(),
                                itemCount: 10,
                                itemBuilder: (context, index) => BetTile(
                                  date: "24 Mar",
                                  match: "MI vs CSK",
                                  bet: "MI",
                                  result: "Win",
                                  amount: "+₹18",
                                ),
                              ),
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
                                itemCount: 10,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text("name"),
                                  subtitle: Row(
                                    spacing: 8,
                                    children: [
                                      Text("totalBets"),
                                      Text("totalLosses"),
                                      Text("totalWins"),
                                    ],
                                  ),
                                  trailing: Text("totalProfit"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// SETTLEMENT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
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
                    ),
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
