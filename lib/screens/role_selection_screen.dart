import 'package:flutter/material.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/screens/admin_signup_screen.dart';
import 'package:wastenot/screens/donor_signup_screen.dart';
import 'package:wastenot/screens/ngo_signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {

  final bool isLogin;

  const RoleSelectionScreen({super.key, required this.isLogin});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {

  String selectedRole = "";

  static const Color mainGreen = Color(0xFF0B4B3F);
  static const Color sponsorBlue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {

    final bool isEnabled = selectedRole.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      body: SafeArea(
        child: Column(
          children: [

            /// MAIN CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 36),

                    const Text(
                      "Select Your Role",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Choose how you'd like to help today",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _roleCard(
                      title: "Donor",
                      description: "Donate surplus food",
                      icon: Icons.volunteer_activism,
                    ),

                    const SizedBox(height: 20),

                    _roleCard(
                      title: "NGO",
                      description: "Receive & distribute food",
                      icon: Icons.apartment,
                    ),

                    const SizedBox(height: 20),

                    _roleCard(
                      title: "Admin",
                      description: "Manage system & alerts",
                      icon: Icons.admin_panel_settings,
                    ),

                    const SizedBox(height: 60),

                    /// CONTINUE BUTTON
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 52,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEnabled
                                ? mainGreen
                                : Colors.grey.shade300,

                            foregroundColor: isEnabled
                                ? Colors.white
                                : Colors.black54,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),

                          onPressed: isEnabled ? _continue : null,

                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            /// SPONSORED
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),

              child: Column(
                mainAxisSize: MainAxisSize.min,
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

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Image.asset(
                        'assets/images/ngo3.png',
                        height: 22,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        "SOS Children’s Villages",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    );
  }

  /// CONTINUE BUTTON LOGIC
  void _continue() {

    /// LOGIN FLOW
    if(widget.isLogin){

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: RouteSettings(arguments: selectedRole),
        ),
      );

    }

    /// SIGNUP FLOW
    else{

      if(selectedRole == "Admin"){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SignUpScreen(),
          ),
        );

      }

      else if(selectedRole == "Donor"){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DonorSignupScreen(),
          ),
        );

      }

      else if(selectedRole == "NGO"){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NgoSignUpScreen(),
          ),
        );

      }

    }
  }

  /// ROLE CARD
  Widget _roleCard({
    required String title,
    required String description,
    required IconData icon,
  }) {

    final bool isSelected = selectedRole == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = title;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: isSelected
              ? mainGreen.withOpacity(0.08)
              : Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? mainGreen
                : Colors.grey.shade300,

            width: 1.4,
          ),
        ),

        child: Row(
          children: [

            CircleAvatar(
              radius: 26,

              backgroundColor: isSelected
                  ? mainGreen
                  : mainGreen.withOpacity(0.15),

              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : mainGreen,
              ),
            ),

            const SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}