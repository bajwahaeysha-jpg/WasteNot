import 'package:flutter/material.dart';

class DonorPrivacyScreen extends StatefulWidget {
  const DonorPrivacyScreen({super.key});

  @override
  State<DonorPrivacyScreen> createState() => _DonorPrivacyScreenState();
}

class _DonorPrivacyScreenState extends State<DonorPrivacyScreen> {

  bool allowMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5D4E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Privacy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),

            title: const Text(
              "Allow direct messages",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Let donors contact your organization directly through the app",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            trailing: Switch(
              value: allowMessages,
              inactiveThumbColor: Colors.white,
              activeTrackColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() {
                  allowMessages = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}