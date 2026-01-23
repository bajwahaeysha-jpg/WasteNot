import 'package:flutter/material.dart';

import 'donor_account_screen.dart';
import 'donor_notifications_screen.dart';
import 'donor_privacy_screen.dart';
import 'donor_about_screen.dart';
import 'donor_faq_screen.dart';
import 'donor_contact_screen.dart';
import 'donor_rate_screen.dart';
import 'donor_privacy_policy_screen.dart';

class DonorSettingsScreen extends StatelessWidget {
  const DonorSettingsScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: [

          const SizedBox(height: 20),

          // 👤 Profile Header
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: mainGreen,
                child: Text(
                  "AM",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Allah Malik",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  Text(
                    "donor@email.com",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          _tile(context, Icons.person_outline, "Account",
              const DonorAccountScreen()),

          _tile(context, Icons.notifications_none, "Notifications & Reminders",
              const DonorNotificationsScreen()),

          _tile(context, Icons.lock_outline, "Privacy",
              const DonorPrivacyScreen()),

          _tile(context, Icons.star_outline, "Rate Us",
              const DonorRateScreen()),

          _tile(context, Icons.mail_outline, "Contact Us",
              const DonorContactScreen()),

          _tile(context, Icons.info_outline, "About App",
              const DonorAboutScreen()),

          _tile(context, Icons.help_outline, "FAQ",
              const DonorFaqScreen()),

          _tile(context, Icons.privacy_tip_outlined, "Privacy Policy",
              const DonorPrivacyPolicyScreen()),

          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Logout logic later
            },
          ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
