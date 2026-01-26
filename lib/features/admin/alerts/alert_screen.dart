import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'alert_details_screen.dart';
import '../models/alert/alert_model.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        "title": "Urgent food request pending",
        "subtitle": "2 donor requests need approval",
        "urgent": true,
      },
      {
        "title": "Pickup scheduled soon",
        "subtitle": "Driver arriving in 30 minutes",
        "urgent": false,
      },
      {
        "title": "Weekly report ready",
        "subtitle": "View your impact summary",
        "urgent": false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Alerts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (_, index) {
  final a = alerts[index];

  return _alertCard(
    context: context,
    title: a['title'] as String,
    subtitle: a['subtitle'] as String,
    urgent: a['urgent'] as bool,
  );
},
      ),
    );
  }

  // ───────────── ALERT CARD ─────────────

  Widget _alertCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool urgent,
  }) {
    final Color iconColor = urgent ? Colors.orange : mainGreen;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        /// ✅ CREATE DUMMY ALERT MODEL
        final alert = AlertModel(
          title: title,
          description: subtitle,
          createdAt: DateTime.now(),
          isResolved: !urgent,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlertDetailsScreen(alert: alert),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: urgent ? const Color(0xFFFFF1E5) : Colors.white,
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
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                urgent
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_active_outlined,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
