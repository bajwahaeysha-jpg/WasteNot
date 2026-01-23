import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {

  bool profileVisibility = true;
  bool activityStatus = true;
  bool dataSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
    
        title: const Text("Privacy",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [

          const SizedBox(height: 20),

          _toggleTile(
            "Profile Visibility",
            profileVisibility,
            "Allow others to view your profile",
            (val) => setState(() => profileVisibility = val),
          ),

          _toggleTile(
            "Activity Status",
            activityStatus,
            "Show when you're active",
            (val) => setState(() => activityStatus = val),
          ),

          _toggleTile(
            "Data Sharing",
            dataSharing,
            "Allow data sharing for improvements",
            (val) => setState(() => dataSharing = val),
          ),
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
