import 'package:flutter/material.dart';

class SmartInsights extends StatelessWidget {
  final String range;

  const SmartInsights({super.key, required this.range});

  List<String> _generateInsights() {
    if (range == "Week") {
      return [
        "🔥 Donations peaked on Thursday",
        "📦 Highest activity occurred between 4–6 PM",
        "📈 This week performed 12% better than last week",
      ];
    } else if (range == "Year") {
      return [
        "📊 Best month was September",
        "🚀 Annual growth increased by 28%",
        "🎯 Donation goal exceeded in Q3",
      ];
    } else {
      return [
        "📈 This month is outperforming the previous one",
        "🕒 Peak usage observed in the last 10 days",
        "💚 Engagement steadily increasing",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Container(
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

          /// 🧠 HEADER
          const Text(
            "Smart Insights",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 INSIGHTS LIST
          ...insights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5F54).withValues(alpha:0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Color(0xFF0F5F54),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
