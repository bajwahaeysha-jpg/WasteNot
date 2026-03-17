import 'package:flutter/material.dart';

class RequestSuccessScreen extends StatefulWidget {
  const RequestSuccessScreen({super.key});

  @override
  State<RequestSuccessScreen> createState() => _RequestSuccessScreenState();
}

class _RequestSuccessScreenState extends State<RequestSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _goBack();
  }

  Future<void> _goBack() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context, true);
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
              size: 90,
            ),
            SizedBox(height: 16),
            Text(
              "Request approved successfully",
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