import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // Header
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
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

                  const Center(
                    child: Icon(Icons.email, size: 90, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "Need Help?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Contact our support team and we'll get back to you shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openEmail,
              icon: const Icon(Icons.send),
              label: const Text("Contact through Mail"),
            ),
          ),
        ],
      ),
    );
  }
}
