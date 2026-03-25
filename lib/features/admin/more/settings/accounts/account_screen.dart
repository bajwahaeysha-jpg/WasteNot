import 'package:flutter/material.dart';
import 'personal_information_screen.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: const [
            Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [

          const SizedBox(height: 20),

          _tile(context, Icons.person_outline, "Personal information", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
            );
          }),

          _tile(context, Icons.lock_outline, "Change password", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }),
        ]),
      ),
    );
  }

  static Widget _tile(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
