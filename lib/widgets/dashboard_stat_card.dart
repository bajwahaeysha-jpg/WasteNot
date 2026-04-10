import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool? isUp;
  final IconData icon;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.isUp,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasChange =
        change != null && change!.trim().isNotEmpty && isUp != null;

    return Container(
      padding: const EdgeInsets.all(14), // ðŸ”¥ thora bigger
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ðŸ” TOP ROW (ICON LEFT + VALUE RIGHT)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// ICON (LEFT)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),

              /// VALUE (RIGHT)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20, // ðŸ”¥ bigger number
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ðŸ”½ TITLE (BOTTOM)
          Text(
            title,
            style: const TextStyle(
              fontSize: 13, // ðŸ”¥ bigger text
              color: Colors.grey,
            ),
          ),

          /// ðŸ“ˆ CHANGE (optional)
          if (hasChange) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp! ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 13,
                  color: isUp! ? const Color(0xFF0B4B3F) : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  change!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUp! ? const Color(0xFF0B4B3F) : Colors.red,
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}