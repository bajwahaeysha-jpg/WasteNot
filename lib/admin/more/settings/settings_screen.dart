import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/more/settings/accounts/account_screen.dart';
import 'package:wastenot/features/admin/more/settings/notifications/notifications_screen.dart';
import 'package:wastenot/features/admin/more/settings/contacts/contact_screen.dart';
import 'package:wastenot/features/admin/more/settings/about/about_screen.dart';
import 'package:wastenot/features/admin/more/settings/FAQ/faq_screen.dart';
import 'package:wastenot/features/admin/more/settings/Privacy_Policy/privacy_policy_screen.dart';
import '../../../../screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // ✅ MUST be true
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        /// 🔙 Always go back to Admin Home (root)
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F5F54),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Settings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 12),

              /// 🧑 PROFILE HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: mainGreen,
                    child: Text(
                      "AM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Allah Malik",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "donor@email.com",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _tile(context, Icons.person_outline, "Account", const AccountScreen()),
              _tile(
                context,
                Icons.notifications_none,
                "Notifications & Reminders",
                const NotificationsScreen(),
              ),
              _tile(context, Icons.mail_outline, "Contact Us", const ContactScreen()),
              _tile(context, Icons.info_outline, "About App", const AboutScreen()),
              _tile(context, Icons.help_outline, "FAQ", const FaqScreen()),
              _tile(
                context,
                Icons.privacy_tip_outlined,
                "Privacy Policy",
                const PrivacyPolicyScreen(),
              ),

              const Spacer(),

              /// 🚪 LOGOUT
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showLogoutSheet(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 REUSABLE TILE
  static Widget _tile(
    BuildContext context,
    IconData icon,
    String text,
    Widget screen,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  /// 🚪 LOGOUT SHEET
  static void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              children: [
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              "Are you sure you want to logout from your admin account?",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Yes, Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: mainGreen,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
