import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wastenot/features/admin/navigation/admin_bottom_navigation.dart';
import 'package:wastenot/features/donor/presentation/donor_navigation_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/repositories/auth_repository.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/screens/welcome_screen.dart';
import 'package:wastenot/services/session_service.dart';

class AppNavigationHandler {
  static Route<void> loginRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    );
  }

  static Route<void> welcomeRoute() {
    return MaterialPageRoute<void>(
      builder: (_) => const WelcomeScreen(),
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

  static Future<void> goToWelcome(
    BuildContext context, {
    bool clearStack = true,
  }) async {
    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(welcomeRoute(), (route) => false);
      return;
    }

    await Navigator.of(context).push(welcomeRoute());
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

  static Future<void> exitApp() {
    return SystemNavigator.pop();
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
  final AuthRepository _authRepository = AuthRepository();
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    SessionService.currentUser.addListener(_handleSessionStateChanged);
    _authRepository.refreshSessionInBackground(
      onResolved: (user) {
        if (!mounted || user != null) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateOut();
        });
      },
    );
  }

  @override
  void dispose() {
    SessionService.currentUser.removeListener(_handleSessionStateChanged);
    super.dispose();
  }

  void _handleSessionStateChanged() {
    final user = SessionService.user;
    if (user != null && !user.isSuspended && !user.isDeleted) {
      return;
    }

    _navigateOut(toLogin: user?.isDeleted == true);
  }

  void _navigateOut({bool toLogin = false}) {
    if (!mounted || _redirecting) {
      return;
    }

    _redirecting = true;
    if (toLogin) {
      AppNavigationHandler.goToLogin(context);
      return;
    }

    AppNavigationHandler.goToWelcome(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        return AppNavigationHandler.homeForUser(user ?? widget.initialUser);
      },
    );
  }
}
