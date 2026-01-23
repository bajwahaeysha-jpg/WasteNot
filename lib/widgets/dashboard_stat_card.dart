import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isUp;
  final IconData icon;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isUp,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🧠 prevents overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title + Icon
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: iconColor.withValues(alpha:.15),
                child: Icon(icon, size: 16, color: iconColor),
              )
            ],
          ),

          const SizedBox(height: 6),

          /// Value
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          /// Change Indicator
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isUp ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$change vs last 7 days",
                  style: TextStyle(
                    fontSize: 12,
                    color: isUp ? Colors.green : Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
