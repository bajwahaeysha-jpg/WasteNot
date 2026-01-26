import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text("FAQ",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _item("How can I donate food?",
                "You can donate food by creating a donation post through the Donor section."),

            _item("How do NGOs receive donations?",
                "NGOs browse available donations and accept them based on location and needs."),

            _item("Is my data secure?",
                "Yes, all user data is handled securely and in compliance with privacy standards."),

            _item("How can I contact support?",
                "You can contact us from the Contact Us screen."),
          ],
        ),
      ),
    );
  }

  Widget _item(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(answer, style: const TextStyle(color: Colors.black54)),
      ]),
    );
  }
}
