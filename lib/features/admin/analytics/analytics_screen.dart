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

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
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

            /// OVERVIEW
            Text(
              "Overview",
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

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

            const SizedBox(height: 26),

            /// PERFORMANCE
            Text(
              "Performance",
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

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

            const SizedBox(height: 26),

            /// SMART INSIGHTS
            SmartInsights(range: selectedRange),
          ],
        ),
      ),
    );
  }
}

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

  static const mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(

        padding: EdgeInsets.symmetric(
          horizontal: width * 0.035,
          vertical: width * 0.04,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:.05),
              blurRadius: 8,
              offset: const Offset(0,3),
            )
          ],
        ),

        child: Stack(
          children: [

            /// ICON TOP RIGHT
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: mainGreen.withValues(alpha:.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: width * 0.05,
                  color: mainGreen,
                ),
              ),
            ),

            /// CONTENT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 6),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

    final width = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(

        padding: EdgeInsets.symmetric(
          vertical: width * 0.05,
          horizontal: width * 0.03,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:.04),
              blurRadius: 6,
              offset: const Offset(0,2),
            )
          ],
        ),

        child: Column(
          children: [

            Text(
              value,
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F5F54),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}