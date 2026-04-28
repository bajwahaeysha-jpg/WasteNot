import 'package:flutter/material.dart';
import 'package:wastenot/services/account_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final AccountService _accountService = AccountService();

  bool allowEditNew = false;
  String error = "";
  bool updated = false;
  bool _isSubmitting = false;

  void _checkCurrent(String value) {
    setState(() {
      allowEditNew = value.trim().isNotEmpty;
      if (error.isNotEmpty) {
        error = "";
      }
    });
  }

  Future<void> _updatePassword() async {
    final currentPassword = currentController.text.trim();
    final newPassword = newController.text.trim();
    final confirmPassword = confirmController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => error = "Please fill in all fields");
      _showSnackBar(error, isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => error = "Passwords do not match");
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() {
      error = "";
      updated = false;
      _isSubmitting = true;
    });

    try {
      await _accountService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) {
        return;
      }
      setState(() => updated = true);
      _showSnackBar("Password updated successfully");
    } on AccountFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => this.error = error.message);
      _showSnackBar(error.message, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Ã°Å¸â€Â¹ MODERN INPUT FIELD
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
              color: enabled ? const Color(0xFF0B4B3F) : Colors.grey.shade300,
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

      /// Ã°Å¸Å¸Â¢ GREEN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B4B3F),
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
                  style: TextStyle(color:  Color(0xFF0B4B3F)),
                ),
              ),

            const SizedBox(height: 30),

            /// UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _updatePassword,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4B3F),
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF0B4B3F),
      ),
    );
  }
}
