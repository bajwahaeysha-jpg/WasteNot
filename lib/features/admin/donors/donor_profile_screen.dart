import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wastenot/features/admin/messages/chat_screen.dart';
import 'notification_screen.dart';
import 'send_notification_screen.dart';
import 'suspend_donor_screen.dart';

class DonorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> donor;

  const DonorProfileScreen({
    super.key,
    required this.donor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        title: Text(
          donor['name'] ?? "Donor",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [

          // 🔹 TOP IMAGE
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(donor['logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 NAME + LOCATION + ACTIONS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // NAME & LOCATION
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          donor['location'],
                          style:
                              const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                // 📞 CALL + 💬 MESSAGE
                Row(
                  children: [

                    // CALL BUTTON
                    IconButton(
                      icon: const Icon(Icons.call,
                          color: Colors.green),
                      onPressed: () async {
                        final telUrl =
                            'tel:${donor['phone']}';
                        if (await canLaunchUrl(
                            Uri.parse(telUrl))) {
                          await launchUrl(
                              Uri.parse(telUrl));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Cannot open dialer")),
                          );
                        }
                      },
                    ),

                    // MESSAGE BUTTON → CHAT SCREEN
                    IconButton(
                      icon: const Icon(Icons.message,
                          color: Colors.teal),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              name: donor['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 STATS
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _coloredStatBox(
                    "${donor['meals']}",
                    "Meals",
                    Colors.blue),
                _coloredStatBox(
                    "${donor['success']}%",
                    "Success",
                    Colors.green),
                _coloredStatBox(
                    donor['status'] ?? "Approved",
                    "Status",
                    Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 ABOUT SECTION
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "About",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _description(donor),
              style: const TextStyle(
                  color: Colors.black87,
                  height: 1.5),
            ),
          ),

          const SizedBox(height: 30),

          // 🔔 SEND NOTIFICATION
          ListTile(
            leading: const Icon(Icons.notifications,
                color: Colors.green),
            title: const Text("Send Notification"),
            onTap: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SendNotificationScreen(),
                ),
              );

              if (!context.mounted) return;

              if (result != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificationScreen(
                            newNotification: result),
                  ),
                );
              }
            },
          ),

          // 🚫 SUSPEND DONOR
          ListTile(
            leading:
                const Icon(Icons.block, color: Colors.red),
            title: const Text(
              "Suspend Donor",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SuspendDonorScreen(
                          donor: donor),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔹 COLORED STAT BOX
  Widget _coloredStatBox(
      String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 4),
        padding:
            const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  static String _description(
      Map<String, dynamic> donor) {
    return "This donor regularly contributes food to NGOs and helps reduce hunger in the community.";
  }
}