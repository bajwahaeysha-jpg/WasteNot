import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool allowDirectMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFF0F4C45),
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    "Privacy",
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Allow direct messages",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Let donors contact your organization directly through the app",
                            style: TextStyle(color: Colors.black),
                          ),
                        ]),
                  ),
                  Switch(
                    value: allowDirectMessages,
                    onChanged: (value) {
                      setState(() {
                        allowDirectMessages = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
