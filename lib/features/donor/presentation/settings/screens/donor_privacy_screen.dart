import 'package:flutter/material.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class DonorPrivacyScreen extends StatefulWidget {
  const DonorPrivacyScreen({super.key});

  @override
  State<DonorPrivacyScreen> createState() => _DonorPrivacyScreenState();
}

class _DonorPrivacyScreenState extends State<DonorPrivacyScreen> {

  bool allowMessages = true;
  bool _isSaving = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    allowMessages = SessionService.user?.allowMessages ?? true;
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
      allowMessages = value;
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
      setState(() => allowMessages = !value);
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
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Privacy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),

            title: const Text(
              "Allow direct messages",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Let donors contact your organization directly through the app",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            trailing: Switch(
              value: allowMessages,
              inactiveThumbColor: Colors.white,
              activeTrackColor: Colors.deepPurple,
              onChanged: _toggleAllowMessages,
            ),
          ),
        ),
      ),
    );
  }
}
