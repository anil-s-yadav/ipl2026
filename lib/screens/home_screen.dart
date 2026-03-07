import 'package:flutter/material.dart';
import '../widgets/match_card.dart';
import '../widgets/vote_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IPL Betting"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// UPCOMING MATCHES
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Upcoming Matches",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    MatchCard(
                      teamA: "MI",
                      teamB: "CSK",
                      date: DateTime(2026, 3, 8),
                    ),
                    MatchCard(
                      teamA: "RCB",
                      teamB: "KKR",
                      date: DateTime(2026, 3, 9),
                    ),
                    MatchCard(
                      teamA: "GT",
                      teamB: "RR",
                      date: DateTime(2026, 3, 10),
                    ),
                    MatchCard(
                      teamA: "GT2",
                      teamB: "RR2",
                      date: DateTime(2026, 3, 4),
                    ),
                    MatchCard(
                      teamA: "GT3",
                      teamB: "RR3",
                      date: DateTime(2026, 3, 6),
                    ),
                  ],
                ),
              ),

              /// TODAY MATCH
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Today's Match",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              Card(
                margin: const EdgeInsets.all(16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "You betted on MI",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "MI vs CSK",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const VoteButtons(),

                      const SizedBox(height: 20),

                      /// Vote stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Column(
                            children: [
                              Text("Money"),
                              SizedBox(height: 6),
                              Text("₹180"),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Money"),
                              SizedBox(height: 6),
                              Text("₹250"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Column(
                            children: [
                              Text("Votes"),
                              SizedBox(height: 6),
                              Text("25"),
                            ],
                          ),

                          Column(
                            children: [
                              Text("Votes"),
                              SizedBox(height: 6),
                              Text("18"),
                            ],
                          ),
                        ],
                      ),

                      Text(
                        "Total: \$1000",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Voters",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // color: Colors.green,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Column(
                            children: [
                              Text("Anil Yadav"),
                              SizedBox(height: 6),
                              Text("Anup Sharma"),
                            ],
                          ),

                          Column(
                            children: [
                              Text("Rohit"),
                              SizedBox(height: 6),
                              Text("Nilesh"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Todays Bet Logs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.purple.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                      Text(
                        "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10",
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "All time Bet Logs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) => ExpansionTile(
                    title: Text("Log_06_03_2026"),
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.shade50,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                              Text(
                                "Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10, win:rs.20",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
