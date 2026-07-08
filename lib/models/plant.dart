import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final int streak;
  final String user;
  final DateTime datePlanted;
  final DateTime lastWattered;

  Plant({
    required this.id,
    required this.name,
    required this.streak,
    required this.user,
    required this.datePlanted,
    required this.lastWattered,
  });

  /// Factory constructor to create a [Plant] with placeholder values if any data is incorrect or missing.
  factory Plant.withPlaceholders({
    String? id,
    String? name,
    int? streak,
    String? user,
    DateTime? datePlanted,
  }) {
    return Plant(
      id: (id == null || id.trim().isEmpty)
          ? 'plant_${DateTime.now().microsecondsSinceEpoch}'
          : id,
      name: (name == null || name.trim().isEmpty) ? 'Sprout' : name,
      streak: (streak == null || streak < 0) ? 0 : streak,
      user: (user == null || user.trim().isEmpty) ? 'Anonymous' : user,
      datePlanted: datePlanted ?? DateTime.now(),
      lastWattered: DateTime.now(),
    );
  }

  /// Converts the [Plant] instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'streak': streak,
      'user': user,
      'datePlanted': Timestamp.fromDate(datePlanted),
      'lastWattered': Timestamp.fromDate(lastWattered),
    };
  }

  /// Creates a [Plant] instance from a Firestore Map.
  factory Plant.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['datePlanted'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Plant(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Sprout',
      streak: map['streak'] as int? ?? 0,
      user: map['user'] as String? ?? 'Anonymous',
      datePlanted: parsedDate,
      lastWattered: DateTime.now(),
    );
  }
}
