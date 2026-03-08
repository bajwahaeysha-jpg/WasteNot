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

  /// 🔹 MODERN INPUT FIELD
  Widget _field(String label, TextEditingController controller,
      {bool enabled = true, Function(String)? onChanged}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? const Color(0xFF0F4C45) : Colors.grey.shade300,
              width: enabled ? 1.4 : 1,
            ),
          ),

          child: TextField(
            controller: controller,
            obscureText: true,
            enabled: enabled,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      /// 🟢 GREEN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),

        title: Row(
          children: const [
            Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.lock, color: Colors.white),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 10),

            /// CURRENT PASSWORD
            _field(
              "Current Password",
              currentController,
              onChanged: _checkCurrent,
            ),

            /// NEW PASSWORD
            _field(
              "New Password",
              newController,
              enabled: allowEditNew,
            ),

            /// CONFIRM PASSWORD
            _field(
              "Confirm Password",
              confirmController,
              enabled: allowEditNew,
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

            const SizedBox(height: 30),

            /// UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: _updatePassword,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  "Update Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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