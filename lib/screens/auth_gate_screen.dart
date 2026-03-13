import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/navigation/admin_bottom_navigation.dart';
import 'package:wastenot/features/donor/presentation/home/screens/donor_home_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/screens/welcome_screen.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/session_service.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  Future<AppUserModel?> _resolveUser(AuthService authService) async {
    try {
      return await authService.currentUserProfile();
    } catch (_) {
      await authService.signOut();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final sessionUser = SessionService.user;

    if (sessionUser?.isAdmin == true) {
      return AdminBottomNavigation(user: sessionUser!.toNavigationUser());
    }

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        return FutureBuilder<AppUserModel?>(
          future: _resolveUser(authService),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError || userSnapshot.data == null) {
              return const WelcomeScreen();
            }

            final user = userSnapshot.data!;
            if (user.isAdmin) {
              return AdminBottomNavigation(user: user.toNavigationUser());
            }

            if (user.isNgo) {
              return NgoHomeScreen(user: user.toNavigationUser());
            }

            return DonorHomeScreen(user: user.toNavigationUser());
          },
        );
      },
    );
  }
}
