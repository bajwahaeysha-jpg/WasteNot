import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/activity_log/services/activity_log_notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  final String group;

  const SendNotificationScreen({super.key, required this.group});

  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final _notificationService = ActivityLogNotificationService();

  static const primary = Color(0xFF0B4B3F);

  String _audienceFromGroupLabel(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized == 'donors') return 'donor';
    if (normalized == 'ngos') return 'ngo';
    if (normalized == 'donors & ngos' || normalized == 'donors and ngos') {
      return 'both';
    }
    return 'both';
  }

  Future<void> sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      return;
    }

    try {
      await _notificationService.sendAdminActivityNotification(
        title: titleController.text.trim(),
        message: messageController.text.trim(),
        targetAudience: _audienceFromGroupLabel(widget.group),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send notification')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Send to ${widget.group}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Notification",
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "This message will be sent to ${widget.group}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Notification Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: sendNotification,
                child: const Text(
                  "Send Notification",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}