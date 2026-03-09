import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CoverageScreen extends StatelessWidget {
  const CoverageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coverageData = [
      {"area": "Johar Town", "percent": 45.0, "color": Colors.blue},
      {"area": "Cantt", "percent": 30.0, "color": Colors.green},
      {"area": "Gulberg", "percent": 15.0, "color": Colors.orange},
      {"area": "DHA", "percent": 10.0, "color": Colors.red},
    ];

    // Find highest and lowest coverage
    final highest = coverageData.reduce((a, b) =>
        (a["percent"] as double) > (b["percent"] as double) ? a : b);
    final lowest = coverageData.reduce((a, b) =>
        (a["percent"] as double) < (b["percent"] as double) ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        title: const Text(
          "Coverage Analytics",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Area-wise Coverage",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Donation distribution performance by area",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            /// PIE CHART
            Center(
              child: SizedBox(
                height: 280,
                width: 280,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    sections: coverageData.map((data) {
                      final double percent = (data["percent"] as double?) ?? 0;
                      return PieChartSectionData(
                        value: percent,
                        color: data["color"] as Color,
                        radius: 60,
                        title: "${data["area"]}\n${percent.toInt()}%",
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            /// HIGHEST & LOWEST COVERAGE
            const Text(
              "Highlights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _legendItem(
                  color: highest["color"] as Color,
                  area: highest["area"] as String,
                  percent: "${(highest["percent"] as double).toInt()}%",
                ),
                const SizedBox(height: 12),
                _legendItem(
                  color: lowest["color"] as Color,
                  area: lowest["area"] as String,
                  percent: "${(lowest["percent"] as double).toInt()}%",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String area,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              area,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            percent,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}