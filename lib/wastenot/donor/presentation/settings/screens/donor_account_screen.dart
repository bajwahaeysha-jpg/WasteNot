import 'package:flutter/material.dart';
import 'donor_personal_information_screen.dart';
import 'donor_change_password_screen.dart';

class DonorAccountScreen extends StatelessWidget {
  const DonorAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [

          const SizedBox(height: 20),

          _tile(context, Icons.person_outline, "Personal Information", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DonorPersonalInformationScreen()),
            );
          }),

          _tile(context, Icons.lock_outline, "Change Password", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DonorChangePasswordScreen()),
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
