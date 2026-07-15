import 'package:cloud_firestore/cloud_firestore.dart';

/// Reprezintă modelul de date pentru o Plantă din Firestore (`/users/{userId}/plants/{plantId}`).
class PlantModel {
  /// ID-ul unic al documentului plantei.
  final String plantId;

  /// Foreign Key către utilizatorul părinte (`userId`).
  final String userId;

  /// Numele dat plantei.
  final String plantName;

  /// Data la care planta a fost plantată.
  final DateTime datePlanted;

  /// Data la care planta a fost udată ultima dată (când s-a scris ultimul mesaj de recunoștință).
  final DateTime lastWatered;

  /// Zilele consecutive în care planta a fost udată.
  final int streak;

  /// Nivelul de dezvoltare al plantei.
  final int plantLevel;

  /// Tipul/specia plantei (ex: Bonsai, Oak, Fern, Succulent, Bamboo).
  final String plantType;

  /// Constructorul standard cu parametri numiți și imutabili.
  PlantModel({
    required this.plantId,
    required this.userId,
    required this.plantName,
    required this.datePlanted,
    required this.lastWatered,
    required this.streak,
    required this.plantLevel,
    this.plantType = 'Oak',
  });

  /// Factory pentru instanțierea clasei direct dintr-un [DocumentSnapshot] din Firestore.
  /// Extras ID-ul documentului ca fiind [plantId] și datele mapate.
  factory PlantModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlantModel.fromMap(data, doc.id);
  }

  /// Factory pentru instanțierea clasei dintr-un `Map<String, dynamic>` și un `id` explicit.
  /// Gestionează conversia sigură a tipurilor [Timestamp] din Firestore în [DateTime] din Dart.
  factory PlantModel.fromMap(Map<String, dynamic> map, String id) {
    return PlantModel(
      plantId: id,
      userId: map['userId'] as String? ?? '',
      plantName: map['plantName'] as String? ?? '',
      datePlanted: _parseDateTime(map['datePlanted']),
      lastWatered: _parseDateTime(map['lastWatered']),
      streak: map['streak'] as int? ?? 0,
      plantLevel: map['plantLevel'] as int? ?? 1,
      plantType: map['plantType'] as String? ?? 'Oak',
    );
  }

  /// Pregătește datele modelului sub formă de `Map<String, dynamic>` pentru salvarea în Firestore.
  /// Câmpurile de tip [DateTime] sunt convertite în [Timestamp] pentru a fi stocate corect în Firestore.
  /// `plantId` este exclus din map deoarece acționează ca ID-ul documentului în colecție.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plantName': plantName,
      'datePlanted': Timestamp.fromDate(datePlanted),
      'lastWatered': Timestamp.fromDate(lastWatered),
      'streak': streak,
      'plantLevel': plantLevel,
      'plantType': plantType,
    };
  }

  /// Creează o copie a obiectului curent, permițând modificarea anumitor câmpuri.
  /// Util pentru state management (Bloc, Riverpod, etc.) unde starea este imutabilă.
  PlantModel copyWith({
    String? plantId,
    String? userId,
    String? plantName,
    DateTime? datePlanted,
    DateTime? lastWatered,
    int? streak,
    int? plantLevel,
    String? plantType,
  }) {
    return PlantModel(
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      plantName: plantName ?? this.plantName,
      datePlanted: datePlanted ?? this.datePlanted,
      lastWatered: lastWatered ?? this.lastWatered,
      streak: streak ?? this.streak,
      plantLevel: plantLevel ?? this.plantLevel,
      plantType: plantType ?? this.plantType,
    );
  }

  /// Helper static privat pentru a asigura conversia corectă a tipului de date
  /// din Firestore (Timestamp) sau alte surse (String/int) în [DateTime].
  static DateTime _parseDateTime(dynamic val) {
    if (val is Timestamp) {
      // Conversie directă din Timestamp Firestore
      return val.toDate();
    } else if (val is String) {
      // Parsare în caz că valoarea este stocată ca String ISO-8601
      return DateTime.tryParse(val) ?? DateTime.now();
    } else if (val is int) {
      // Conversie în caz că valoarea este stocată ca epoch în milisecunde
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    // Fallback în caz de valoare nulă sau tip neașteptat
    return DateTime.now();
  }

  @override
  String toString() {
    return 'PlantModel(plantId: $plantId, userId: $userId, plantName: $plantName, datePlanted: $datePlanted, lastWatered: $lastWatered, streak: $streak, plantLevel: $plantLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PlantModel &&
      other.plantId == plantId &&
      other.userId == userId &&
      other.plantName == plantName &&
      other.datePlanted == datePlanted &&
      other.lastWatered == lastWatered &&
      other.streak == streak &&
      other.plantLevel == plantLevel;
  }

  @override
  int get hashCode {
    return plantId.hashCode ^
      userId.hashCode ^
      plantName.hashCode ^
      datePlanted.hashCode ^
      lastWatered.hashCode ^
      streak.hashCode ^
      plantLevel.hashCode;
  }
}
