import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../models/message_model.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';
import 'plant_history_page.dart';

class PlantDetailPage extends StatefulWidget {
  final String userId;
  final String plantId;

  const PlantDetailPage({
    super.key,
    required this.userId,
    required this.plantId,
  });

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final _dbService = DatabaseService();
  late Stream<UserModel?> _userStream;
  late Stream<PlantModel?> _plantStream;
  late Stream<List<MessageModel>> _messagesStream;
  final _gratitudeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _userStream = _dbService.userStream(widget.userId);
    _plantStream = _dbService.plantStream(widget.userId, widget.plantId);
    _messagesStream = _dbService.messagesStream(widget.userId, widget.plantId);
  }

  @override
  void dispose() {
    _gratitudeController.dispose();
    super.dispose();
  }

  IconData _getPlantIcon(String plantType) {
    switch (plantType.toLowerCase()) {
      case 'oak':
        return Icons.nature;
      case 'fern':
        return Icons.spa;
      case 'bonsai':
        return Icons.eco;
      case 'succulent':
        return Icons.yard_outlined;
      case 'bamboo':
        return Icons.grass;
      default:
        return Icons.spa_outlined;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _deletePlant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppColors.charcoal.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          title: Text(
            'Delete Plant',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this plant from your garden? This action cannot be undone.',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.paleGreenGray.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.paleGreenGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93000A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        await _dbService.deletePlant(widget.userId, widget.plantId);
        // Page stream pop listener handles returning back
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete plant: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showGratitudeModal(
    BuildContext context,
    PlantModel plant,
    UserModel? user,
  ) {
    _gratitudeController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water with Gratitude',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white60,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reflect on something you appreciate today. Writing this message increases your streak and awards you +1 coin!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.paleGreenGray.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.glassBg.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: TextField(
                            controller: _gratitudeController,
                            maxLines: 4,
                            autofocus: true,
                            style: GoogleFonts.notoSerif(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Today, I am grateful for...',
                              hintStyle: GoogleFonts.notoSerif(
                                fontSize: 16,
                                color: AppColors.paleGreenGray.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  final text = _gratitudeController.text.trim();
                                  if (text.isEmpty) return;

                                  setModalState(() {
                                    _isSubmitting = true;
                                  });
                                  setState(() {
                                    _isSubmitting = true;
                                  });

                                  final navigator = Navigator.of(context);
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);

                                  try {
                                    final currentCoins = user?.coins ?? 0;
                                    await _dbService.addMessage(
                                      widget.userId,
                                      widget.plantId,
                                      text,
                                      plant.streak,
                                      currentCoins,
                                    );
                                    if (mounted) {
                                      navigator.pop();
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Gratitude recorded! +1 Coin',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          backgroundColor: AppColors.seedGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // Log or handle error
                                  } finally {
                                    if (mounted) {
                                      setModalState(() {
                                        _isSubmitting = false;
                                      });
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.seedGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textDark,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: AppColors.textDark,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Water with Gratitude',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;

        return StreamBuilder<PlantModel?>(
          stream: _plantStream,
          builder: (context, plantSnapshot) {
            final plant = plantSnapshot.data;

            // Handle deletion gracefully
            if (plantSnapshot.connectionState == ConnectionState.active &&
                plant == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
              return const Scaffold(
                backgroundColor: AppColors.charcoal,
                body: ZenBackground(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.seedGreen,
                    ),
                  ),
                ),
              );
            }

            if (plant == null) {
              return const Scaffold(
                backgroundColor: AppColors.charcoal,
                body: ZenBackground(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.seedGreen,
                    ),
                  ),
                ),
              );
            }

            final progress = (plant.streak % 5) / 5;
            final displayProgress = progress == 0.0 ? 0.1 : progress;

            // Scale factor for glow and avatar size based on plant level
            final levelScale = 1.0 + (plant.plantLevel - 1) * 0.05;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ZenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Detail Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
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
                              plant.plantName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFC06B6B),
                                size: 22,
                              ),
                              onPressed: _deletePlant,
                            ),
                          ],
                        ),
                      ),

                      // Detail Content scroll area
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),

                              // Plant Display Box
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Glow Ring
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      width: 180 * levelScale,
                                      height: 180 * levelScale,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.seedGreen.withValues(
                                              alpha:
                                                  0.18 +
                                                  (plant.plantLevel * 0.02)
                                                      .clamp(0.0, 0.12),
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Sprout image
                                    SizedBox(
                                      width: 140 * levelScale,
                                      height: 140 * levelScale,
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCoWkZpvg2y3XCY-IEILuXGTX3VgP4SAXOf-jkGfHXHiVN3IgK0b5Cp67J60MOtvGXW9FnlOJEB025a15t0LhYHAmtakLqy3WsXAZrxbBuAz8x1-T1gzF2X_5HNGElDU9vY2qJENr-a72bnddvnLp6XdMMT9lPkFDP_0f7-EZOp7ulxt5I4B1Fm9sobL3HR__XjrEbRfTv81IGsHRw9rrQxYfOY965XB0SNf_3Nfikx7nohBMcm1wKy9os_-6CTApkPMabAvTMI-Rs',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Plant Attributes Card
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.glassBg.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                _getPlantIcon(plant.plantType),
                                                color: AppColors.lightGreen,
                                                size: 26,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                plant.plantType.toUpperCase(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .paleGreenGray
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      letterSpacing: 0.8,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                'Lvl ${plant.plantLevel}',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'PLANT LEVEL',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.lightGreen,
                                                      letterSpacing: 1.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${plant.streak} 🔥',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'DAY STREAK',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.lightGreen,
                                                      letterSpacing: 1.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Progress bar details
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Next Level',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppColors.paleGreenGray
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                          Text(
                                            '${(progress * 5).toInt()} / 5 Days',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.lightGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 6,
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
                                ),
                              ),

                              // Warning banner if not watered for more than 1 day
                              if (DateTime.now()
                                      .difference(plant.lastWatered)
                                      .inDays >=
                                  1) ...[
                                Builder(
                                  builder: (context) {
                                    final now = DateTime.now();
                                    final daysSinceWatered = now
                                        .difference(plant.lastWatered)
                                        .inDays;
                                    final isCritical = daysSinceWatered >= 3;

                                    final String warningMessage;
                                    if (isCritical) {
                                      final deadline = plant.lastWatered.add(
                                        const Duration(days: 3),
                                      );
                                      final remaining = deadline.difference(
                                        now,
                                      );
                                      final remainingHours = remaining.inHours;
                                      if (remainingHours > 0) {
                                        warningMessage =
                                            "You have only $remainingHours ${remainingHours == 1 ? 'hour' : 'hours'} left to water this plant, otherwise it will die!";
                                      } else {
                                        warningMessage =
                                            "Your plant is critical! Water it immediately to save it from dying!";
                                      }
                                    } else {
                                      warningMessage =
                                          "You haven't been grateful for $daysSinceWatered ${daysSinceWatered == 1 ? 'day' : 'days'}. Water your plant to keep it growing!";
                                    }

                                    final bannerBgColor = isCritical
                                        ? const Color(
                                            0xFF93000A,
                                          ).withValues(alpha: 0.25)
                                        : const Color(
                                            0xFF93000A,
                                          ).withValues(alpha: 0.15);
                                    final bannerBorderColor = isCritical
                                        ? const Color(
                                            0xFFFFB4AB,
                                          ).withValues(alpha: 0.5)
                                        : const Color(
                                            0xFF93000A,
                                          ).withValues(alpha: 0.3);
                                    final iconColor = isCritical
                                        ? const Color(0xFFFF897A)
                                        : const Color(0xFFFFB4AB);

                                    return Column(
                                      children: [
                                        const SizedBox(height: 24),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: bannerBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: bannerBorderColor,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: iconColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    warningMessage,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 13,
                                                          color: iconColor,
                                                          fontWeight: isCritical
                                                              ? FontWeight.w700
                                                              : FontWeight.w500,
                                                          height: 1.4,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Nurture CTA Button
                              Builder(
                                builder: (context) {
                                  final now = DateTime.now();
                                  final alreadyWateredToday =
                                      plant.lastWatered.year == now.year &&
                                      plant.lastWatered.month == now.month &&
                                      plant.lastWatered.day == now.day;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: alreadyWateredToday
                                          ? null
                                          : () => _showGratitudeModal(
                                              context,
                                              plant,
                                              user,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.seedGreen,
                                        disabledBackgroundColor: Colors.white
                                            .withValues(alpha: 0.08),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        elevation: alreadyWateredToday ? 0 : 4,
                                        shadowColor: AppColors.seedGreen
                                            .withValues(alpha: 0.3),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            alreadyWateredToday
                                                ? Icons.check_circle_outline
                                                : Icons.water_drop,
                                            color: alreadyWateredToday
                                                ? Colors.white.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : AppColors.textDark,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            alreadyWateredToday
                                                ? 'Already Watered Today'
                                                : 'Write Gratitude Message',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: alreadyWateredToday
                                                  ? Colors.white.withValues(
                                                      alpha: 0.35,
                                                    )
                                                  : AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 36),

                              // History Title
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'GRATITUDE HISTORY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.paleGreenGray.withValues(
                                      alpha: 0.6,
                                    ),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // History list view
                              StreamBuilder<List<MessageModel>>(
                                stream: _messagesStream,
                                builder: (context, msgSnapshot) {
                                  if (msgSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.seedGreen,
                                      ),
                                    );
                                  }

                                  final messages = msgSnapshot.data ?? [];
                                  if (messages.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.glassBg.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.04,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40,
                                        horizontal: 24,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.edit_note,
                                            size: 44,
                                            color: AppColors.paleGreenGray
                                                .withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No entries yet',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Every gratitude message you write will be saved here in the plant history.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: AppColors.paleGreenGray
                                                  .withValues(alpha: 0.5),
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final displayCount = messages.length > 3
                                      ? 3
                                      : messages.length;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: displayCount,
                                        itemBuilder: (context, index) {
                                          final msg = messages[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.glassBg
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.05),
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(
                                                20.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.spa_outlined,
                                                            color: AppColors
                                                                .lightGreen,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            'Grateful Reflection',
                                                            style: GoogleFonts.plusJakartaSans(
                                                              fontSize: 11,
                                                              color: AppColors
                                                                  .lightGreen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        _formatDate(
                                                          msg.dateWritten,
                                                        ),
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 11,
                                                              color: AppColors
                                                                  .paleGreenGray
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    msg.messageText,
                                                    style:
                                                        GoogleFonts.notoSerif(
                                                          fontSize: 14.5,
                                                          height: 1.6,
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.9,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (messages.length > 3) ...[
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) => PlantHistoryPage(
                                                      userId: widget.userId,
                                                      plantId: widget.plantId,
                                                      plantName:
                                                          plant.plantName,
                                                    ),
                                                transitionsBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child,
                                                    ) {
                                                      final begin =
                                                          const Offset(
                                                            0.0,
                                                            1.0,
                                                          );
                                                      final end = Offset.zero;
                                                      final curve =
                                                          Curves.easeInOut;
                                                      final tween =
                                                          Tween(
                                                            begin: begin,
                                                            end: end,
                                                          ).chain(
                                                            CurveTween(
                                                              curve: curve,
                                                            ),
                                                          );
                                                      return SlideTransition(
                                                        position: animation
                                                            .drive(tween),
                                                        child: child,
                                                      );
                                                    },
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            foregroundColor:
                                                AppColors.lightGreen,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'See All Reflections (${messages.length})',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
