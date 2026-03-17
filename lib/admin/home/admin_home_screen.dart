import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:wastenot/features/admin/home/components/header.dart';
import 'components/stats_section.dart';
import 'package:wastenot/features/admin/home/components/quick_actions_section.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Header(
            user: widget.user,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  StatsSection(),
                  SizedBox(height: 20),
                  QuickActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}