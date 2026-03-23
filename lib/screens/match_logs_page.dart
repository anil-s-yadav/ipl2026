import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ipl2026/services/auth_service.dart';

class MatchLogsPage extends StatefulWidget {
  final Map<String, dynamic> match;
  const MatchLogsPage({super.key, required this.match});

  @override
  State<MatchLogsPage> createState() => _MatchLogsPageState();
}

class _MatchLogsPageState extends State<MatchLogsPage> {
  final AuthService auth = AuthService();
  List<Map<String, dynamic>> currentMatchLogs = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var crntMatchlogs = await auth.getLogsByMatchId(widget.match['match_id']);
    setState(() {
      currentMatchLogs = crntMatchlogs;
    });
    log(currentMatchLogs.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Logs for ${widget.match['tamA']} vs ${widget.match['teamB']}",
        ),
      ),
      body: Center(
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
              // Text(
              //   "${todayMatches[0]ferwrQ['teamA'] ?? ""} vs ${todayMatches[0]['teamB'] ?? ""}",
              // ),
              Text("Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10"),

              // Text(
              //   "${todayMatches[1]['teamA'] ?? ""} vs ${todayMatches[1]['teamB'] ?? ""}",
              // ),
              Text("Anil Yadav Voted Mi at 06-03-2026 at 05:53 AM Rs. 10"),
            ],
          ),
        ),
      ),
    );
  }
}
