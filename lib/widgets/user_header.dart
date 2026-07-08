import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_garden_app/models/my_user.dart';
import 'package:gratitude_garden_app/theme/app_theme.dart';

class UserHeader extends StatelessWidget {
  final MyUser user;

  const UserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Profile Picture with glowing border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF54AA1D).withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF54AA1D).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF3D3A3A),
                backgroundImage: NetworkImage(user.profilePicUrl),
              ),
            ),
            const SizedBox(width: 14),
            // User Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFFC0CAB4),
                  ),
                ),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFAF4F4),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Settings Button
        const Icon(Icons.settings_rounded, color: AppColors.paleGreenGray, size: 28),
      ],
    );
  }
}
