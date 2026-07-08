import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/my_user.dart';
import '../services/db_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registers a new user with Email and Password, initializes a MyUser object,
  /// and saves their data in the Firestore 'users' collection.
  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;

      // Initialize the MyUser object using the factory method with placeholders if data is incorrect.
      MyUser newUser = MyUser.withPlaceholders(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        profilePicUrl: '', // Will default to placeholder in the model
        plants: [], // Empty list initially
      );

      // Save the user details to Firestore
      await _dbService.saveUser(newUser);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code}");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error during registration: $e");
      rethrow;
    }
  }

  /// Login method (Email & Password)
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint("Login successful for: $email");
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
      debugPrint("Unexpected error during login: $e");
      rethrow;
    }
  }

  /// Logout method
  Future<void> logout() async {
    await _auth.signOut();
  }
}
