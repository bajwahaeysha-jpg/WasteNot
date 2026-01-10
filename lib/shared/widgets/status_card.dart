import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final int count;

  const StatusCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: AppColors.primary),
            const Spacer(),
            Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('$count',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
