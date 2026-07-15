import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/auth_page.dart';
import '../pages/home_page_v2.dart';
import 'firebase_auth.dart';
import '../services/db_service.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';

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
            backgroundColor: AppColors.charcoal,
            body: ZenBackground(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF54AA1D)),
              ),
            ),
          );
        }

        // Dacă utilizatorul nu este logat, se afișează AuthPage
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const AuthPage();
        }

        final uid = authSnapshot.data!.uid;

        // Delegăm către un StatefulWidget separat pentru a reține instanțele stream-urilor
        // și a preveni re-crearea lor (și flash-ul de reîncărcare) la fiecare rebuild.
        return _LoggedInSection(
          uid: uid,
          authService: authService,
          dbService: dbService,
        );
      },
    );
  }
}

class _LoggedInSection extends StatefulWidget {
  final String uid;
  final AuthService authService;
  final DatabaseService dbService;

  const _LoggedInSection({
    required this.uid,
    required this.authService,
    required this.dbService,
  });

  @override
  State<_LoggedInSection> createState() => _LoggedInSectionState();
}

class _LoggedInSectionState extends State<_LoggedInSection> {
  late Stream<UserModel?> _userStream;
  late Stream<List<PlantModel>> _plantsStream;

  @override
  void initState() {
    super.initState();
    _userStream = widget.dbService.userStream(widget.uid);
    _plantsStream = widget.dbService.plantsStream(widget.uid);
  }

  @override
  void didUpdateWidget(covariant _LoggedInSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _userStream = widget.dbService.userStream(widget.uid);
      _plantsStream = widget.dbService.plantsStream(widget.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.charcoal,
            body: ZenBackground(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF54AA1D)),
              ),
            ),
          );
        }

        if (!userSnapshot.hasData || userSnapshot.data == null) {
          // Fallback în cazul în care documentul utilizatorului nu există în Firestore
          return Scaffold(
            backgroundColor: AppColors.charcoal,
            body: ZenBackground(
              child: Center(
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
                        "Profilul utilizatorului nu a fost găsit.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Contul a fost creat în Auth, dar nu există un document corespunzător în Firestore.",
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
                        onPressed: () => widget.authService.logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text("Sign Out"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final user = userSnapshot.data!;

        // Ascultăm în timp real colecția de plante (sub-colecție) cu instanța cache-uită a stream-ului
        return StreamBuilder<List<PlantModel>>(
          stream: _plantsStream,
          builder: (context, plantsSnapshot) {
            if (plantsSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.charcoal,
                body: ZenBackground(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF54AA1D)),
                  ),
                ),
              );
            }

            final plantsList = plantsSnapshot.data ?? [];

            return HomePageV2(
              user: user,
              plants: plantsList,
            );
          },
        );
      },
    );
  }
}
