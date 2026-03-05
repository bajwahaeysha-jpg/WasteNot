import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/activity_log/activity_log_data.dart';
import 'suspend_ngo_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class NGOProfileScreen extends StatelessWidget {
  final Map ngo;

  const NGOProfileScreen({super.key, required this.ngo});

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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          ngo['name'],
          style: const TextStyle(color: Colors.white),
        ),
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
                ngo['logo'],
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
                      ngo['name'],
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
                          ngo['location'],
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                /// CALL BUTTON
                IconButton(
                  icon: const Icon(Icons.call, color: primary),
                  onPressed: () async {

                    final telUrl = 'tel:${ngo['phone']}';

                    if (await canLaunchUrl(Uri.parse(telUrl))) {
                      await launchUrl(Uri.parse(telUrl));
                    }
                  },
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

                _statBox(
                  ngo['mealsReceived'].toString(),
                  "Meals",
                ),

                const SizedBox(width: 10),

                _statBox(
                  "${ngo['successRate']}%",
                  "Success",
                ),

                const SizedBox(width: 10),

                _statBox(
                  ngo['status'],
                  "Status",
                ),
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "This NGO is dedicated to supporting underprivileged communities by ensuring fair and timely distribution of donated food.",
              style: TextStyle(
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
            onTap: () => _showNotificationDialog(context),
          ),

          /// SUSPEND NGO
          ListTile(
            leading: const Icon(
              Icons.block,
              color: Colors.red,
            ),
            title: const Text(
              "Suspend NGO",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuspendNGOScreen(ngo: ngo),
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
  static Widget _statBox(String value, String label) {
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

  /// SEND NOTIFICATION DIALOG
  void _showNotificationDialog(BuildContext context) {

    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {

        return AlertDialog(

          title: const Text("Send Notification"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Message",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () {

                if (titleCtrl.text.isEmpty || msgCtrl.text.isEmpty) return;

                activityLogs.insert(0, {
                  "title": titleCtrl.text,
                  "message": msgCtrl.text,
                  "receiver": ngo['name'],
                  "type": "ngo",
                  "time": "Now"
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Notification sent to NGO"),
                  ),
                );
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }
}