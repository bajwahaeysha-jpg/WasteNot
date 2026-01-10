import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // 🖼️ Header image section
          Container(
            height: 230,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  Center(
                    child: Icon(Icons.privacy_tip,
                        size: 100, color: Colors.white.withValues(alpha: 0.9)
),
                  ),
                ],
              ),
            ),
          ),

          // 📜 Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [

                Text("Privacy Policy",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color: Colors.black)),

                SizedBox(height: 6),
                Text("Updated: 1 Jan 2026",
                    style: TextStyle(color: Colors.black)),

                SizedBox(height: 20),

                Text(
                  "WasteNot is committed to protecting your privacy. This Privacy Policy "
                  "explains how we collect, use, and safeguard your information when you use "
                  "our application and services.",
                  style: TextStyle(height: 1.5,color: Colors.black),
                ),

                SizedBox(height: 20),

                Text("1. Scope of Policy",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),

                SizedBox(height: 8),
                Text(
                  "This policy applies to all users of the WasteNot platform. By using our "
                  "service, you agree to the collection and use of information in accordance "
                  "with this policy.",
                  style: TextStyle(height: 1.5,color: Colors.black),
                ),

                SizedBox(height: 20),

                Text("2. Information We Collect",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),

                SizedBox(height: 8),
                Text(
                  "We collect personal information such as name, email address, phone number, "
                  "and organization details to operate and improve our service.",
                  style: TextStyle(height: 1.5,color: Colors.black),
                ),

                SizedBox(height: 20),

                Text("3. Use of Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),

                SizedBox(height: 8),
                Text(
                  "The information we collect is used to provide, maintain, and improve "
                  "WasteNot services, communicate with you, and ensure platform safety.",
                  style: TextStyle(height: 1.5,color: Colors.black),
                ),

                SizedBox(height: 20),

                Text("4. Data Security",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),

                SizedBox(height: 8),
                Text(
                  "We take appropriate security measures to protect your personal data "
                  "against unauthorized access, alteration, disclosure, or destruction.",
                  style: TextStyle(height: 1.5,color: Colors.black),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
