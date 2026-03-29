import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    final user = await _authService.checkUserSession();
    if (!mounted) {
      return;
    }

    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(AppNavigationHandler.homeRoute(user));
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
