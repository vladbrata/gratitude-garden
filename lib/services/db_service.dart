import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../models/message_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salvează sau actualizează datele unui utilizator în colecția `/users`.
  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.userId).set(user.toMap());
      debugPrint("Utilizator salvat cu succes: ${user.userId}");
    } on FirebaseException catch (e) {
      debugPrint("Eroare Firestore la salvarea utilizatorului: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Eroare neașteptată la salvarea utilizatorului: $e");
      rethrow;
    }
  }

  /// Stream în timp real pentru datele de profil ale utilizatorului (`/users/{uid}`).
  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromDocument(snapshot);
    });
  }

  /// Stream în timp real pentru lista de plante ale utilizatorului (`/users/{uid}/plants`).
  Stream<List<PlantModel>> plantsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PlantModel.fromDocument(doc)).toList();
    });
  }

  /// Stream în timp real pentru o singură plantă a utilizatorului (`/users/{uid}/plants/{plantId}`).
  Stream<PlantModel?> plantStream(String uid, String plantId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(plantId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return PlantModel.fromDocument(snapshot);
    });
  }

  /// Stream în timp real pentru mesajele de recunoștință ale unei plante
  /// (`/users/{uid}/plants/{plantId}/messages`), ordonate cronologic invers (cele mai noi primele).
  Stream<List<MessageModel>> messagesStream(String uid, String plantId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(plantId)
        .collection('messages')
        .orderBy('dateWritten', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromDocument(doc)).toList();
    });
  }

  /// Adaugă o nouă plantă în sub-colecția de plante a utilizatorului și returnează ID-ul ei.
  Future<String> addPlant(String uid, String plantName, String plantType) async {
    try {
      final plantRef = _db.collection('users').doc(uid).collection('plants').doc();
      final newPlant = PlantModel(
        plantId: plantRef.id,
        userId: uid,
        plantName: plantName,
        datePlanted: DateTime.now(),
        lastWatered: DateTime.now().subtract(const Duration(days: 1)),
        streak: 0, // Începe cu 0 zile de streak la plantare (urmează a fi udată)
        plantLevel: 1,
        plantType: plantType,
      );
      await plantRef.set(newPlant.toMap());
      debugPrint("Plantă nouă adăugată: ${newPlant.plantName} (${plantRef.id})");
      return plantRef.id;
    } on FirebaseException catch (e) {
      debugPrint("Eroare Firestore la adăugarea plantei: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Eroare neașteptată la adăugarea plantei: $e");
      rethrow;
    }
  }

  /// Udează o plantă, actualizând direct streak-ul, data ultimei udări și oferind 1 monedă.
  Future<void> waterPlant(String uid, String plantId, int currentStreak) async {
    final batch = _db.batch();

    final plantRef = _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(plantId);

    batch.update(plantRef, {
      'streak': currentStreak + 1,
      'lastWatered': Timestamp.fromDate(DateTime.now()),
    });

    final userRef = _db.collection('users').doc(uid);
    batch.update(userRef, {
      'coins': FieldValue.increment(1),
    });

    try {
      await batch.commit();
      debugPrint("Planta $plantId a fost udată și s-a oferit 1 monedă. Noul streak: ${currentStreak + 1}");
    } on FirebaseException catch (e) {
      debugPrint("Eroare Firestore la udarea plantei (Write Batch): ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Șterge o plantă din sub-colecția utilizatorului.
  Future<void> deletePlant(String uid, String plantId) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('plants')
          .doc(plantId)
          .delete();
      debugPrint("Planta $plantId a fost ștearsă din Firestore.");
    } on FirebaseException catch (e) {
      debugPrint("Eroare Firestore la ștergerea plantei: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Adaugă un mesaj de recunoștință în sub-colecția plantei și o "udează" automat,
  /// actualizând streak-ul plantei, data ultimei udări și monedele utilizatorului (+1 monedă).
  Future<void> addMessage(String uid, String plantId, String messageText, int currentStreak, int currentCoins) async {
    final batch = _db.batch();

    // 1. Referință și date pentru noul mesaj
    final messageRef = _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(plantId)
        .collection('messages')
        .doc();

    final newMessage = MessageModel(
      messageId: messageRef.id,
      plantId: plantId,
      userId: uid,
      dateWritten: DateTime.now(),
      messageText: messageText,
    );

    batch.set(messageRef, newMessage.toMap());

    // 2. Referință pentru actualizarea plantei (streak + 1, lastWatered)
    final plantRef = _db
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(plantId);

    batch.update(plantRef, {
      'streak': currentStreak + 1,
      'lastWatered': Timestamp.fromDate(DateTime.now()),
    });

    // 3. Referință pentru actualizarea monedelor utilizatorului (+1 coin pentru recunoștință)
    final userRef = _db.collection('users').doc(uid);
    batch.update(userRef, {
      'coins': currentCoins + 1,
    });

    try {
      await batch.commit();
      debugPrint("Mesaj adăugat și plantă udată cu succes prin Write Batch.");
    } on FirebaseException catch (e) {
      debugPrint("Eroare Firestore la salvarea mesajului (Write Batch): ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Eroare neașteptată la salvarea mesajului (Write Batch): $e");
      rethrow;
    }
  }
}
