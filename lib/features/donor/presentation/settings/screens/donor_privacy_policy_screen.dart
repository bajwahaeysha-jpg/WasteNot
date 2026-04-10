import 'package:flutter/material.dart';

class DonorPrivacyPolicyScreen extends StatelessWidget {
  const DonorPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // GREEN HEADER WITH BACK BUTTON
            Stack(
              children: [

                Container(
  width: double.infinity,
  padding: const EdgeInsets.only(top: 80, bottom: 60), // height increase
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF0B4B3F),
        Color(0xFF2E7D6E),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: const Center(
    child: Icon(
      Icons.shield_outlined,
      color: Colors.white,
      size: 70,
    ),
  ),
),

                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Updated: 1 Jan 2026",
                    style: TextStyle(color: Colors.grey),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "WasteNot is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application and services.",
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "1. Scope of Policy",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "This policy applies to all users of the WasteNot platform. By using our service, you agree to the collection and use of information in accordance with this policy.",
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "2. Information We Collect",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "We collect personal information such as name, email address, phone number, and organization details to operate and improve our service.",
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "3. Use of Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "The information we collect is used to provide, maintain, and improve WasteNot services, communicate with you, and ensure platform safety.",
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "4. Data Security",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "We take appropriate security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction.",
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}