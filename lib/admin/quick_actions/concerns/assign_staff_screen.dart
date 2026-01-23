import 'package:flutter/material.dart';

class AssignStaffScreen extends StatelessWidget {
  const AssignStaffScreen({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    final staff = [
      "Ali (Field Officer)",
      "Sara (Supervisor)",
      "Ahmed (Logistics)",
      "Fatima (Coordinator)",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Assign Staff",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staff.length,
        itemBuilder: (_, i) => _staffTile(context, staff[i]),
      ),
    );
  }

  Widget _staffTile(BuildContext context, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: mainGreen,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pop(context, name),
      ),
    );
  }
}
