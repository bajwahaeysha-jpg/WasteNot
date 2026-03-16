import 'package:flutter/material.dart';
import 'package:wastenot/features/messaging/services/messaging_service.dart';

class MessageBadgeIcon extends StatelessWidget {
  const MessageBadgeIcon({
    super.key,
    required this.userId,
    this.color,
  });

  final String userId;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final messagingService = MessagingService();

    return StreamBuilder<int>(
      stream: messagingService.unreadConversationCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.message, color: color),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
