import 'package:flutter/material.dart';

class DonorPrivacyPolicyScreen extends StatelessWidget {
  const DonorPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Privacy Policy",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "We respect your privacy. Your personal data is never shared "
          "with third parties. All information is securely stored and "
          "used only for improving your experience with WasteNot.",
          style: TextStyle(height: 1.4),
        ),
      ),
    );
  }
}
