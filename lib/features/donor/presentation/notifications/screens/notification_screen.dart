import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {

  static const Color mainGreen = Color(0xFF0E5E53);

  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          _notificationTile(
            Icons.check_circle,
            Colors.green,
            "Donation Accepted",
            "You have accepted 100 cooked meals from Cafe Aroma.",
            "10 minutes ago",
          ),

          const SizedBox(height: 10),

          _notificationTile(
            Icons.notifications,
            Colors.blue,
            "New Donation Available",
            "Fresh bread packets are available in Sector 11.",
            "1 hour ago",
          ),

          const SizedBox(height: 10),

          _notificationTile(
            Icons.warning_amber_rounded,
            Colors.orange,
            "Urgent Need Alert",
            "Food demand increased due to flood emergency.",
            "Yesterday",
          ),
        ],
      ),
    );
  }

  Widget _notificationTile(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
  ) {

    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(

        children: [

          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}