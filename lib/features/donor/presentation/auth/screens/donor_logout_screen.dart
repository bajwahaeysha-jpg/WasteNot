import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/auth_service.dart';

class DonorLogoutScreen extends StatefulWidget {
  const DonorLogoutScreen({super.key});

  @override
  State<DonorLogoutScreen> createState() => _DonorLogoutScreenState();
}

class _DonorLogoutScreenState extends State<DonorLogoutScreen> {
  final AuthService _authService = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 72, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'You will be signed out from your account.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _loading ? null : _logout,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Logout'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _loading = true);
    await _authService.logout();
    if (!mounted) {
      return;
    }
    AppNavigationHandler.goToLogin(context);
  }
}
