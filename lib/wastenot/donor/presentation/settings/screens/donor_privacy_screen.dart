import 'package:flutter/material.dart';

class DonorPrivacyScreen extends StatelessWidget {
  const DonorPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Privacy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: const [

          ListTile(
            title: Text("Data Usage"),
            subtitle: Text("How we use your personal data"),
          ),

          Divider(),

          ListTile(
            title: Text("Permissions"),
            subtitle: Text("Manage app permissions"),
          ),

          Divider(),

          ListTile(
            title: Text("Blocked NGOs"),
            subtitle: Text("View and manage blocked organizations"),
          ),

        ]),
      ),
    );
  }
}
