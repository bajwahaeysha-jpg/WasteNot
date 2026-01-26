import 'package:flutter/material.dart';

class DonorNotificationsScreen extends StatelessWidget {
  const DonorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Notifications & Reminders",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text("Donation Alerts"),
            subtitle: const Text("Get notified when an NGO accepts your donation"),
          ),

          const Divider(),

          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text("Reminders"),
            subtitle: const Text("Receive reminders for upcoming donations"),
          ),

          const Divider(),

          SwitchListTile(
            value: false,
            onChanged: (v) {},
            title: const Text("Promotional Updates"),
            subtitle: const Text("Receive news & updates from WasteNot"),
          ),

        ]),
      ),
    );
  }
}
