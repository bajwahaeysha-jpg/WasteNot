import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorContactScreen extends StatelessWidget {
  const DonorContactScreen({super.key});

  Future<void> _openMail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@wastenot.com',
      queryParameters: {
        'subject': 'WasteNot Support',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5D4E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Contact Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [

            const SizedBox(height: 120),

            const Icon(
              Icons.support_agent,
              size: 100,
              color: Color(0xFF0F5D4E),
            ),

            const SizedBox(height: 25),

            const Text(
              "Need Help?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Contact our support team and we'll get back to you shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openMail,
                icon: const Icon(Icons.mail_outline),
                label: const Text(
                  "Contact through Mail",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5D4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}