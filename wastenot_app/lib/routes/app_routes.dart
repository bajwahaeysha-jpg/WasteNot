import 'package:flutter/material.dart';

import '../screens/welcome_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../admin/home/admin_home_screen.dart';
import '../services/local_auth_service.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String roleSelection = '/roleSelection';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminHome = '/adminHome';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // 🔐 AUTH GUARD ENTRY POINT
      case welcome:
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<bool>(
            future: LocalAuthService.isLoggedIn(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                final user = LocalAuthService.getUser();

                return FutureBuilder(
                  future: user,
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return AdminHomeScreen(
                      user: {
                        'name': userSnap.data!['name'],
                        'role': userSnap.data!['role'],
                      },
                    );
                  },
                );
              }

              return const WelcomeScreen();
            },
          ),
        );

     case roleSelection:
  return MaterialPageRoute(
    builder: (_) => const RoleSelectionScreen(),
  );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );

      case adminHome:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => AdminHomeScreen(
            user: {
              'name': args['name'],
              'role': args['role'],
            },
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
