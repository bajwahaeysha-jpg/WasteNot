import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/firestore_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final currentUser = authService.currentFirebaseUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F4C45),
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
        stream: firestoreService.notificationsForUser(
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

              return _NotificationTile(
                icon: _resolveIcon(notification['title']?.toString() ?? ''),
                iconColor: _resolveColor(notification['title']?.toString() ?? ''),
                title: notification['title']?.toString() ?? 'Notification',
                message: notification['message']?.toString() ?? '',
                time: DateFormat('dd MMM, hh:mm a').format(date),
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
      return const Color(0xFF0F4C45);
    }
    if (title.toLowerCase().contains('rejected')) {
      return Colors.red;
    }
    return const Color(0xFF0F4C45);
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              color: iconColor.withValues(alpha: .15),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

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
        ],
      ),
    );
  }
}
