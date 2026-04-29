import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/change_password_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/personal_information_screen.dart';
import 'package:wastenot/screens/welcome_screen.dart';
import 'package:wastenot/services/account_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: const [
            Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white),
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _tile(context, Icons.person_outline, 'Personal information', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
              );
            }),
            _tile(context, Icons.lock_outline, 'Change password', () {
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
                'Delete account',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tile(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'This permanently deletes your account. Historical donations, feedback, concerns, and logs stay preserved in an archived detached state and will no longer be linked to you.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed || !context.mounted) {
    return;
  }

  // ✅ DEBUG PRINTS (IMPORTANT)
  print("PROJECT ID: ${Firebase.app().options.projectId}");
  print("UID: ${FirebaseAuth.instance.currentUser?.uid}");

  _showBlockingLoader(context);

  try {
    await AccountService().deleteAccount();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  } on AccountFailure catch (error) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message), backgroundColor: Colors.red),
    );
  }
}

  void _showBlockingLoader(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
