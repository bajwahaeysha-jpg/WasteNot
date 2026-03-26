import 'package:flutter/material.dart';

import '../../quick_actions/concerns/concerns_screen.dart';
import '../../quick_actions/active/admin_active_operations_screen.dart';
import '../../quick_actions/requests/requests_screen.dart';
import '../../more/feedback/admin_feedback_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    /// responsive sizes
    final iconSize = screenWidth * 0.065;
    final circleSize = screenWidth * 0.13;
    final textSize = screenWidth * 0.030;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TITLE
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 12),

        /// CARD
        Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              _QuickAction(
                icon: Icons.warning_amber_rounded,
                label: "Concerns",
                color: const Color(0xFF2E7D32),
                iconSize: iconSize,
                circleSize: circleSize,
                textSize: textSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConcernsScreen(),
                    ),
                  );
                },
              ),

              _QuickAction(
                icon: Icons.feedback_outlined,
                label: "Feedback",
                color: const Color(0xFFFBC02D),
                iconSize: iconSize,
                circleSize: circleSize,
                textSize: textSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminFeedbackScreen(),
                    ),
                  );
                },
              ),

              _QuickAction(
                icon: Icons.track_changes,
                label: "Active",
                color: Colors.black,
                iconSize: iconSize,
                circleSize: circleSize,
                textSize: textSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActiveScreen(),
                    ),
                  );
                },
              ),

              _QuickAction(
                icon: Icons.apps,
                label: "Requests",
                color: const Color(0xFFFFC107),
                iconSize: iconSize,
                circleSize: circleSize,
                textSize: textSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  final double iconSize;
  final double circleSize;
  final double textSize;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.iconSize,
    required this.circleSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onTap,
            splashColor: color.withValues(alpha:0.15),
            highlightColor: color.withValues(alpha:0.08),

            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha:0.15),
              ),

              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
