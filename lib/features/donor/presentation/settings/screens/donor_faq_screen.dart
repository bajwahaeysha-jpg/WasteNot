import 'package:flutter/material.dart';

class DonorFaqScreen extends StatelessWidget {
  const DonorFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("FAQ",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [

            ListTile(
              title: Text("How do I donate food?"),
              subtitle: Text("Go to Donate tab and add donation details."),
            ),

            Divider(),

            ListTile(
              title: Text("Is my data safe?"),
              subtitle: Text("Yes, we securely store your information."),
            ),

            Divider(),

            ListTile(
              title: Text("How do NGOs contact me?"),
              subtitle: Text("NGOs can message you directly through the app."),
            ),

          ],
        ),
      ),
    );
  }
}
