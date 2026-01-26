import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/alert/alert_model.dart';

class AlertDetailsScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Alert Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔔 TITLE
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              /// 📝 DESCRIPTION
              Text(
                alert.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 12),

              /// 📅 CREATED DATE
              _infoRow(
                icon: Icons.calendar_today,
                label: "Created",
                value: _formatDate(alert.createdAt),
              ),

              const SizedBox(height: 10),

              /// 📌 STATUS
              _statusRow(alert.isResolved),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── INFO ROW ─────────────

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── STATUS ROW ─────────────

  Widget _statusRow(bool resolved) {
    final Color color = resolved ? Colors.green : Colors.orange;

    return Row(
      children: [
        Icon(
          resolved ? Icons.check_circle : Icons.pending,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          "Status:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            resolved ? "Resolved" : "Pending",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── DATE FORMAT ─────────────

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
