import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';
import 'plant_detail_page.dart';

class CreatePlantPage extends StatefulWidget {
  final UserModel user;

  const CreatePlantPage({super.key, required this.user});

  @override
  State<CreatePlantPage> createState() => _CreatePlantPageState();
}

class _CreatePlantPageState extends State<CreatePlantPage> {
  final _nameController = TextEditingController();
  final _dbService = DatabaseService();
  String _selectedSpirit = 'Bonsai';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _spiritOptions = [
    {
      'name': 'Oak',
      'icon': Icons.nature,
      'trait': 'strength and endurance',
    },
    {
      'name': 'Fern',
      'icon': Icons.spa,
      'trait': 'growth and adaptability',
    },
    {
      'name': 'Bonsai',
      'icon': Icons.eco,
      'trait': 'patience and resilience',
    },
    {
      'name': 'Succulent',
      'icon': Icons.yard_outlined,
      'trait': 'mindfulness and peace',
    },
    {
      'name': 'Bamboo',
      'icon': Icons.grass,
      'trait': 'flexibility and strength',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitPlant() async {
    final plantName = _nameController.text.trim();
    if (plantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please give your plant a name first!',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFAF4F4),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF93000A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final plantId = await _dbService.addPlant(
        widget.user.userId,
        plantName,
        _selectedSpirit,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              userId: widget.user.userId,
              plantId: plantId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add plant. Please try again.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _spiritOptions.firstWhere(
      (opt) => opt['name'] == _selectedSpirit,
      orElse: () => _spiritOptions[2], // Bonsai
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.paleGreenGray,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'New Plant',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button space
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Naming Section
                      Text(
                        'NAME YOUR PLANT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.paleGreenGray.withValues(alpha: 0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.glassBg.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.notoSerif(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g., Willow, Juniper...',
                                hintStyle: GoogleFonts.notoSerif(
                                  fontSize: 18,
                                  color: AppColors.paleGreenGray.withValues(alpha: 0.35),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Plant Selection Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Your Spirit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '5 VARIETIES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightGreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid layout matching Stitch (Oak, Fern, Bonsai, Succulent, Bamboo)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: _spiritOptions.length,
                        itemBuilder: (context, index) {
                          final option = _spiritOptions[index];
                          final name = option['name'] as String;
                          final icon = option['icon'] as IconData;
                          final isActive = _selectedSpirit == name;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSpirit = name;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.seedGreen.withValues(alpha: 0.25)
                                    : AppColors.glassBg.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.lightGreen.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.05),
                                  width: isActive ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive
                                          ? AppColors.lightGreen.withValues(alpha: 0.15)
                                          : Colors.white.withValues(alpha: 0.04),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isActive ? AppColors.lightGreen : AppColors.paleGreenGray,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isActive ? Colors.white : AppColors.paleGreenGray,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Nurturing Guide Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.glassBg.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppColors.lightGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'NURTURING GUIDE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightGreen,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: AppColors.paleGreenGray.withValues(alpha: 0.85),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Each plant in your garden grows when you record a moment of gratitude. This $_selectedSpirit represents ',
                                      ),
                                      TextSpan(
                                        text: selectedOption['trait'],
                                        style: TextStyle(
                                          color: AppColors.lightGreen,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: GoogleFonts.notoSerif().fontFamily,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom Button CTA
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPlant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.seedGreen,
                      disabledBackgroundColor: AppColors.seedGreen.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.seedGreen.withValues(alpha: 0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_florist,
                                color: AppColors.textDark,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Plant in Garden',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
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
