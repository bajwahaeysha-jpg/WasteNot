import 'package:flutter/material.dart';

import 'personal_information_screen.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: Row(
          children: const [
            Text(
              'Account',
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(width: 8),
            Icon(Icons.person),
          ],
        ),
         iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [

          const SizedBox(height: 20),

          _tile(context, Icons.person_outline, "Personal Information", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
            );
          }),

          _tile(context, Icons.lock_outline, "Change Password", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }),

          const Divider(height: 40),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => const _DeleteAccountSheet(),
            ),
          ),
        ]),
      ),
    );
  }

  static Widget _tile(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DeleteAccountSheet extends StatelessWidget {
  const _DeleteAccountSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(
          children: [
            const Text("Delete Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          "You will permanently lose access to your admin account and all associated data. "
          "This action cannot be undone.",
          style: TextStyle(color: Colors.black54),
        ),

        const SizedBox(height: 24),

        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () {
            
          },
          child: const Text("Yes, delete my account",
              style: TextStyle(color: Colors.red)),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ]),
    );
  }
}
