import 'package:flutter/material.dart';
import 'widgets/smart_insights.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  String selectedRange = "Month";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Analytics",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// ✅ OVERVIEW CARDS WITH ICONS
            Row(
              children: const [

                _StatCard(
                  title: "Donations",
                  value: "1.0k",
                  icon: Icons.volunteer_activism,
                ),

                SizedBox(width: 12),

                _StatCard(
                  title: "Meals Served",
                  value: "1,351",
                  icon: Icons.restaurant,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [

                _StatCard(
                  title: "Active NGOs",
                  value: "120",
                  icon: Icons.groups,
                ),

                SizedBox(width: 12),

                _StatCard(
                  title: "Pending Requests",
                  value: "34",
                  icon: Icons.pending_actions,
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ✅ PERFORMANCE HEADER
            const Text(
              "Performance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            /// ✅ PERFORMANCE (SCREENSHOT STYLE)
            Row(
              children: const [

                _PerformanceCard(
                  title: "Meals",
                  value: "1240",
                ),

                SizedBox(width: 10),

                _PerformanceCard(
                  title: "Success",
                  value: "92%",
                ),

                SizedBox(width: 10),

                _PerformanceCard(
  title: "Coverage",
  value: "86%",
),
              ],
            ),

            const SizedBox(height: 24),

            /// ✅ SMART INSIGHTS (LAST)
            SmartInsights(range: selectedRange),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////
/// ⭐ COMPACT OVERVIEW CARD (SMALL SIZE)
////////////////////////////////////////////////////

class _StatCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(

        /// ✅ SMALL HEIGHT FEEL
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0,2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [

            /// ICON TOP RIGHT
            Row(
              children: [

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),

                Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF0F5F54),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// VALUE
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////
/// ⭐ PERFORMANCE CARD (SCREENSHOT STYLE)
////////////////////////////////////////////////////

class _PerformanceCard extends StatelessWidget {

  final String title;
  final String value;

  const _PerformanceCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(

        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),

        decoration: BoxDecoration(

          /// ✅ GREEN COLOR
          color: const Color(0xFF0F5F54),

          borderRadius: BorderRadius.circular(14),

          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0,3),
            )
          ],
        ),

        child: Column(

          children: [

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,

                /// WHITE TEXT
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}