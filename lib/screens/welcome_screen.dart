import 'package:flutter/material.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/screens/role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);
  static const Color sponsorBlue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5FBF9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: mainGreen.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/welcome_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Donate and share. Make a difference today.\nBecause every meal matters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 42),
                      _primaryButton(
                        context,
                        'Login',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _outlineButton(
                        context,
                        'Sign Up',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen(isLogin: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 18),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Sponsored by',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/ngo3.png', height: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "SOS Children's Villages",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: sponsorBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _outlineButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: mainGreen,
          side: const BorderSide(color: mainGreen, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
