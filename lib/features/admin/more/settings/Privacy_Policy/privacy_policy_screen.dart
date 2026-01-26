import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        
        title: const Text("Privacy Policy",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [

          Text("Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          SizedBox(height: 12),

          Text(
            "Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.",
            style: TextStyle(color: Colors.black54),
          ),

          SizedBox(height: 16),

          Text("Information We Collect",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 6),

          Text(
            "We may collect personal information such as name, email, phone number, and usage data to improve our services.",
            style: TextStyle(color: Colors.black54),
          ),

          SizedBox(height: 16),

          Text("How We Use Information",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 6),

          Text(
            "We use collected information to provide better service, improve user experience, and communicate important updates.",
            style: TextStyle(color: Colors.black54),
          ),

          SizedBox(height: 16),

          Text("Security",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 6),

          Text(
            "We take strong security measures to protect your data from unauthorized access.",
            style: TextStyle(color: Colors.black54),
          ),
        ]),
      ),
    );
  }
}
