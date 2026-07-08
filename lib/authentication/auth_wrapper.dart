import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gratitude_garden_app/pages/home_page.dart';
import '../pages/auth_page.dart';
import '../pages/home_page_v2.dart';
import 'firebase_auth.dart';
import '../services/db_service.dart';
import '../models/my_user.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DatabaseService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF2D2A2A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF54AA1D)),
            ),
          );
        }

        // If user is not logged in, show AuthPage
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const AuthPage();
        }

        // If user is logged in, stream their MyUser profile from Firestore
        return StreamBuilder<MyUser?>(
          stream: dbService.userDocStream(authSnapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF2D2A2A),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF54AA1D)),
                ),
              );
            }

            if (!userSnapshot.hasData || userSnapshot.data == null) {
              // Fallback in case user is authenticated but user document is not created or found in Firestore
              return Scaffold(
                backgroundColor: const Color(0xFF2D2A2A),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "User profile not found in database.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your account was created in Auth, but no Firestore document was found.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFC0CAB4),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF54AA1D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => authService.logout(),
                          icon: const Icon(Icons.logout),
                          label: const Text("Sign Out"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // User document loaded successfully, navigate to HomePageV2
            return HomePageV2(user: userSnapshot.data!);
          },
        );
      },
    );
  }
}
