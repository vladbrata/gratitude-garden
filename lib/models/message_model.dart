import 'package:cloud_firestore/cloud_firestore.dart';

/// Reprezintă modelul de date pentru un Mesaj din Firestore (`/users/{userId}/plants/{plantId}/messages/{messageId}`).
class MessageModel {
  /// ID-ul unic al documentului mesajului.
  final String messageId;

  /// Foreign Key către planta de care aparține mesajul (`plantId`).
  final String plantId;

  /// Foreign Key către autorul mesajului (`userId`).
  final String userId;

  /// Data la care a fost scris mesajul de recunoștință.
  final DateTime dateWritten;

  /// Textul gândului de recunoștință.
  final String messageText;

  /// Constructorul standard cu parametri numiți și imutabili.
  MessageModel({
    required this.messageId,
    required this.plantId,
    required this.userId,
    required this.dateWritten,
    required this.messageText,
  });

  /// Factory pentru instanțierea clasei direct dintr-un [DocumentSnapshot] din Firestore.
  /// Extras ID-ul documentului ca fiind [messageId] și datele mapate.
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel.fromMap(data, doc.id);
  }

  /// Factory pentru instanțierea clasei dintr-un `Map<String, dynamic>` și un `id` explicit.
  /// Gestionează conversia sigură a tipului [Timestamp] din Firestore în [DateTime] din Dart.
  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      plantId: map['plantId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      dateWritten: _parseDateTime(map['dateWritten']),
      messageText: map['messageText'] as String? ?? '',
    );
  }

  /// Pregătește datele modelului sub formă de `Map<String, dynamic>` pentru salvarea în Firestore.
  /// Câmpurile de tip [DateTime] sunt convertite în [Timestamp] pentru a fi stocate corect în Firestore.
  /// `messageId` este exclus din map deoarece acționează ca ID-ul documentului în colecție.
  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'userId': userId,
      'dateWritten': Timestamp.fromDate(dateWritten),
      'messageText': messageText,
    };
  }

  /// Creează o copie a obiectului curent, permițând modificarea anumitor câmpuri.
  /// Util pentru state management (Bloc, Riverpod, etc.) unde starea este imutabilă.
  MessageModel copyWith({
    String? messageId,
    String? plantId,
    String? userId,
    DateTime? dateWritten,
    String? messageText,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      dateWritten: dateWritten ?? this.dateWritten,
      messageText: messageText ?? this.messageText,
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
    return 'MessageModel(messageId: $messageId, plantId: $plantId, userId: $userId, dateWritten: $dateWritten, messageText: $messageText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MessageModel &&
      other.messageId == messageId &&
      other.plantId == plantId &&
      other.userId == userId &&
      other.dateWritten == dateWritten &&
      other.messageText == messageText;
  }

  @override
  int get hashCode {
    return messageId.hashCode ^
      plantId.hashCode ^
      userId.hashCode ^
      dateWritten.hashCode ^
      messageText.hashCode;
  }
}
