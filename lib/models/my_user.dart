import 'plant.dart';

class MyUser {
  final String id;
  final String firstName;
  final String lastName;
  final String profilePicUrl;
  final List<Plant> plants;

  MyUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicUrl,
    required this.plants,
  });

  /// Factory constructor to create a [MyUser] with placeholder values if any data is incorrect or missing.
  factory MyUser.withPlaceholders({
    String? id,
    String? firstName,
    String? lastName,
    String? profilePicUrl,
    List<Plant>? plants,
  }) {
    // 1. Validate ID (fallback if empty or null)
    final finalId = (id == null || id.trim().isEmpty)
        ? 'user_${DateTime.now().microsecondsSinceEpoch}'
        : id.trim();

    // 2. Validate First Name (only letters, spaces, hyphens, and apostrophes are allowed, must be non-empty)
    final isFirstNameValid =
        firstName != null &&
        firstName.trim().isNotEmpty &&
        RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(firstName);
    final finalFirstName = isFirstNameValid ? firstName.trim() : 'Garden';

    // 3. Validate Last Name (similar rules to First Name)
    final isLastNameValid =
        lastName != null &&
        lastName.trim().isNotEmpty &&
        RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(lastName);
    final finalLastName = isLastNameValid ? lastName.trim() : 'Guest';

    // 4. Validate Profile Picture URL (must be a valid http or https absolute URL)
    bool isUrlValid = false;
    if (profilePicUrl != null && profilePicUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(profilePicUrl);
      isUrlValid =
          uri != null &&
          uri.hasAbsolutePath &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    }
    final finalProfilePicUrl = isUrlValid
        ? profilePicUrl!.trim()
        : 'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg';

    return MyUser(
      id: finalId,
      firstName: finalFirstName,
      lastName: finalLastName,
      profilePicUrl: finalProfilePicUrl,
      plants: plants ?? [],
    );
  }

  /// Converts the [MyUser] instance into a Map for Firestore storage.
  /// Note: The 'id' and 'isValidated' properties are NOT saved in the database fields.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicUrl': profilePicUrl,
      'plants': plants.map((plant) => plant.toMap()).toList(),
    };
  }

  /// Creates a [MyUser] instance from a Map and a document ID.
  /// Supports both camelCase and lowercase/spaced variations of property keys for compatibility.
  factory MyUser.fromMap(String docId, Map<String, dynamic> map) {
    final rawPlants = map['plants'] as List<dynamic>? ?? [];
    final List<Plant> parsedPlants = rawPlants
        .map((p) => Plant.fromMap(Map<String, dynamic>.from(p as Map)))
        .toList();

    return MyUser(
      id: docId,
      firstName:
          (map['firstName'] ?? map['first name'] ?? map['firstname'])
              as String? ??
          'Garden',
      lastName:
          (map['lastName'] ?? map['lastname'] ?? map['last name']) as String? ??
          'Guest',
      profilePicUrl:
          (map['profilePicUrl'] ??
                  map['profilepicurl'] ??
                  map['profile_pic_url'])
              as String? ??
          'https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg',
      plants: parsedPlants,
    );
  }
}
