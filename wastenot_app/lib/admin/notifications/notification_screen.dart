import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 🔑 SHARED COLOR (FIX)
const Color mainGreen = Color(0xFF0F5F54);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// 🟢 APP BAR
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      /// 🔔 NOTIFICATIONS LIST
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationTile(
            icon: Icons.food_bank,
            title: "New donation received",
            subtitle: "5 minutes ago",
          ),
          _NotificationTile(
            icon: Icons.verified,
            title: "NGO approved",
            subtitle: "1 hour ago",
          ),
          _NotificationTile(
            icon: Icons.emoji_events,
            title: "Monthly goal reached",
            subtitle: "1 hour ago",
          ),
        ],
      ),
    );
  }
}

/// ───────────── NOTIFICATION TILE ─────────────

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔔 ICON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mainGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: mainGreen,
            ),
          ),

          const SizedBox(width: 12),

          /// 📝 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
