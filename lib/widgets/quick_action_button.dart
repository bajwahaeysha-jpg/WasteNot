import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.flash_on, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
