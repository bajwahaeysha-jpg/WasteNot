import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    final user = await _authRepository.resolveStartupSession(
      timeout: const Duration(seconds: 23),
    );

    if (!mounted) {
      return;
    }

    if (user != null) {
      AppNavigationHandler.goToHome(context, user);
      return;
    }

    AppNavigationHandler.goToWelcome(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
