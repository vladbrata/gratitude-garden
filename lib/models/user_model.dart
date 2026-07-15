import 'package:cloud_firestore/cloud_firestore.dart';

/// Reprezintă modelul de date pentru un Utilizator din Firestore (`/users/{userId}`).
class UserModel {
  /// ID-ul unic al documentului, preluat din Firebase Auth.
  final String userId;

  /// Prenumele utilizatorului.
  final String firstName;

  /// Numele de familie al utilizatorului.
  final String lastName;

  /// URL-ul către imaginea de profil.
  final String profilePicUrl;

  /// Sistemul de reward-uri al aplicației (monede virtuale).
  final int coins;

  /// Constructorul standard cu parametri numiți și imutabili.
  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePicUrl,
    required this.coins,
  });

  /// Factory pentru instanțierea clasei direct dintr-un [DocumentSnapshot] din Firestore.
  /// Extras ID-ul documentului ca fiind [userId] și datele mapate.
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  /// Factory pentru instanțierea clasei dintr-un `Map<String, dynamic>` și un `id` explicit.
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      profilePicUrl: map['profilePicUrl'] as String? ?? '',
      coins: map['coins'] as int? ?? 0,
    );
  }

  /// Pregătește datele modelului sub formă de `Map<String, dynamic>` pentru salvarea în Firestore.
  /// `userId` este exclus din map deoarece acționează ca ID-ul documentului în colecție.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicUrl': profilePicUrl,
      'coins': coins,
    };
  }

  /// Creează o copie a obiectului curent, permițând modificarea anumitor câmpuri.
  /// Util pentru state management (Bloc, Riverpod, etc.) unde starea este imutabilă.
  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? profilePicUrl,
    int? coins,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      coins: coins ?? this.coins,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, firstName: $firstName, lastName: $lastName, profilePicUrl: $profilePicUrl, coins: $coins)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.userId == userId &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.profilePicUrl == profilePicUrl &&
      other.coins == coins;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      profilePicUrl.hashCode ^
      coins.hashCode;
  }
}
