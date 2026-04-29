import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/features/donor/models/donor_notification_model.dart';
import 'package:wastenot/services/admin_notification_read_receipt_service.dart';
import 'package:wastenot/services/donor_notification_service.dart';
import 'package:wastenot/services/notification_read_service.dart';
import 'package:wastenot/services/session_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    final user = SessionService.user;
    final service = DonorNotificationService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.notificationsForDonor(
          uid: user?.uid,
          email: user?.email,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Unable to load notifications",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final raw = snapshot.data ?? const <Map<String, dynamic>>[];
          final notifications = raw.map((item) {
            final idValue = item['id'];
            final id = idValue == null ? 'unknown' : idValue.toString();
            try {
              return DonorNotificationModel.fromMap(id: id, data: item);
            } catch (_) {
              return DonorNotificationModel.fromMap(
                id: id,
                data: const <String, dynamic>{},
              );
            }
          }).toList();

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return _notificationTile(
                context,
                _iconForType(item.type),
                _colorForType(item.type),
                item.title,
                item.message,
                _formatTime(item.createdAt),
                item,
              );
            },
          );
        },
      ),
    );
  }

  Widget _notificationTile(
  BuildContext context,
  IconData icon,
  Color color,
  String title,
  String message,
  String time,
  DonorNotificationModel item,
) {
  final currentUid = SessionService.user?.uid;

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
      if (currentUid != null && currentUid.trim().isNotEmpty) {
        final audience = item.targetAudience.trim().toLowerCase();

        if (audience == 'donor' || audience == 'both') {
          AdminNotificationReadReceiptService().markBroadcastNotificationRead(
            uid: currentUid,
            notificationId: item.id,
            audience: 'donor',
          );
        } else {
          NotificationReadService().markUserNotificationRead(
            notificationId: item.id,
          );
        }
      }
    },
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// (optional) unread dot
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

  IconData _iconForType(String? type) {
    switch (type) {
      case 'donor_suspension':
        return Icons.block;
      case 'donor_unsuspension':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'donor_suspension':
        return Colors.red;
      case 'donor_unsuspension':
        return const Color(0xFF0B4B3F);
      default:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime? rawValue) {
    if (rawValue == null) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(rawValue);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    }
    return DateFormat('dd/MM/yyyy').format(rawValue);
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String time;

  const NotificationDetailScreen({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.time,
  });

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Notification Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
