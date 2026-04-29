import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';

import '../../../../services/auth_service.dart';
import 'FAQ/faq_screen.dart';
import 'Privacy_Policy/privacy_policy_screen.dart';
import 'about/about_screen.dart';
import 'accounts/account_screen.dart';
import 'contacts/contact_screen.dart';
import 'notifications/notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const SettingsScreen({
    super.key,
    required this.user,
  });

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    File? profileImage;

    if (user['image'] != null) {
      profileImage = File(user['image']);
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B4B3F),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: mainGreen,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage) : null,
                    child: profileImage == null
                        ? Text(
                            (user['name'] ?? "A")[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user['email'] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _tile(
                context,
                Icons.person_outline,
                "Account",
                const AccountScreen(),
              ),
              _tile(
                context,
                Icons.notifications_none,
                "Notifications & Reminders",
                const NotificationsScreen(),
              ),
              _tile(
                context,
                Icons.mail_outline,
                "Contact Us",
                const ContactScreen(),
              ),
              _tile(
                context,
                Icons.info_outline,
                "About App",
                const AboutScreen(),
              ),
              _tile(
                context,
                Icons.help_outline,
                "FAQ",
                const FaqScreen(),
              ),
              _tile(
                context,
                Icons.privacy_tip_outlined,
                "Privacy Policy",
                const PrivacyPolicyScreen(),
              ),
              const Spacer(),
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
                onTap: () => _confirmLogout(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
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
                    const Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Are you sure you want to log out from your account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4B3F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
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
        ) ??
        false;

    if (!confirmed || !context.mounted) {
      return;
    }

    await _logout(context);
  }

  static Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) {
      return;
    }

    await AppNavigationHandler.goToWelcome(context);
  }
}
