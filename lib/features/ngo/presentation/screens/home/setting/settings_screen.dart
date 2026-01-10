
import 'package:flutter/material.dart';
import 'package:wastenot/core/state/app_user.dart';

import 'account/account_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';
import 'faq_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_screen.dart';
import 'rate_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

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
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    AppUser.image != null ? FileImage(AppUser.image!) : null,
                child: AppUser.image == null
                    ? Text(AppUser.name.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppUser.name,
                      style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black)),
                  Text(AppUser.email,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          _tile(Icons.person_outline, "Account", const AccountScreen()),
          _tile(Icons.notifications_none, "Notifications & Reminders", const NotificationsScreen()),
          _tile(Icons.lock_outline, "Privacy", const PrivacyScreen()),
          _tile(Icons.star_outline, "Rate Us", const RateUsScreen()),
          _tile(Icons.mail_outline, "Contact Us", const ContactScreen()),
          _tile(Icons.info_outline, "About App", const AboutScreen()),
          _tile(Icons.help_outline, "FAQ", const FaqScreen()),
          _tile(Icons.privacy_tip_outlined, "Privacy Policy", const PrivacyPolicyScreen()),

          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Log out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        
                      },
                      child: const Text("Log out"),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _tile(IconData icon, String title, Widget page) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        setState(() {}); // 🔥 This is what makes everything update instantly
      },
    );
  }
}
