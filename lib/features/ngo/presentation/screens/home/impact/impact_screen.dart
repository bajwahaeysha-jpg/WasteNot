import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Impact", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const Text("Good Morning", style: TextStyle(color: Colors.black)),
          const SizedBox(height: 4),
          const Text("Khair Foundation",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),

          const SizedBox(height: 18),

          const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            children: const [
              _SummaryCard("Accepted", "96", Icons.check_circle, Color(0xFFE6F4EA)),
              _SummaryCard("Meals", "164", Icons.restaurant, Color(0xFFEAF1FB)),
              _SummaryCard("People", "1420", Icons.people, Color(0xFFFFF1E6)),
              _SummaryCard("Locations", "42", Icons.location_on, Color(0xFFEFE9FB)),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: const [
              Icon(Icons.store, color: primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "You helped 21 restaurants prevent food waste this month.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(children: [
              Row(children: const [
                CircleAvatar(backgroundColor: primary, child: Icon(Icons.directions_run, color: Colors.white)),
                SizedBox(width: 10),
                Text("Activity", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16),
              ]),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Accepted donations — last 5 months", style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 150, child: _ActivityGraph()),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Average: 9 donations per month", style: TextStyle(color: Colors.black)),
              ),
            ]),
          ),

          const SizedBox(height: 26),

          const Text("Beneficiaries", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 6),
          const Text("People who you benefited through your work",
              style: TextStyle(color: Colors.black)),
          const SizedBox(height: 16),

          Center(
            child: SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: 70,
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(value: 80, color: Colors.blue, radius: 18),
                        PieChartSectionData(value: 10, color: Colors.red, radius: 18),
                        PieChartSectionData(value: 10, color: Colors.orange, radius: 18),
                      ],
                    ),
                  ),
                  const Text("100%",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LegendRow(Colors.blue, "Orphans — 80%"),
                _LegendRow(Colors.red, "Homeless — 10%"),
                _LegendRow(Colors.orange, "Others — 10%"),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendRow(this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.black)),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 14, backgroundColor: color, child: Icon(icon, size: 14, color: Colors.black)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        ]),
      ]),
    );
  }
}

class _ActivityGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              const m = ["Jan", "Feb", "Mar", "Apr", "May"];
              return Text(m[v.toInt()], style: const TextStyle(color: Colors.black));
            }),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          _bar(0, 4),
          _bar(1, 7),
          _bar(2, 5),
          _bar(3, 9),
          _bar(4, 12),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, width: 14, color: ImpactScreen.primary, borderRadius: BorderRadius.circular(6)),
    ]);
  }
}
