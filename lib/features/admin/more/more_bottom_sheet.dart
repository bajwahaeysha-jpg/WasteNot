import 'package:flutter/material.dart';

import 'profile/admin_profile_screen.dart';
import 'settings/settings_screen.dart';
import 'support/admin_support_screen.dart';

class AdminMoreSheet extends StatelessWidget {
  const AdminMoreSheet({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, Icons.person_outline, "Profile",
                const AdminProfileScreen()),
            _item(context, Icons.settings_outlined, "Settings",
                const SettingsScreen()),
            _item(context, Icons.support_agent_outlined, "Support",
                const AdminSupportScreen()),
          
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
        // 1️⃣ Close bottom sheet
        Navigator.of(context).pop();

        // 2️⃣ Open screen normally (NO async gap)
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}
