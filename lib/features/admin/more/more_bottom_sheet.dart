import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/auth_service.dart';
import 'feedback/admin_feedback_screen.dart';
import 'profile/admin_profile_screen.dart';
import 'settings/settings_screen.dart';

class AdminMoreSheet extends StatelessWidget {

  final Map<String, dynamic> user;

  const AdminMoreSheet({
    super.key,
    required this.user,
  });

  static const Color mainGreen = Color(0xFF0F5F54);
  static final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _item(
              context,
              Icons.person_outline,
              "Profile",
              AdminProfileScreen(user: user),
            ),

            _item(
              context,
              Icons.settings_outlined,
              "Settings",
              SettingsScreen(user: user)
            ),
            _item(
  context,
  Icons.feedback_outlined,
  "Feedback",
  const AdminFeedbackScreen(),
),

            const Divider(),

            /// LOGOUT
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),

              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: mainGreen),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      onTap: () {

        Navigator.of(context).pop();

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          title: const Text("Log Out"),

          content: const Text(
            "Are you sure you want to log out?",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed: () async {
                await _authService.logout();
                if (!context.mounted) {
                  return;
                }
                AppNavigationHandler.goToLogin(context);
              },

              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }
}
