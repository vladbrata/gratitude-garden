import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_garden_app/widgets/user_header.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';

class HomePageV2 extends StatelessWidget {
  final UserModel user;
  final List<PlantModel> plants;

  const HomePageV2({super.key, required this.user, required this.plants});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: ZenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserHeader(user: user),

              // Garden Grid or Empty State
              if (plants.isEmpty)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.seedGreen.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.lightGreen.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: AppColors.lightGreen,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No plants yet',
                            style: GoogleFonts.lora(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFAF4F4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Your garden is waiting to grow. Plant your first seed and nurture it with daily gratitude.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppColors.paleGreenGray.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: 220,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Do nothing for now
                              },
                              icon: const Icon(Icons.add, color: Color(0xFFFAF4F4), size: 20),
                              label: Text(
                                'Plant a Seed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFAF4F4),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.seedGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                elevation: 3,
                                shadowColor: AppColors.seedGreen.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            0.62, // Taller ratio to match Stitch screen card aspect ratio
                      ),
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        final progress = (plant.streak % 5) / 5;
                        final displayProgress = progress == 0.0 ? 0.1 : progress;

                        return GestureDetector(
                          // onTap: () => _showPlantOptions(context, plant),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF373434,
                                  ).withValues(alpha: 0.4),
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
                                              AppColors.seedGreen.withValues(
                                                alpha: 0.15,
                                              ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          plant.plantName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFAF4F4),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Lv. ${plant.plantLevel} Oak Sprout',
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
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: displayProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.seedGreen,
                                                borderRadius:
                                                    BorderRadius.circular(999),
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
