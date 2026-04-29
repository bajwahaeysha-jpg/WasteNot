import 'package:flutter/material.dart';

import 'feedback/admin_feedback_screen.dart';
import 'profile/admin_profile_screen.dart';
import 'settings/settings_screen.dart';

class AdminMoreSheet extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminMoreSheet({
    super.key,
    required this.user,
  });

  static const Color mainGreen = Color(0xFF0B4B3F);

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
              SettingsScreen(user: user),
            ),
            _item(
              context,
              Icons.feedback_outlined,
              "Feedback",
              const AdminFeedbackScreen(),
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
}
