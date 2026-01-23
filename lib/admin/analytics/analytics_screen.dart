import 'package:flutter/material.dart';
import 'widgets/smart_insights.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedRange = "Month";
  bool comparisonEnabled = false;

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
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 OVERVIEW CARDS
            Row(
              children: const [
                _StatCard(title: "Donations", value: "351.12k"),
                SizedBox(width: 12),
                _StatCard(title: "Meals Served", value: "1,351"),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _StatCard(title: "Active NGOs", value: "120"),
                SizedBox(width: 12),
                _StatCard(title: "Pending Requests", value: "34"),
              ],
            ),

            const SizedBox(height: 22),

            /// 🧠 SMART INSIGHTS
            SmartInsights(range: selectedRange),

            const SizedBox(height: 24),

            /// 📈 PERFORMANCE HEADER
            Row(
              children: const [
                Text(
                  "Performance",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
              ],
            ),

            const SizedBox(height: 14),

            /// 📊 PERFORMANCE TILES
            const _ProgressTile("Donation Growth", 0.845, "+24.5%"),
            const _ProgressTile("Meal Coverage", 0.86, "86%"),
            const _ProgressTile("NGO Engagement", 0.78, "78%"),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 🔹 SUMMARY STAT CARD
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 PROGRESS TILE
class _ProgressTile extends StatelessWidget {
  final String title;
  final double value;
  final String label;

  const _ProgressTile(this.title, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 TITLE + VALUE
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 PROGRESS BAR
          SizedBox(
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                color: const Color(0xFF0F5F54),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
