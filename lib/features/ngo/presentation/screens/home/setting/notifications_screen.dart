import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool notificationsEnabled = true;
  bool remindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFF0F4C45),
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    "Notifications & Reminders",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            _toggleTile(
              title: "Notifications",
              subtitle: "Receive updates about donations and activity",
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() => notificationsEnabled = val);
              },
            ),

            const SizedBox(height: 16),

            _toggleTile(
              title: "Reminders",
              subtitle: "Get reminders for scheduled pickups and tasks",
              value: remindersEnabled,
              onChanged: (val) {
                setState(() => remindersEnabled = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ]),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
