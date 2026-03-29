import 'package:flutter/material.dart';
import 'package:wastenot/screens/admin_signup_screen.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/screens/role_selection_screen.dart';
import 'package:wastenot/screens/splash_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String roleSelection = '/roleSelection';
  static const String login = '/login';
  static const String signup = '/signup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(isLogin: true),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
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
