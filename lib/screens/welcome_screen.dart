import 'package:flutter/material.dart';
import '../../screens/role_selection_screen.dart';
import 'login_screen.dart';

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
            colors: [
              Color(0xFFF5FBF9),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// CENTER CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// LOGO
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: mainGreen.withValues(alpha: 0.06),
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
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Donate & Share. Make a difference today.\nBecause every meal matters.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 42),

                      /// LOGIN BUTTON
                      _primaryButton(
                        context,
                        "Login",
                        () => _goToLogin(context),
                      ),

                      const SizedBox(height: 14),

                      /// SIGNUP BUTTON
                      _outlineButton(
                        context,
                        "Sign Up",
                        () => _goToRoleSelection(context),
                      ),
                    ],
                  ),
                ),
              ),

              /// SPONSORED SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 18),
                child: Column(
                  children: [

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Sponsored by",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/ngo3.png',
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "SOS Children’s Villages",
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

  /// PRIMARY BUTTON
  Widget _primaryButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// OUTLINE BUTTON
  Widget _outlineButton(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: mainGreen,
          side: const BorderSide(color: mainGreen, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// LOGIN NAVIGATION
  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  /// ROLE SELECTION FOR SIGNUP
  void _goToRoleSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      ),
    );
  }
}