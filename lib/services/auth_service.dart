import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        "totalWins": 0,
        "totalLosses": 0,
        "totalProfit": 0,
        "totalBets": 0,
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
  }

  /// CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

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
}
