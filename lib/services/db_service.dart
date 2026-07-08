import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/my_user.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves or updates a [MyUser] document in the Firestore 'users' collection.
  /// The document ID matches the [MyUser.id].
  Future<void> saveUser(MyUser user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
      debugPrint("Successfully saved user data for ID: ${user.id}");
    } on FirebaseException catch (e) {
      debugPrint("Firestore Exception while saving user: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Unexpected error while saving user: $e");
      rethrow;
    }
  }

  /// Streams a user's document from the Firestore 'users' collection mapped to a [MyUser] object.
  Stream<MyUser?> userDocStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return MyUser.fromMap(snapshot.id, snapshot.data()!);
    });
  }
}
