import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'components/header.dart';
import 'components/stats_section.dart';
import 'components/quick_actions_section.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [

          /// 🔹 FIXED HEADER
          Header(user: widget.user),

          /// 🔹 SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.015,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔍 SEARCH BAR (NOW FIRST)
                    TextField(
                      onChanged: (_) {},
                      decoration: InputDecoration(
                        hintText: "Search donors, NGOs, donations...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 👤 USER NAME (NOW BELOW SEARCH)
                    Text(
                      (widget.user['name'] ?? "Admin")
                          .toString()
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 📊 ALERT + STATS
                    const StatsSection(),

                    const SizedBox(height: 20),

                    /// ⚡ QUICK ACTIONS
                    const QuickActionsSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
