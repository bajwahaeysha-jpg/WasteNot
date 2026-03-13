import 'package:flutter/material.dart';
import 'package:wastenot/screens/donor_signup_screen.dart';
import 'package:wastenot/screens/ngo_signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key, required this.isLogin});

  final bool isLogin;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  static const Color mainGreen = Color(0xFF0B4B3F);
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your role',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainGreen),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the account type you want to create.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            _roleCard(
              title: 'Donor',
              description: 'Create a donor account and start donating food.',
              icon: Icons.volunteer_activism,
            ),
            const SizedBox(height: 18),
            _roleCard(
              title: 'NGO',
              description: 'Submit your NGO registration for admin approval.',
              icon: Icons.apartment,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: selectedRole == null ? null : _continue,
                child: const Text('Continue'),
              ),
            ),
            if (widget.isLogin)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Login does not require role selection anymore.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selectedRole == title;

    return InkWell(
      onTap: () => setState(() => selectedRole = title),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? mainGreen.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? mainGreen : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: isSelected ? mainGreen : mainGreen.withOpacity(0.12),
              child: Icon(icon, color: isSelected ? Colors.white : mainGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    final screen = selectedRole == 'Donor'
        ? const DonorSignupScreen()
        : const NgoSignUpScreen();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
