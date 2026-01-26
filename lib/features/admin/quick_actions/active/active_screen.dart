import 'package:flutter/material.dart';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  final activeItems = [
    {
      "title": "Donation Pickup",
      "subtitle": "Javson Hotel → Khair Foundation",
      "status": "In Progress",
      "time": "12 mins ago",
    },
    {
      "title": "Concern Review",
      "subtitle": "Food delay reported in Gulberg",
      "status": "Pending",
      "time": "25 mins ago",
    },
    {
      "title": "NGO Delivery",
      "subtitle": "Edhi Foundation — 120 meals",
      "status": "In Transit",
      "time": "40 mins ago",
    },
    {
      "title": "Staff Assignment",
      "subtitle": "Assign driver to Sunrise Bakery",
      "status": "Pending",
      "time": "1 hr ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        title: const Text("Active Operations", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeItems.length,
        itemBuilder: (context, i) => _activeCard(activeItems[i]),
      ),
    );
  }

  Widget _activeCard(Map item) {
    final Color statusColor = item['status'] == "In Progress"
        ? Colors.blue
        : item['status'] == "In Transit"
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['title'],
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(item['subtitle'], style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 6),
          Text(item['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
