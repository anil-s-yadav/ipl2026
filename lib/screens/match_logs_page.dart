import 'package:flutter/material.dart';
import 'package:ipl2026/services/auth_service.dart';
import 'package:intl/intl.dart';

class MatchLogsPage extends StatefulWidget {
  final Map<String, dynamic> match;
  const MatchLogsPage({super.key, required this.match});

  @override
  State<MatchLogsPage> createState() => _MatchLogsPageState();
}

class _MatchLogsPageState extends State<MatchLogsPage> {
  final AuthService auth = AuthService();
  List<Map<String, dynamic>> currentMatchLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      var crntMatchlogs = await auth.getLogsByMatchId(widget.match['match_id']);
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

  String _formatDate(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: Text(
          "${widget.match['tamA'] ?? 'Team A'} vs ${widget.match['teamB'] ?? 'Team B'}",
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
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
        : Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF14192A), Color(0xFF0B0F19)],
                center: Alignment.topCenter,
                radius: 1.5,
              ),
            ),
            child: currentMatchLogs.isEmpty
              ? const Center(child: Text("No bet logs found for this match.", style: TextStyle(color: Colors.white70, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentMatchLogs.length,
                  itemBuilder: (context, index) {
                    var log = currentMatchLogs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F38),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
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
                                log['name'] ?? 'Unknown User',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3D00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "₹${log['amount'] ?? 0}",
                                  style: const TextStyle(color: Color(0xFFFF3D00), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text("Voted for: ", style: TextStyle(color: Colors.white54)),
                              Text(
                                "${log['voted_team'] ?? 'None'}",
                                style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(log['date_time'] ?? ""),
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
    );
  }
}
