import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipl2026/services/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// SIGN UP
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    String phone = "",
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      /// Create Firestore user profile
      await _db.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "totalWins": 0.0,
        "totalLosses": 0.0,
        "totalProfit": 0.0,
        "totalBets": 0.0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    LocalStoragePref.instance!.logOutStorage();
  }

  /// CURRENT USER
  // User? getCurrentUser() {
  //   return _auth.currentUser;
  // }

  //User profile
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // 1. Get current logged-in user ID
      String uid = _auth.currentUser!.uid;

      // 2. Fetch the document from 'users' collection
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        log("User document does not exist");
        return null;
      }
    } catch (e) {
      log("Error fetching user: $e");
      return null;
    }
  }

  // Get all users data

  Future<List<Map<String, dynamic>>> getAllUsersExceptMe() async {
    try {
      String myUid = _auth.currentUser!.uid;

      // Query 'users' collection where the document ID is not mine
      // FieldPath.documentId refers to the actual ID of the document (mkYunXp...)
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: myUid)
          .get();

      // Map the documents into a list of Map objects
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMyBetsHis() async {
    try {
      String uid = _auth.currentUser!.uid;

      // Access subcollection: users/{uid}/mybets
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('mybets')
          .orderBy("match_date", descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          "match_id": doc.id, // optional: include matchId
          "betted_team": data["betted_team"] ?? "",
          "matches": data["matches"] ?? "",
          "result": data["result"] ?? "",
          "profit": (data["profit"] ?? 0).toDouble(),
          "match_date": data["match_date"] ?? "",
        };
      }).toList();
    } catch (e) {
      print("Error fetching my bets: $e");
      return [];
    }
  }

  Future<void> insertMatch(DateTime date, String teamA, String teamB) async {
    try {
      Map<String, dynamic> matchData = {
        "matchDate": Timestamp.fromDate(date),
        "teamA": teamA,
        "teamABetAmount": 0.0,
        "teamABetCount": 0.0,
        "teamAbetUsers": [],
        "teamB": teamB,
        "teamBBetAmount": 0.0,
        "teamBBetCount": 0.0,
        "teamBbetUsers": [],
        "totalBetsCount": 0.0,
        "totalPoolAmount": 0.0,
        "winnerTeam": "",
      };

      // ✅ Auto-generate matchId
      await _db.collection('matches').add(matchData);
    } catch (e) {
      print("Error inserting match: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllMatches() async {
    try {
      QuerySnapshot snapshot = await _db.collection('matches').get();

      print("Docs count: ${snapshot.docs.length}"); // debug

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          "match_id": doc.id,
          "matchDate": (data["matchDate"] as Timestamp).toDate(),
          "teamA": data["teamA"],
          "teamABetAmount": data["teamABetAmount"],
          "teamABetCount": data["teamABetCount"],
          "teamAbetUsers": data["teamAbetUsers"],
          "teamB": data["teamB"],
          "teamBBetAmount": data["teamBBetAmount"],
          "teamBBetCount": data["teamBBetCount"],
          "teamBbetUsers": data["teamBbetUsers"],
          // Correct field name is `totalBetsCount` (typo existed as `tetotalBetsCount`).
          "totalBetsCount":
              data["totalBetsCount"] ?? data["tetotalBetsCount"] ?? 0.0,
          "totalPoolAmount": data["totalPoolAmount"],
          "winnerTeam": data["winnerTeam"],
        };
      }).toList();
    } catch (e) {
      log("Error fetching matches: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogsByMatchId(String matchId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('logs')
          .doc(matchId)
          .collection('entries')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data["log_id"] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching logs: $e");
      return [];
    }
  }

  // Future<Map<String, dynamic>?> getMatchLog(String matchId) async {
  //   try {
  //     DocumentSnapshot doc = await _db.collection('logs').doc(matchId).get();

  //     if (!doc.exists) {
  //       print("No log found");
  //       return null;
  //     }

  //     final data = doc.data() as Map<String, dynamic>;

  //     return {
  //       "match_id": doc.id,
  //       "matchid": data["matchid"] ?? "",
  //       "amount": (data["amount"] ?? 0).toDouble(),
  //       "date_time": data["date_time"] ?? "",
  //       "name": data["name"] ?? "",
  //       "status": data["status"] ?? "",
  //       "Betd_team": data["Betd_team"] ?? "",
  //     };
  //   } catch (e) {
  //     print("Error fetching log: $e");
  //     return null;
  //   }
  // }
}
