import 'package:flutter/material.dart';
import 'package:wastenot/core/state/local_password.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool allowEditNew = false;
  String error = "";
  bool updated = false;

  void _checkCurrent(String value) async {
    final saved = await LocalPassword.getPassword();

    if (value == saved) {
      setState(() {
        allowEditNew = true;
        error = "";
      });
    } else {
      setState(() {
        allowEditNew = false;
        error = "Incorrect current password";
      });
    }
  }

  void _updatePassword() async {
    if (!allowEditNew) {
      setState(() => error = "Enter correct current password first");
      return;
    }

    if (newController.text != confirmController.text) {
      setState(() => error = "Passwords do not match");
      return;
    }

    await LocalPassword.setPassword(newController.text);

    setState(() {
      error = "";
      updated = true;
    });
  }

  Widget _field(String label, TextEditingController controller,
      {bool enabled = true, Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: true,
        enabled: enabled,
        onChanged: onChanged,
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Change Password",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          _field(
            "Current Password",
            currentController,
            onChanged: _checkCurrent,
          ),

          _field("New Password", newController, enabled: allowEditNew),
          _field("Confirm Password", confirmController, enabled: allowEditNew),

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
