import 'package:flutter/material.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool allowDirectMessages = true;
  bool _isSaving = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    allowDirectMessages = SessionService.user?.allowMessages ?? true;
  }

  Future<void> _toggleAllowMessages(bool value) async {
    if (_isSaving) {
      return;
    }

    final user = SessionService.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update privacy settings.')),
      );
      return;
    }

    setState(() {
      allowDirectMessages = value;
      _isSaving = true;
    });

    try {
      await _firestoreService.updateUserDocument(
        uid: user.uid,
        data: {'allowMessages': value},
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => allowDirectMessages = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update privacy settings.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFF0B4B3F),
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    "Privacy",
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Allow direct messages",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Let donors contact your organization directly through the app",
                            style: TextStyle(color: Colors.black),
                          ),
                        ]),
                  ),
                  Switch(
                    value: allowDirectMessages,
                    onChanged: _toggleAllowMessages,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
