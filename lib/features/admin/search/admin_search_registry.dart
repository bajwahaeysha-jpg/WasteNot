import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/activity_log/activity_log_screen.dart';
import 'package:wastenot/features/admin/analytics/analytics_screen.dart';
import 'package:wastenot/features/admin/donations/all_donations_screen.dart';
import 'package:wastenot/features/admin/donors/all_donors_screen.dart';
import 'package:wastenot/features/admin/home/admin_home_screen.dart';
import 'package:wastenot/features/admin/meals/all_meals_screen.dart';
import 'package:wastenot/features/admin/more/feedback/admin_feedback_screen.dart';
import 'package:wastenot/features/admin/more/profile/admin_profile_screen.dart';
import 'package:wastenot/features/admin/more/settings/FAQ/faq_screen.dart';
import 'package:wastenot/features/admin/more/settings/Privacy_Policy/privacy_policy_screen.dart';
import 'package:wastenot/features/admin/more/settings/about/about_screen.dart';
import 'package:wastenot/features/admin/more/settings/accounts/account_screen.dart';
import 'package:wastenot/features/admin/more/settings/accounts/change_password_screen.dart';
import 'package:wastenot/features/admin/more/settings/accounts/personal_information_screen.dart';
import 'package:wastenot/features/admin/more/settings/contacts/contact_screen.dart';
import 'package:wastenot/features/admin/more/settings/notifications/notifications_screen.dart';
import 'package:wastenot/features/admin/more/settings/settings_screen.dart';
import 'package:wastenot/features/admin/ngos/all_ngos_screen.dart';
import 'package:wastenot/features/admin/quick_actions/active/admin_active_operations_screen.dart';
import 'package:wastenot/features/admin/quick_actions/concerns/concerns_screen.dart';
import 'package:wastenot/features/admin/quick_actions/coverage/coverage_screen.dart';
import 'package:wastenot/features/admin/quick_actions/requests/requests_screen.dart';

class AdminSearchItem {
  const AdminSearchItem({
    required this.title,
    required this.icon,
    required this.builder,
    this.keywords = const [],
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
  final List<String> keywords;
}

List<AdminSearchItem> buildAdminSearchItems(Map<String, dynamic> user) {
  return [
    AdminSearchItem(
      title: 'Home',
      icon: Icons.home_outlined,
      builder: (_) => AdminHomeScreen(user: user),
      keywords: const ['dashboard', 'admin home'],
    ),
    AdminSearchItem(
      title: 'Analytics',
      icon: Icons.analytics_outlined,
      builder: (_) => const AnalyticsScreen(),
      keywords: const ['analysis', 'stats', 'reports'],
    ),
    AdminSearchItem(
      title: 'Activity Log',
      icon: Icons.notifications_active_outlined,
      builder: (_) => const ActivityLogScreen(),
      keywords: const ['notifications', 'recent activity'],
    ),
    AdminSearchItem(
      title: 'All Donors',
      icon: Icons.people_outline,
      builder: (_) => const AllDonorsScreen(),
      keywords: const ['donor', 'users'],
    ),
    AdminSearchItem(
      title: 'All NGOs',
      icon: Icons.apartment_outlined,
      builder: (_) => const AllNGOsScreen(),
      keywords: const ['ngo', 'organizations'],
    ),
    AdminSearchItem(
      title: 'All Donations',
      icon: Icons.inventory_2_outlined,
      builder: (_) => const AllDonationsScreen(),
      keywords: const ['donation', 'food'],
    ),
    AdminSearchItem(
      title: 'Impact',
      icon: Icons.volunteer_activism_outlined,
      builder: (_) => const AllMealsScreen(),
      keywords: const ['meals', 'impact', 'saved'],
    ),
    AdminSearchItem(
      title: 'Concerns',
      icon: Icons.warning_amber_rounded,
      builder: (_) => const ConcernsScreen(),
      keywords: const ['complaints', 'issues'],
    ),
    AdminSearchItem(
      title: 'Feedback',
      icon: Icons.feedback_outlined,
      builder: (_) => const AdminFeedbackScreen(),
      keywords: const ['reviews', 'ratings'],
    ),
    AdminSearchItem(
      title: 'Active Operations',
      icon: Icons.track_changes_outlined,
      builder: (_) => const ActiveScreen(),
      keywords: const ['active', 'operations'],
    ),
    AdminSearchItem(
      title: 'Requests',
      icon: Icons.request_page_outlined,
      builder: (_) => const RequestsScreen(),
      keywords: const ['pending', 'approvals'],
    ),
    AdminSearchItem(
      title: 'Coverage',
      icon: Icons.map_outlined,
      builder: (_) => const CoverageScreen(),
      keywords: const ['areas', 'coverage map'],
    ),
    AdminSearchItem(
      title: 'Profile',
      icon: Icons.person_outline,
      builder: (_) => AdminProfileScreen(user: user),
      keywords: const ['admin profile', 'account'],
    ),
    AdminSearchItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      builder: (_) => SettingsScreen(user: user),
      keywords: const ['preferences', 'configuration'],
    ),
    AdminSearchItem(
      title: 'Account',
      icon: Icons.manage_accounts_outlined,
      builder: (_) => const AccountScreen(),
      keywords: const ['account settings'],
    ),
    AdminSearchItem(
      title: 'Personal Information',
      icon: Icons.badge_outlined,
      builder: (_) => const PersonalInformationScreen(),
      keywords: const ['profile details', 'personal info'],
    ),
    AdminSearchItem(
      title: 'Change Password',
      icon: Icons.lock_outline,
      builder: (_) => const ChangePasswordScreen(),
      keywords: const ['password', 'security'],
    ),
    AdminSearchItem(
      title: 'Notifications',
      icon: Icons.notifications_none,
      builder: (_) => const NotificationsScreen(),
      keywords: const ['alerts', 'reminders'],
    ),
    AdminSearchItem(
      title: 'Contact Us',
      icon: Icons.mail_outline,
      builder: (_) => const ContactScreen(),
      keywords: const ['contact', 'support'],
    ),
    AdminSearchItem(
      title: 'About App',
      icon: Icons.info_outline,
      builder: (_) => const AboutScreen(),
      keywords: const ['about', 'application'],
    ),
    AdminSearchItem(
      title: 'FAQ',
      icon: Icons.help_outline,
      builder: (_) => const FaqScreen(),
      keywords: const ['questions', 'help'],
    ),
    AdminSearchItem(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      builder: (_) => const PrivacyPolicyScreen(),
      keywords: const ['privacy', 'policy'],
    ),
  ];
}
