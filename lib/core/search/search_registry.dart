import 'package:flutter/material.dart';

// Home & Core
import '../../features/ngo/presentation/screens/home/impact/impact_screen.dart';
import '../../features/ngo/presentation/screens/inbox/messages_screen.dart';
import '../../features/ngo/presentation/screens/active/active_donations_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/settings_screen.dart';

// Settings sub-features
import '../../features/ngo/presentation/screens/home/setting/account/account_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/account/personal_information_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/account/change_password_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/notifications_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/privacy_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/contact_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/about_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/faq_screen.dart';
import '../../features/ngo/presentation/screens/home/setting/privacy_policy_screen.dart';

class SearchItem {
  final String title;
  final IconData icon;
  final Widget page;

  SearchItem(this.title, this.icon, this.page);
}

final List<SearchItem> globalSearchItems = [
  SearchItem("Settings", Icons.settings, const SettingsScreen()),
  SearchItem("Account", Icons.person, const AccountScreen()),
  SearchItem("Personal Information", Icons.badge, const PersonalInformationScreen()),
  SearchItem("Change Password", Icons.lock, const ChangePasswordScreen()),
  SearchItem("Notifications", Icons.notifications, const NotificationsScreen()),
  SearchItem("Privacy", Icons.security, const PrivacyScreen()),
  SearchItem("Contact Us", Icons.mail, const ContactScreen()),
  SearchItem("About App", Icons.info, const AboutScreen()),
  SearchItem("FAQ", Icons.help, const FaqScreen()),
  SearchItem("Privacy Policy", Icons.privacy_tip, const PrivacyPolicyScreen()),
  SearchItem("Impact", Icons.insights, const ImpactScreen()),
  SearchItem("Messages", Icons.message, MessagesScreen()),
  SearchItem("Active Donations", Icons.inventory, const ActiveDonationsScreen()),
];
