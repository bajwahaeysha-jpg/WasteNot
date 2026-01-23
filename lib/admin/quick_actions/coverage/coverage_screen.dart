import 'package:flutter/material.dart';

class CoverageScreen extends StatelessWidget {
  const CoverageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = [
      {"area": "Johar Town", "coverage": 92, "status": "High"},
      {"area": "DHA Phase 5", "coverage": 76, "status": "Medium"},
      {"area": "Gulberg", "coverage": 58, "status": "Low"},
      {"area": "Model Town", "coverage": 85, "status": "High"},
      {"area": "Multan City", "coverage": 63, "status": "Medium"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        title: const Text("Coverage", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
       children: [
  _summaryCard(),
  const SizedBox(height: 16),

  ...zones.map((z) => _zoneCard(z)),
],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F5F54),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("System Coverage", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Cities: 12", style: TextStyle(color: Colors.white)),
          Text("Active Zones: 38", style: TextStyle(color: Colors.white)),
          Text("Coverage Efficiency: 81%", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _zoneCard(Map z) {
    Color statusColor;
    switch (z['status']) {
      case "High":
        statusColor = Colors.green;
        break;
      case "Medium":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(z['area'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: z['coverage'] / 100,
                  color: const Color(0xFF0F5F54),
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 8,
                ),
                const SizedBox(height: 6),
                Text("Coverage: ${z['coverage']}%"),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha:.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              z['status'],
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
