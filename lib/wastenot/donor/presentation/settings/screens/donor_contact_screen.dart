import 'package:flutter/material.dart';

class DonorContactScreen extends StatelessWidget {
  const DonorContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Contact Us",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text("Need help?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Text("Email: support@wastenot.com"),
          SizedBox(height: 6),
          Text("Phone: +92 300 1234567"),
          SizedBox(height: 6),
          Text("Office: Sialkot, Pakistan"),
        ]),
      ),
    );
  }
}
