import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  String error = "";
  bool updated = false;

  void _updatePassword() {
    if (newController.text != confirmController.text) {
      setState(() => error = "Passwords do not match");
      return;
    }

  

    setState(() {
      error = "";
      updated = true;
      currentController.clear();
      newController.clear();
      confirmController.clear();
    });
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        title: const Text("Change Password",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
       iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          _field("Current Password", currentController),
          _field("New Password", newController),
          _field("Confirm Password", confirmController),

          if (error.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),

          if (updated)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text("Password updated successfully",
                  style: TextStyle(color: Colors.green)),
            ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _updatePassword,
              child: const Text("Update Password"),
            ),
          ),
        ]),
      ),
    );
  }
}
