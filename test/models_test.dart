import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gratitude_garden_app/models/user_model.dart';
import 'package:gratitude_garden_app/models/plant_model.dart';
import 'package:gratitude_garden_app/models/message_model.dart';

void main() {
  group('PlantModel Tests', () {
    test('toMap and fromMap conversion with valid data', () {
      final date = DateTime(2026, 7, 8);
      final plant = PlantModel(
        plantId: 'plant_123',
        userId: 'user_123',
        plantName: 'Rose',
        datePlanted: date,
        lastWatered: date,
        streak: 5,
        plantLevel: 2,
      );

      final map = plant.toMap();
      expect(map['plantId'], isNull); // plantId is excluded from map as it's the document ID
      expect(map['userId'], 'user_123');
      expect(map['plantName'], 'Rose');
      expect(map['streak'], 5);
      expect(map['plantLevel'], 2);
      expect(map['datePlanted'], isA<Timestamp>());
      expect(map['lastWatered'], isA<Timestamp>());

      final parsed = PlantModel.fromMap(map, 'plant_123');
      expect(parsed.plantId, 'plant_123');
      expect(parsed.userId, 'user_123');
      expect(parsed.plantName, 'Rose');
      expect(parsed.streak, 5);
      expect(parsed.plantLevel, 2);
      expect(parsed.datePlanted.year, 2026);
      expect(parsed.lastWatered.year, 2026);
    });

    test('copyWith works correctly', () {
      final plant = PlantModel(
        plantId: 'plant_123',
        userId: 'user_123',
        plantName: 'Rose',
        datePlanted: DateTime(2026, 7, 8),
        lastWatered: DateTime(2026, 7, 8),
        streak: 5,
        plantLevel: 2,
      );

      final updated = plant.copyWith(
        plantName: 'Tulip',
        streak: 6,
      );

      expect(updated.plantName, 'Tulip');
      expect(updated.streak, 6);
      expect(updated.plantId, 'plant_123'); // remains unchanged
    });
  });

  group('UserModel Tests', () {
    test('toMap and fromMap conversion with valid data', () {
      final user = UserModel(
        userId: 'user_123',
        firstName: 'Alice',
        lastName: 'Smith',
        profilePicUrl: 'https://example.com/pic.png',
        coins: 120,
      );

      final map = user.toMap();
      expect(map['userId'], isNull); // userId is excluded from map as it's the document ID
      expect(map['firstName'], 'Alice');
      expect(map['lastName'], 'Smith');
      expect(map['profilePicUrl'], 'https://example.com/pic.png');
      expect(map['coins'], 120);

      final parsed = UserModel.fromMap(map, 'user_123');
      expect(parsed.userId, 'user_123');
      expect(parsed.firstName, 'Alice');
      expect(parsed.lastName, 'Smith');
      expect(parsed.profilePicUrl, 'https://example.com/pic.png');
      expect(parsed.coins, 120);
    });

    test('copyWith works correctly', () {
      final user = UserModel(
        userId: 'user_123',
        firstName: 'Alice',
        lastName: 'Smith',
        profilePicUrl: 'https://example.com/pic.png',
        coins: 120,
      );

      final updated = user.copyWith(
        firstName: 'Alison',
        coins: 150,
      );

      expect(updated.firstName, 'Alison');
      expect(updated.coins, 150);
      expect(updated.userId, 'user_123'); // remains unchanged
    });
  });

  group('MessageModel Tests', () {
    test('toMap and fromMap conversion with valid data', () {
      final date = DateTime(2026, 7, 8);
      final message = MessageModel(
        messageId: 'msg_456',
        plantId: 'plant_123',
        userId: 'user_123',
        dateWritten: date,
        messageText: 'Gratitude text',
      );

      final map = message.toMap();
      expect(map['messageId'], isNull); // messageId is excluded from map as it's the document ID
      expect(map['plantId'], 'plant_123');
      expect(map['userId'], 'user_123');
      expect(map['messageText'], 'Gratitude text');
      expect(map['dateWritten'], isA<Timestamp>());

      final parsed = MessageModel.fromMap(map, 'msg_456');
      expect(parsed.messageId, 'msg_456');
      expect(parsed.plantId, 'plant_123');
      expect(parsed.userId, 'user_123');
      expect(parsed.messageText, 'Gratitude text');
      expect(parsed.dateWritten.year, 2026);
    });
  });
}
