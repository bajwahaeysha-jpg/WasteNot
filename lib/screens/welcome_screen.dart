import 'package:flutter/material.dart';
import '../../screens/role_selection_screen.dart';
import '../../screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);
  static const Color sponsorBlue = Color(0xFF1E88E5); // 🔵 SOS brand-like blue

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

              /// 🔝 CENTER CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// 🌱 Logo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mainGreen.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/welcome_logo.png',
                          width: 140,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainGreen,
                          letterSpacing: 0.3,
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

                      /// 🟢 Login Button
                      _primaryButton(
                        context,
                        "Login",
                        () => _goToRoleSelection(context),
                      ),

                      const SizedBox(height: 14),

                      /// ⚪ Sign Up Button
                      _outlineButton(
                        context,
                        "Sign Up",
                        () => _goToSignup(context),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔽 SPONSORED SECTION (LOGO + TEXT MATCHED)
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/ngo3.png',
                          height: 24, // ✅ matched with text height
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "SOS Children’s Villages",
                          style: TextStyle(
                            fontSize: 14, // ✅ visually same as logo
                            fontWeight: FontWeight.w700,
                            color: sponsorBlue, // 🔵 logo-style blue
                            letterSpacing: 0.3,
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

  // 🟢 PRIMARY BUTTON
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
          elevation: 2,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  // ⚪ OUTLINE BUTTON
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
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  // ➡️ LOGIN FLOW
  void _goToRoleSelection(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, _) => const RoleSelectionScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  // ➡️ SIGN UP FLOW
  void _goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpScreen(),
      ),
    );
  }
}
