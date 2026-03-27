import 'package:flutter/material.dart';

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    super.key,
    required this.achievedCount,
    required this.target,
    required this.isLoading,
    required this.unitLabel,
    this.title = 'Monthly Goal',
  });

  final int achievedCount;
  final int target;
  final bool isLoading;
  final String unitLabel;
  final String title;

  bool get _hasGoal => target > 0;

  @override
  Widget build(BuildContext context) {
    final progress =
        _hasGoal ? (achievedCount / target).clamp(0.0, 1.0) : 0.0;

    final percentage =
        _hasGoal ? ((achievedCount / target) * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage('assets/images/home1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          /// 🔹 Progress Bar (upar hi rahegi)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.yellow,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 Bottom Text
          if (_hasGoal) ...[
            Text(
              '$achievedCount / $target $unitLabel  $percentage% completed',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ] else ...[
            if (isLoading) ...[
              const Text(
                'Loading current month goal...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
            ],
            const Text(
              'No goal set for this month',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set your goal from the More section',
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],

          /// ✅ EXTRA SPACE (neeche)
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}