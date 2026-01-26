import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@wastenot.com',
      query: 'subject=Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Contact Us",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 12),

            const Text(
              "Need help?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "If you have any questions, issues, or feedback, feel free to reach out to us.",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            /// 📧 Email (CLICKABLE)
            GestureDetector(
              onTap: _launchEmail,
              child: _infoTile(
                Icons.email_outlined,
                "Email",
                "support@wastenot.com",
                clickable: true,
              ),
            ),

            _infoTile(Icons.phone_outlined, "Phone", "+92 300 0000000"),
            _infoTile(Icons.location_on_outlined, "Address", "Sialkot, Pakistan"),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value, {
    bool clickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                value,
                style: TextStyle(
                  color: clickable ? Colors.blue : Colors.black54,
                  decoration:
                      clickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
