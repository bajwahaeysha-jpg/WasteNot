import 'package:flutter/material.dart';

class DonorNotificationsScreen extends StatefulWidget {
  const DonorNotificationsScreen({super.key});

  @override
  State<DonorNotificationsScreen> createState() =>
      _DonorNotificationsScreenState();
}

class _DonorNotificationsScreenState extends State<DonorNotificationsScreen> {

  bool notifications = true;
  bool reminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5D4E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications & Reminders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Notifications Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                subtitle: const Text(
                  "Receive updates about donations and activity",
                  style: TextStyle(color: Colors.grey),
                ),

                trailing: Switch(
                  value: notifications,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.deepPurple,
                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminders Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                title: const Text(
                  "Reminders",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                subtitle: const Text(
                  "Get reminders for scheduled pickups and tasks",
                  style: TextStyle(color: Colors.grey),
                ),

                trailing: Switch(
                  value: reminders,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.deepPurple,
                  onChanged: (value) {
                    setState(() {
                      reminders = value;
                    });
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}