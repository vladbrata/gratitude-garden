import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized color palette for the Gratitude Garden app.
class AppColors {
  static const Color seedGreen = Color(0xFF54AA1D);
  static const Color charcoal = Color(0xFF2D2A2A);
  static const Color lightGreen = Color(0xFF82DC4D);
  static const Color paleGreenGray = Color(0xFFC0CAB4);
  static const Color zenDarkGreen = Color(0xFF1E261A);
  static const Color glassBg = Color(0x80100E0E);
  static const Color cardBg = Color(0xFF353232);
  static const Color textLight = Color(0xFFC0CAB4);
  static const Color textDark = Color(0xFF143700);

  // Radial glow colors
  static const Color lightGreenAura = Color(0x1F82DC4D); // 12% opacity
  static const Color deepGreenAura = Color(0x1954AA1D); // 10% opacity
}

/// Centralized typographic styles using Google Fonts.
class AppFonts {
  /// Serif headings (e.g. Lora)
  static TextStyle title({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.paleGreenGray,
    double? letterSpacing,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Clean UI/Body text (e.g. Plus Jakarta Sans)
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.paleGreenGray,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Noto Serif for form inputs, text values
  static TextStyle serif({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSerif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

/// A reusable Zen garden background widget that applies linear gradients,
/// radial light/earth glows, and the willow tree line art decoration.
class ZenBackground extends StatelessWidget {
  final Widget child;

  const ZenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: AppColors.charcoal),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base smooth diagonal linear gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.zenDarkGreen,
                  Color(
                    0xFF22281D,
                  ), // Smooth intermediate color retaining a slight green tint
                  AppColors.charcoal,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 2. Soft top-left green radial glow
          Positioned(
            top: -150,
            left: -100,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF54AA1D).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Content child
          child,
        ],
      ),
    );
  }
}
