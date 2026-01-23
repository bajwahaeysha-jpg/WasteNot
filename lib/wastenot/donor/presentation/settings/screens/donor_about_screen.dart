import 'package:flutter/material.dart';

class DonorAboutScreen extends StatelessWidget {
  const DonorAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("About App",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text("WasteNot",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 12),

            Text(
              "WasteNot connects donors with NGOs to reduce food waste and fight hunger. "
              "Our mission is to make donating food simple, fast and impactful.",
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),

            SizedBox(height: 20),

            Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
