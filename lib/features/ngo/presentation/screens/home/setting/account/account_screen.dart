import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/change_password_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/personal_information_screen.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/account_service.dart';

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
        child: Column(
          children: [
            const SizedBox(height: 20),
            _tile(context, Icons.person_outline, 'Personal information', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationScreen(),
                ),
              );
            }),
            _tile(context, Icons.lock_outline, 'Change password', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
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

  static Widget _tile(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
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
              'This deletes your Firebase sign-in, but your Firestore history stays archived with a deleted status.',
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

    final currentPassword = await _askCurrentPassword(context);
    if ((currentPassword ?? '').trim().isEmpty || !context.mounted) {
      return;
    }

    _showBlockingLoader(context);

    try {
      await AccountService().deleteAccountWithPassword(
        currentPassword: currentPassword!,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      await AppNavigationHandler.goToLogin(context);
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

  Future<String?> _askCurrentPassword(BuildContext context) async {
    final controller = TextEditingController();
    var obscureText = true;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm password'),
              content: TextField(
                controller: controller,
                obscureText: obscureText,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => obscureText = !obscureText);
                    },
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  Navigator.pop(dialogContext, controller.text.trim());
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, controller.text.trim());
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
