import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import 'package:wastenot/features/donor/presentation/home/screens/donor_home_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin_signup_screen.dart';
import '../features/admin/home/admin_home_screen.dart';
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

                    final user = userSnap.data!;
final role = user['role'];

if (role == 'Admin') {
  return AdminHomeScreen(user: user);
}

if (role == 'Donor') {
  return DonorHomeScreen(user: user);
}

if (role == 'NGO') {
  return NgoHomeScreen(user: user);
}

return const WelcomeScreen();

                  },
                );
              }

              return const WelcomeScreen();
            },
          ),
        );

     case roleSelection:
  return MaterialPageRoute(
builder: (_) => const RoleSelectionScreen(isLogin: true),  );

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
