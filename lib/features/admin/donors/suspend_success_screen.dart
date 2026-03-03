import 'package:flutter/material.dart';

class SuspendSuccessScreen extends StatefulWidget {
  const SuspendSuccessScreen({super.key});

  @override
  State<SuspendSuccessScreen> createState() => _SuspendSuccessScreenState();
}

class _SuspendSuccessScreenState extends State<SuspendSuccessScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pop(context); // ✅ bas ek screen band
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
              color: Color(0xFF0F4C45),
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              "Suspend notification has been sent",
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
