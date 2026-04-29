import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/ngo_notification_service.dart';
import 'package:wastenot/services/notification_read_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final notificationService = NgoNotificationService();
    final currentUser = authService.currentFirebaseUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: notificationService.notificationsForNgo(
          uid: currentUser?.uid,
          email: currentUser?.email,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final createdAt = notification['createdAt'];
              final date = createdAt is Timestamp
                  ? createdAt.toDate()
                  : DateTime.now();
              final isRead =
                  notification['isRead'] == true || notification['read'] == true;

              final title =
                  notification['title']?.toString().trim().isNotEmpty == true
                  ? notification['title'].toString()
                  : 'Notification';

              final message =
                  notification['message']?.toString().trim().isNotEmpty == true
                  ? notification['message'].toString()
                  : 'No details available';

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final notifId = notification['id']?.toString() ?? '';

                    // Mark as read to remove badge in real time.
                    if (notifId.trim().isNotEmpty) {
                      NotificationReadService().markUserNotificationRead(
                        notificationId: notifId,
                      );
                    }

                  },
                  child: _NotificationTile(
                    icon: _resolveIcon(title),
                    iconColor: _resolveColor(title),
                    title: title,
                    message: message,
                    time: DateFormat('dd MMM, hh:mm a').format(date),
                    isRead: isRead,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _resolveIcon(String title) {
    if (title.toLowerCase().contains('approved')) {
      return Icons.check_circle;
    }
    if (title.toLowerCase().contains('rejected')) {
      return Icons.cancel;
    }
    return Icons.notifications_active;
  }

  Color _resolveColor(String title) {
    if (title.toLowerCase().contains('approved')) {
      return const Color(0xFF0B4B3F);
    }
    if (title.toLowerCase().contains('rejected')) {
      return Colors.red;
    }
    return const Color(0xFF0B4B3F);
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha:0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
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
          if (!isRead)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          if (!isRead) const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final String donationId;

  const NotificationDetailScreen({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.donationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notification Detail',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha:0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              if (donationId.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Related Donation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  donationId,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
