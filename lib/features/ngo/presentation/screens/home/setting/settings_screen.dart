import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/goal/ngo_goal_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/about_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/account_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/contact_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/faq_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/notifications_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/privacy_policy_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/privacy_screen.dart';
import 'package:wastenot/screens/welcome_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/session_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        final profileImageUrl = user?.profileImageUrl;

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
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF0F4C45),
                      backgroundImage: profileImageUrl != null &&
                              profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? Text(
                              SessionService.initials(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'NGO',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _tile(context, Icons.person_outline, 'Account', const AccountScreen()),
                _tile(
                  context,
                  Icons.notifications_none,
                  'Notifications & Reminders',
                  const NotificationsScreen(),
                ),
                _tile(context, Icons.lock_outline, 'Privacy', const PrivacyScreen()),
                _tile(context, Icons.mail_outline, 'Contact Us', const ContactScreen()),
                _tile(context, Icons.info_outline, 'About App', const AboutScreen()),
                _tile(context, Icons.help_outline, 'FAQ', const FaqScreen()),
                _tile(context, Icons.flag_outlined, 'Set Monthly Goal', const NgoGoalScreen()),
                _tile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  const PrivacyPolicyScreen(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, Widget screen) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out from your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) {
      return;
    }

    await AuthService().signOut();
    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}
