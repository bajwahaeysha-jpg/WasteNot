import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/navigation/admin_bottom_navigation.dart';
import 'package:wastenot/features/donor/presentation/donor_navigation_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/services/auth_service.dart';

class AppNavigationHandler {
  static Route<void> loginRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    );
  }

  static Route<void> homeRoute(AppUserModel user) {
    return MaterialPageRoute<void>(
      builder: (_) => _ProtectedHomeScreen(initialUser: user),
    );
  }

  static Future<void> goToLogin(
    BuildContext context, {
    bool clearStack = true,
  }) async {
    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(loginRoute(), (route) => false);
      return;
    }

    await Navigator.of(context).push(loginRoute());
  }

  static Future<void> goToHome(
    BuildContext context,
    AppUserModel user, {
    bool clearStack = true,
  }) async {
    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(homeRoute(user), (route) => false);
      return;
    }

    await Navigator.of(context).push(homeRoute(user));
  }

  static Widget homeForUser(AppUserModel user) {
    if (user.isAdmin) {
      return AdminBottomNavigation(user: user.toNavigationUser());
    }

    if (user.isNgo) {
      return NgoHomeScreen(user: user.toNavigationUser());
    }

    return DonorNavigationScreen(user: user.toNavigationUser());
  }
}

class _ProtectedHomeScreen extends StatefulWidget {
  const _ProtectedHomeScreen({
    required this.initialUser,
  });

  final AppUserModel initialUser;

  @override
  State<_ProtectedHomeScreen> createState() => _ProtectedHomeScreenState();
}

class _ProtectedHomeScreenState extends State<_ProtectedHomeScreen> {
  late final Future<AppUserModel?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AuthService().checkUserSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUserModel?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            AppNavigationHandler.goToLogin(context);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppNavigationHandler.homeForUser(user);
      },
    );
  }
}
