import 'package:flutter/material.dart';
import 'personal_information_screen.dart';
import 'change_password_screen.dart';
import 'package:wastenot/screens/login_screen.dart';

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

          const Divider(height: 40),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text(
              "Delete account",
              style: TextStyle(fontSize: 16, color: Colors.red),
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
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DeleteAccountSheet extends StatelessWidget {
  const _DeleteAccountSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            children: [
              const Text(
                "Delete account",
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
            "You will lose access to all your data and donation history. "
            "This action can’t be undone. Are you sure you want to delete your account?",
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 28),

          /// Delete Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {

                Navigator.pop(context);

                /// bottom message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Account deleted successfully"),
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF0F4C45),
                  ),
                );

                /// after 1 sec go to login
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                });
              },
              child: const Text(
                "Yes, delete my account",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Cancel Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}