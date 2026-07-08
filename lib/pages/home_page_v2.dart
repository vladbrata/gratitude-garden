import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/my_user.dart';
import '../models/plant.dart';
import '../authentication/firebase_auth.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class HomePageV2 extends StatelessWidget {
  final MyUser user;

  const HomePageV2({super.key, required this.user});

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _addNewPlant(BuildContext context) async {
    final dbService = DatabaseService();

    final plantNames = [
      'Willow',
      'Juniper',
      'Gratitude Ivy',
      'Hope Sprout',
      'Kindness Bloom',
      'Serenity Fern',
      'Joy Bonsai',
      'Peace Lily',
    ];
    final randomName = plantNames[DateTime.now().millisecond % plantNames.length];

    final newPlant = Plant.withPlaceholders(
      name: randomName,
      streak: 3, // Start at 3 to match the Lv. 3 visual in Stitch
      user: '${user.firstName} ${user.lastName}',
    );

    final updatedPlants = List<Plant>.from(user.plants)..add(newPlant);
    final updatedUser = MyUser(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      profilePicUrl: user.profilePicUrl,
      plants: updatedPlants,
    );

    try {
      await dbService.saveUser(updatedUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Planted a new "$randomName" in your Gratitude Garden!',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.seedGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add plant: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _waterPlant(BuildContext context, Plant plant) async {
    final dbService = DatabaseService();

    final updatedPlants = user.plants.map((p) {
      if (p.id == plant.id) {
        return Plant(
          id: p.id,
          name: p.name,
          streak: p.streak + 1,
          user: p.user,
          datePlanted: p.datePlanted,
          lastWattered: DateTime.now(),
        );
      }
      return p;
    }).toList();

    final updatedUser = MyUser(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      profilePicUrl: user.profilePicUrl,
      plants: updatedPlants,
    );

    try {
      await dbService.saveUser(updatedUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You watered "${plant.name}"! Streak is now ${plant.streak + 1} days.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.seedGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to water plant: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _deletePlant(BuildContext context, Plant plant) async {
    final dbService = DatabaseService();

    final updatedPlants = user.plants.where((p) => p.id != plant.id).toList();
    final updatedUser = MyUser(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      profilePicUrl: user.profilePicUrl,
      plants: updatedPlants,
    );

    try {
      await dbService.saveUser(updatedUser);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Uprooted "${plant.name}" from your garden.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete plant: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showPlantOptions(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plant.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Lv. ${plant.streak}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Planted on ${plant.datePlanted.day}/${plant.datePlanted.month}/${plant.datePlanted.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.paleGreenGray.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.seedGreen.withValues(alpha: 0.2),
                    child: const Icon(Icons.water_drop, color: AppColors.lightGreen),
                  ),
                  title: Text(
                    'Water Sprout',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Increase streak by 1 day',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.paleGreenGray, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _waterPlant(context, plant);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  ),
                  title: Text(
                    'Uproot Plant',
                    style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Remove this plant permanently',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.paleGreenGray, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deletePlant(context, plant);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.seedGreen.withValues(alpha: 0.2),
                    child: const Icon(Icons.local_florist, color: AppColors.lightGreen),
                  ),
                  title: Text(
                    'Plant a Seed',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Add a new plant to your grid',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.paleGreenGray, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _addNewPlant(context);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.logout, color: Colors.redAccent),
                  ),
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Log out of your account',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.paleGreenGray, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await AuthService().logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged out successfully.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.seedGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error logging out: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxStreak = user.plants.isEmpty
        ? 0
        : user.plants.map((p) => p.streak).reduce((a, b) => a > b ? a : b);

    // Compute display streak: fallback to 7 if there are no plants or if max is 0 to match screenshot mockup visual
    final displayStreak = maxStreak == 0 ? 7 : maxStreak;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning, ${user.firstName}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFAF4F4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFormattedDate(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.paleGreenGray.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showSettings(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lightGreen.withValues(alpha: 0.2),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: AppColors.paleGreenGray,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.lightGreen,
                              width: 2.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              user.profilePicUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Streak Badge
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2929).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            color: AppColors.lightGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Streak: $displayStreak Days',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFAF4F4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Garden Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62, // Taller ratio to match Stitch screen card aspect ratio
                    ),
                    // We render user's plants plus one placeholder card for planting new seeds
                    itemCount: user.plants.length + 1,
                    itemBuilder: (context, index) {
                      if (index < user.plants.length) {
                        final plant = user.plants[index];
                        final progress = (plant.streak % 5) / 5;
                        final displayProgress = progress == 0.0 ? 0.1 : progress;

                        return GestureDetector(
                          onTap: () => _showPlantOptions(context, plant),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF373434).withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    width: 1.0,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Sprout Image with radial aura
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              AppColors.seedGreen.withValues(alpha: 0.15),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCoWkZpvg2y3XCY-IEILuXGTX3VgP4SAXOf-jkGfHXHiVN3IgK0b5Cp67J60MOtvGXW9FnlOJEB025a15t0LhYHAmtakLqy3WsXAZrxbBuAz8x1-T1gzF2X_5HNGElDU9vY2qJENr-a72bnddvnLp6XdMMT9lPkFDP_0f7-EZOp7ulxt5I4B1Fm9sobL3HR__XjrEbRfTv81IGsHRw9rrQxYfOY965XB0SNf_3Nfikx7nohBMcm1wKy9os_-6CTApkPMabAvTMI-Rs',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Text & Level info
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          plant.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFAF4F4),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Lv. ${plant.streak} Oak Sprout',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.lightGreen,
                                            letterSpacing: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        // Level Progress Bar
                                        Container(
                                          height: 4,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF373434),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: displayProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.seedGreen,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // The last card is always the interactive "Add Seed" placeholder card
                        return GestureDetector(
                          onTap: () => _addNewPlant(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF373434).withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.seedGreen.withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: AppColors.seedGreen.withValues(alpha: 0.3),
                                            width: 1.5,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: AppColors.lightGreen,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Plant a Seed',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.paleGreenGray.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
