import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Metoda de Înregistrare (E-mail & Parolă)
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    List<String> departments = const [],
  }) async {
    List<String> finalDepartments = List.from(departments);
    if (!finalDepartments.contains('Ag')) {
      finalDepartments.add('Ag');
    }

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email.trim(),
        'role': 'volunteer',
        'departments': finalDepartments,
        'joinedDate': FieldValue.serverTimestamp(),
        'meetingsAttended': [],
        'volunteerScore': 0,
        'profilePictureUrl': 'https://uxwing.com/no-profile-picture-icon/',
        'isValidated': false,
      });
    } on FirebaseAuthException catch (e) {
      debugPrint("Eroare Firebase Auth: ${e.code}");
      rethrow;
    } catch (e) {
      debugPrint("Eroare neașteptată: $e");
      rethrow;
    }
  }

  // Metoda de Logare (E-mail & Parolă)
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint("Logare reușită pentru: $email");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        throw 'Email or password is incorrect. Please check the data.';
      } else if (e.code == 'user-disabled') {
        throw 'This account has been disabled.';
      } else {
        throw 'An error occurred during authentication: ${e.message}';
      }
    } catch (e) {
      debugPrint("Eroare neașteptată la login: $e");
      rethrow;
    }
  }

  // Metoda de Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
