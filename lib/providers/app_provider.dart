import 'package:flutter/material.dart';
import 'package:ipl2026/models/match_model.dart';
import 'package:ipl2026/models/log_model.dart';
import 'package:ipl2026/services/auth_service.dart';

class AppProvider with ChangeNotifier {
  final AuthService _auth = AuthService();

  Map<String, dynamic>? currentUserData;
  List<Map<String, dynamic>> allPlayers = [];
  List<Map<String, dynamic>> myBetsHistory = [];

  List<MatchModel> allMatches = [];
  List<MatchModel> todayMatches = [];
  List<MatchModel> upcomingMatches = [];
  List<MatchModel> pastMatches = [];

  List<LogModel> match1Logs = [];
  List<LogModel> match2Logs = [];

  bool isLoadingHome = false;
  bool isLoadingDashboard = false;

  Future<void> initHomeData() async {
    isLoadingHome = true;
    notifyListeners();

    try {
      currentUserData = await _auth.getUserData();
      var rawData = await _auth.getAllMatches();
      allMatches = rawData
          .map((e) => MatchModel.fromMap(e, e['match_id']))
          .toList();

      DateTime now = DateTime.now();
      bool isSameDay(DateTime a, DateTime b) {
        return a.year == b.year && a.month == b.month && a.day == b.day;
      }

      List<MatchModel> today = [];
      List<MatchModel> upcoming = [];
      List<MatchModel> past = [];

      for (var match in allMatches) {
        DateTime date = match.matchDate;
        if (isSameDay(date, now)) {
          today.add(match);
        } else if (date.isAfter(now)) {
          upcoming.add(match);
        } else {
          past.add(match);
        }
      }

      today.sort((a, b) {
        int dateCompare = a.matchDate.compareTo(b.matchDate);
        if (dateCompare == 0) {
          // If same day, put afternoon before evening
          return a.matchTime.compareTo(b.matchTime);
        }
        return dateCompare;
      });
      upcoming.sort((a, b) => a.matchDate.compareTo(b.matchDate));
      past.sort((a, b) => b.matchDate.compareTo(a.matchDate));

      todayMatches = today;
      upcomingMatches = upcoming;
      pastMatches = past;

      allMatches = [...today, ...upcoming, ...past];

      var rawLog1 = today.isNotEmpty
          ? await _auth.getLogsByMatchId(today[0].matchId)
          : <Map<String, dynamic>>[];
      var rawLog2 = today.length > 1
          ? await _auth.getLogsByMatchId(today[1].matchId)
          : <Map<String, dynamic>>[];

      match1Logs = rawLog1.map((e) => LogModel.fromMap(e)).toList();
      match2Logs = rawLog2.map((e) => LogModel.fromMap(e)).toList();

      // Newest first (who Betd last on top). Since `date_time` is ISO-8601,
      // string compare matches chronological order.
      match1Logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      match2Logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      debugPrint("Error loading home data: $e");
    }

    isLoadingHome = false;
    notifyListeners();
  }

  Future<void> initDashboardData() async {
    isLoadingDashboard = true;
    notifyListeners();

    try {
      currentUserData ??= await _auth.getUserData();
      allPlayers = await _auth.getAllUsers();
      
      // Sort players by profit (descending)
      allPlayers.sort((a, b) {
        double profitA = (a['totalProfit'] ?? 0).toDouble();
        double profitB = (b['totalProfit'] ?? 0).toDouble();
        return profitB.compareTo(profitA);
      });

      myBetsHistory = await _auth.getMyBetsHis();
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    }

    isLoadingDashboard = false;
    notifyListeners();
  }
}
