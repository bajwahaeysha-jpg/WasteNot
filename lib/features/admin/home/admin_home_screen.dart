import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../search/admin_global_search_screen.dart';
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

          /// 🔹 HEADER
          Header(user: widget.user),

          /// 🔹 CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.045,
                  vertical: size.height * 0.018,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔍 SEARCH BAR (ENHANCED)
                    TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminGlobalSearchScreen(user: widget.user),
                          ),
                        );
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search across admin panel...",
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 22),
                        suffixIcon: const Icon(Icons.tune, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 👤 USER NAME (BIGGER + STRONG)
                    Text(
                      (widget.user['name'] ?? "Admin")
                          .toString()
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24, // 🔥 bigger
                        fontWeight: FontWeight.w800, // 🔥 stronger
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /// ROLE
                    const Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 14, // 🔥 slightly bigger
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 📊 ALERT + STATS
                    const StatsSection(),

                    const SizedBox(height: 22),

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