import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipl2026/screens/addmatchpage.dart';
import 'package:ipl2026/screens/login_screen.dart';
import 'package:ipl2026/screens/match_logs_page.dart';
import 'package:ipl2026/services/auth_service.dart';
import 'package:ipl2026/widgets/pastmatches_card.dart';
import '../widgets/match_card.dart';
import '../widgets/vote_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();

  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> todayMatches = [];
  List<Map<String, dynamic>> pastMatches = [];
  List<Map<String, dynamic>> crntmatch1logs = [];
  List<Map<String, dynamic>> crntmatch2logs = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var data = await auth.getAllMatches();

    DateTime now = DateTime.now();

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    List<Map<String, dynamic>> today = [];
    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> past = [];

    for (var match in data) {
      DateTime date = match['matchDate'];

      if (isSameDay(date, now)) {
        today.add(match);
      } else if (date.isAfter(now)) {
        upcoming.add(match);
      } else {
        past.add(match);
      }
    }

    // Combine (Today → Upcoming → Past)
    List<Map<String, dynamic>> sortedAll = [...today, ...upcoming, ...past];
    log(today.toString());
    var crntMlog1 = await auth.getLogsByMatchId(today[0]['match_id']);
    var crntMlog2 = await auth.getLogsByMatchId(today[1]['match_id']);

    setState(() {
      matches = sortedAll; // 1. Combined list
      todayMatches = today; // 2. Today list
      // upcomingMatches = upcoming; // (optional)
      pastMatches = past; // 3. Past list
      crntmatch1logs = crntMlog1;
      crntmatch2logs = crntMlog2;
    });
  }

  List<Map<String, dynamic>> sortMatches(List<Map<String, dynamic>> matches) {
    DateTime now = DateTime.now();

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    matches.sort((a, b) {
      DateTime dateA = a['matchDate'];
      DateTime dateB = b['matchDate'];

      int priorityA = isSameDay(dateA, now)
          ? 0 // Today
          : dateA.isAfter(now)
          ? 1 // Upcoming
          : 2; // Past

      int priorityB = isSameDay(dateB, now)
          ? 0
          : dateB.isAfter(now)
          ? 1
          : 2;

      // First sort by priority
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // Then sort inside each group
      return dateA.compareTo(dateB);
    });

    return matches;
  }

  String totalBet(double a, double b) {
    final amt = a + b;
    return "Total:  $amt";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IPL Betting"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => getData(), icon: Icon(Icons.refresh)),
          SizedBox(width: 20),
        ],
      ),
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return MatchCard(
                      teamA: matches[index]['teamA'],
                      teamB: matches[index]['teamB'],
                      date: matches[index]['matchDate'],
                    );
                  },
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

              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: todayMatches.length,
                  itemBuilder: (context, index) {
                    final tData = todayMatches[index];
                    return Card(
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
                              "You betted on ${tData['teamA']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${tData['teamA']} vs ${tData['teamB']}",
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
                              children: [
                                Column(
                                  children: [
                                    Text("Money"),
                                    SizedBox(height: 6),
                                    Text(
                                      "₹${tData['teamABetAmount'].toString()}",
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Money"),
                                    SizedBox(height: 6),
                                    Text("₹${tData['teamBBetAmount']}"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text("Votes"),
                                    SizedBox(height: 6),
                                    Text("₹${tData['teamABetCount']}"),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Text("Votes"),
                                    SizedBox(height: 6),
                                    Text("₹${tData['teamBBetCount']}"),
                                  ],
                                ),
                              ],
                            ),

                            Text(
                              totalBet(
                                tData['teamABetAmount'],
                                tData['teamBBetAmount'],
                              ),
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
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    itemCount: tData['teamAbetUsers'].length,
                                    itemBuilder: (context, index) {
                                      return Text(tData['teamAbetUsers']);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                  child: ListView.builder(
                                    itemCount: tData['teamBbetUsers'].length,
                                    itemBuilder: (context, index) {
                                      return Text(tData['teamBbetUsers']);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Todays Bet Logs Match 1",
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
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final cmlog1 = crntmatch1logs[index];
                      // maybe this is wrong I want make it dynamic.
                      // there will be two matches per day I want to show logs for both fetch data
                      return Text(
                        "${cmlog1['name']} Voted ${cmlog1['voted_team']} at ${cmlog1['date_time']} Rs. 10",
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Todays Bet Logs Match 1",
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
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final cmlog2 = crntmatch2logs[index];
                      // maybe this is wrong I want make it dynamic.
                      // there will be two matches per day I want to show logs for both fetch data
                      return Text(
                        "${cmlog2['name']} Voted ${cmlog2['voted_team']} at ${cmlog2['date_time']} Rs. 10",
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Past Matches data",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchLogsPage(
                            match: pastMatches[index]['match_id'],
                          ),
                        ),
                      ),
                      child: PastmatchesCard(pastMatche: pastMatches[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
