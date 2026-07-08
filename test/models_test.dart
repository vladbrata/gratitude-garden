import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gratitude_garden_app/models/my_user.dart';
import 'package:gratitude_garden_app/models/plant.dart';

void main() {
  group('Plant Model Tests', () {
    test('toMap and fromMap conversion with valid data', () {
      final date = DateTime(2026, 7, 8);
      final plant = Plant(
        id: 'plant_123',
        name: 'Rose',
        streak: 5,
        user: 'user_123',
        datePlanted: date,
        lastWattered: date,
      );

      final map = plant.toMap();
      expect(map['id'], 'plant_123');
      expect(map['name'], 'Rose');
      expect(map['streak'], 5);
      expect(map['user'], 'user_123');
      expect(map['datePlanted'], isA<Timestamp>());

      final parsed = Plant.fromMap(map);
      expect(parsed.id, 'plant_123');
      expect(parsed.name, 'Rose');
      expect(parsed.streak, 5);
      expect(parsed.user, 'user_123');
      expect(parsed.datePlanted.year, 2026);
    });

    test('withPlaceholders constructor fallback behavior', () {
      final plant = Plant.withPlaceholders(
        id: '',
        name: null,
        streak: -5,
        user: '   ',
        datePlanted: null,
      );

      expect(plant.id, startsWith('plant_'));
      expect(plant.name, 'Sprout');
      expect(plant.streak, 0);
      expect(plant.user, 'Anonymous');
      expect(plant.datePlanted, isNotNull);
    });
  });

  group('MyUser Model Tests', () {
    test('toMap and fromMap conversion with valid data', () {
      final date = DateTime(2026, 7, 8);
      final plant = Plant(
        id: 'plant_123',
        name: 'Rose',
        streak: 5,
        user: 'user_123',
        datePlanted: date,
        lastWattered: date,
      );

      final user = MyUser(
        id: 'user_123',
        firstName: 'Alice',
        lastName: 'Smith',
        profilePicUrl: 'https://example.com/pic.png',
        plants: [plant],
      );

      final map = user.toMap();
      expect(map['id'], isNull); // id is not saved to map
      expect(map['firstName'], 'Alice');
      expect(map['lastName'], 'Smith');
      expect(map['profilePicUrl'], 'https://example.com/pic.png');
      expect(map['plants'], isA<List>());
      expect(map['plants'][0]['name'], 'Rose');

      final parsed = MyUser.fromMap('user_123', map);
      expect(parsed.id, 'user_123');
      expect(parsed.firstName, 'Alice');
      expect(parsed.lastName, 'Smith');
      expect(parsed.profilePicUrl, 'https://example.com/pic.png');
      expect(parsed.plants.length, 1);
      expect(parsed.plants[0].name, 'Rose');
    });

    test('withPlaceholders constructor fallback behavior', () {
      final user = MyUser.withPlaceholders(
        id: '  ',
        firstName: 'Alice123', // invalid characters
        lastName: '', // empty
        profilePicUrl: 'invalid_url', // invalid URL format
        plants: null,
      );

      expect(user.id, startsWith('user_'));
      expect(user.firstName, 'Garden');
      expect(user.lastName, 'Guest');
      expect(
        user.profilePicUrl,
        'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg',
      );
      expect(user.plants, isEmpty);
    });
  });
}
