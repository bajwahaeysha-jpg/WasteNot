import 'package:flutter/material.dart';

class ExpireSuccessScreen extends StatefulWidget {
  const ExpireSuccessScreen({super.key});

  @override
  State<ExpireSuccessScreen> createState() => _ExpireSuccessScreenState();
}

class _ExpireSuccessScreenState extends State<ExpireSuccessScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pop(context); // ✅ back to previous screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Color(0xFF0F5F54),
            ),
            SizedBox(height: 16),
            Text(
              "Notification has been sent",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
