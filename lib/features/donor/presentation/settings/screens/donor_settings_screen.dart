import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_about_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_account_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_contact_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_faq_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_notifications_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_privacy_policy_screen.dart';
import 'package:wastenot/features/donor/presentation/settings/screens/donor_privacy_screen.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/session_service.dart';

class DonorSettingsScreen extends StatelessWidget {
  const DonorSettingsScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    final user = SessionService.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: mainGreen,
                  child: Text(
                    SessionService.initials(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Donor',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            _tile(context, Icons.person_outline, 'Account', const DonorAccountScreen()),
            _tile(context, Icons.notifications_none, 'Notifications & Reminders', const DonorNotificationsScreen()),
            _tile(context, Icons.lock_outline, 'Privacy', const DonorPrivacyScreen()),
            _tile(context, Icons.mail_outline, 'Contact Us', const DonorContactScreen()),
            _tile(context, Icons.info_outline, 'About App', const DonorAboutScreen()),
            _tile(context, Icons.help_outline, 'FAQ', const DonorFaqScreen()),
            _tile(context, Icons.privacy_tip_outlined, 'Privacy Policy', const DonorPrivacyPolicyScreen()),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _confirmLogout(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6F5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                "Log out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              const Text(
                "Are you sure you want to log out from your account?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /// CANCEL
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF0B4B3F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// LOGOUT BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4B3F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pop(dialogContext, true),
                    child: const Text(
                      "Log out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ) ?? false;

  if (!confirmed || !context.mounted) return;

  await AuthService().logout();

  if (!context.mounted) return;

  await AppNavigationHandler.goToWelcome(context);
}
}
