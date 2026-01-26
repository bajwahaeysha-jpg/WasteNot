import 'package:flutter/material.dart';

class DonorChangePasswordScreen extends StatefulWidget {
  const DonorChangePasswordScreen({super.key});

  @override
  State<DonorChangePasswordScreen> createState() =>
      _DonorChangePasswordScreenState();
}

class _DonorChangePasswordScreenState extends State<DonorChangePasswordScreen> {

  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  String error = "";
  bool success = false;

  void updatePassword() {
    if (newController.text != confirmController.text) {
      setState(() => error = "Passwords do not match");
      return;
    }

    setState(() {
      error = "";
      success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Change Password",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          _field("Current Password", currentController),
          _field("New Password", newController),
          _field("Confirm Password", confirmController),

          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),

          if (success)
            const Text("Password updated successfully",
                style: TextStyle(color: Colors.green)),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: updatePassword,
              child: const Text("Update Password"),
            ),
          ),

        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }
}
