import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {

  bool donationAlerts = true;
  bool systemUpdates = true;
  bool promotional = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
       
        title: const Text("Notifications & Reminders",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [

          const SizedBox(height: 20),

          _toggleTile("Donation Alerts", donationAlerts,
              "Receive alerts for new donations", (val) {
            setState(() => donationAlerts = val);
          }),

          _toggleTile("System Updates", systemUpdates,
              "App updates and maintenance alerts", (val) {
            setState(() => systemUpdates = val);
          }),

          _toggleTile("Promotional Notifications", promotional,
              "Offers and promotions", (val) {
            setState(() => promotional = val);
          }),
        ]),
      ),
    );
  }

  Widget _toggleTile(
    String title,
    bool value,
    String subtitle,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
