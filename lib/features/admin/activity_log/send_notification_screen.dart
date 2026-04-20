import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/activity_log/services/activity_log_notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  final String? donorId;
  final String? ngoId;

  const SendNotificationScreen({
    super.key,
    this.donorId,
    this.ngoId,
  });

  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final _notificationService = ActivityLogNotificationService();

  static const primary = Color(0xFF0B4B3F);
  String selectedGroup = 'All';

  String _audienceFromSelectedGroup(String group) {
    switch (group) {
      case 'Donors':
        return 'donor';
      case 'NGOs':
        return 'ngo';
      case 'All':
      default:
        return 'both';
    }
  }

  Future<void> sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      return;
    }

    try {
      if (widget.donorId != null || widget.ngoId != null) {
        await _notificationService.sendAdminActivityNotification(
          title: titleController.text.trim(),
          message: messageController.text.trim(),
          targetAudience: 'both',
        );
      } else {
        await _notificationService.sendAdminActivityNotification(
          title: titleController.text.trim(),
          message: messageController.text.trim(),
          targetAudience: _audienceFromSelectedGroup(selectedGroup),
        );
      }
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
      title: const Text(
        "Send Notification",
        style: TextStyle(color: Colors.white),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP HEADING
          Text(
            "Create Notification",
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          /// CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// DROPDOWN HEADING
                const Text(
                  "Select Audience",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                /// DROPDOWN (UI LIKE IMAGE)
                DropdownButtonFormField<String>(
                  initialValue: selectedGroup,
                  items: ["All", "Donors", "NGOs"]
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedGroup = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE FIELD
                const Text(
                  "Notification Title",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter title...",
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// DESCRIPTION FIELD
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: messageController,
                  maxLines: 4, // ✅ FIXED BOX SIZE
                  decoration: InputDecoration(
                    hintText: "Write notification details...",
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    ),
  );
}
}
