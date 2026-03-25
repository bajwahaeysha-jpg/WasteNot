import 'package:flutter/material.dart';
import 'package:wastenot/services/account_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final AccountService _accountService = AccountService();

  String error = "";
  bool success = false;
  bool _isSubmitting = false;

  Future<void> updatePassword() async {
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
      success = false;
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
      setState(() => success = true);
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
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            ),
            _field(
              "New Password",
              newController,
              icon: Icons.lock_open_outlined,
            ),
            _field(
              "Confirm Password",
              confirmController,
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
            if (success)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Password updated successfully",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 28),
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
                onPressed: _isSubmitting ? null : updatePassword,
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

  Widget _field(
    String label,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0F4C45)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0F4C45),
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
