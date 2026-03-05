import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'send_notification_screen.dart';
import 'suspend_donor_screen.dart';
import 'package:wastenot/features/admin/activity_log/activity_log_data.dart';

class DonorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> donor;

  const DonorProfileScreen({
    super.key,
    required this.donor,
  });

  static const primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.45;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Text(
          donor['name'] ?? "Donor",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [

          /// IMAGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                donor['logo'],
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// NAME + CALL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      donor['name'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          donor['location'],
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                /// CALL
                Row(
                  children: [

                    IconButton(
                      icon: const Icon(Icons.call, color: primary),
                      onPressed: () async {

                        final telUrl = 'tel:${donor['phone']}';

                        if (await canLaunchUrl(Uri.parse(telUrl))) {
                          await launchUrl(Uri.parse(telUrl));
                        }
                      },
                    ),

                  
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [

                _statBox("${donor['meals']}", "Meals"),

                const SizedBox(width: 10),

                _statBox("${donor['success']}%", "Success"),

                const SizedBox(width: 10),

                _statBox(donor['status'] ?? "Approved", "Status"),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// ABOUT
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "About",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _description(donor),
              style: const TextStyle(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// SEND NOTIFICATION
          ListTile(
            leading: const Icon(
              Icons.notifications,
              color: primary,
            ),
            title: const Text("Send Notification"),
            onTap: () async {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendNotificationScreen(),
                ),
              );

              if (result != null) {

                activityLogs.insert(0, {
                  "title": result['title'],
                  "message": result['message'],
                  "receiver": donor['name'],
                  "time": "Now"
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notification Sent")),
                );
              }
            },
          ),

          /// SUSPEND
          ListTile(
            leading: const Icon(
              Icons.block,
              color: Colors.red,
            ),
            title: const Text(
              "Suspend Donor",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuspendDonorScreen(donor: donor),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// STAT BOX
  Widget _statBox(String value, String label) {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          children: [

            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _description(Map<String, dynamic> donor) {
    return "This donor regularly contributes food to NGOs and helps reduce hunger in the community.";
  }
}