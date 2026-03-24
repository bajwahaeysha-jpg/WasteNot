import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorContactScreen extends StatelessWidget {
  const DonorContactScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);

  void _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'wastenotapplication@gmail.com',
      query: Uri.encodeFull(
        'subject=WasteNot Support&body=Please describe your issue here.',
      ),
    );

    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Contact Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.support_agent,
              size: 90, // slightly bigger
              color: primary,
            ),

            const SizedBox(height: 30),

            const Text(
              "Need Help?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Contact our support team and we'll get back to you shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openEmail,
                icon: const Icon(Icons.email_outlined),
                label: const Text(
                  "Contact through Mail",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // more rounded
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