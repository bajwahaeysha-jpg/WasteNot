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

  Widget _field(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    Function(String)? onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: true,
          enabled: enabled,
          onChanged: onChanged,

          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0F4C45)),

            filled: true,
            fillColor: Colors.white,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled
                    ? const Color(0xFF0F4C45)
                    : Colors.grey.shade300,
                width: 1.4,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0F4C45),
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      resizeToAvoidBottomInset: true,

      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Change Password",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _field(
              "Current Password",
              currentController,
              icon: Icons.lock_outline,
              onChanged: _checkCurrent,
            ),

            _field(
              "New Password",
              newController,
              enabled: allowEditNew,
              icon: Icons.lock_open_outlined,
            ),

            _field(
              "Confirm Password",
              confirmController,
              enabled: allowEditNew,
              icon: Icons.verified_user_outlined,
            ),

            if (error.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (updated)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Password updated successfully",
                  style: TextStyle(color: Colors.green),
                ),
              ),

            const SizedBox(height: 28),

            /// Button
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: _updatePassword,

                child: const Text(
                  "Update Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}