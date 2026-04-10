import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/features/admin/donors/donor_profile_screen.dart';
import 'package:wastenot/features/admin/ngos/ngo_profile_screen.dart';
import 'package:wastenot/features/admin/notifications/services/admin_notification_target_service.dart';
import 'package:wastenot/features/admin/quick_actions/requests/request_detail_screen.dart';
import 'package:wastenot/models/admin_registration_notification_model.dart';
import 'package:wastenot/services/admin_registration_notification_service.dart';
import '../../../core/constants/app_colors.dart';

/// ðŸ”‘ SHARED COLOR (FIX)
const Color mainGreen = Color(0xFF0B4B3F);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdminRegistrationNotificationService();
    final targetService = AdminNotificationTargetService();
    return Scaffold(
      backgroundColor: AppColors.background,

      /// ðŸŸ¢ APP BAR
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      /// ðŸ”” NOTIFICATIONS LIST
      body: StreamBuilder<List<AdminRegistrationNotification>>(
        stream: service.streamAdminRegistrationNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Unable to load notifications"));
          }

          final items =
              snapshot.data ?? const <AdminRegistrationNotification>[];
          if (items.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((item) {
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openTarget(context, item, targetService),
                child: _NotificationTile(
                  icon: _iconFor(item.type),
                  title: item.title,
                  subtitle: _formatTime(item.createdAt),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  static IconData _iconFor(String type) {
    switch (type) {
      case 'new_donor_registered':
        return Icons.person_add;
      case 'new_ngo_registered':
        return Icons.apartment;
      default:
        return Icons.notifications;
    }
  }

  static String _formatTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
    if (difference.inDays < 1) return '${difference.inHours} hours ago';
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  Future<void> _openTarget(
    BuildContext context,
    AdminRegistrationNotification item,
    AdminNotificationTargetService targetService,
  ) async {
    // Mark as read for admin badge removal (admin-only registration notifications).
    await AdminRegistrationNotificationService().markRegistrationNotificationRead(
      notificationId: item.id,
    );

    if (item.type == 'new_donor_registered' && item.relatedUserId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonorProfileScreen(donorId: item.relatedUserId),
        ),
      );
      return;
    }

    if (item.type == 'new_ngo_registered') {
      final email = item.relatedUserId.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO details not available.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      var loaderOpen = true;

      try {
        final ngoUid = await targetService.findUserIdByEmail(email);
        if (!context.mounted) return;
        if (loaderOpen) {
          Navigator.pop(context);
          loaderOpen = false;
        }

        if (ngoUid != null && ngoUid.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NGOProfileScreen(ngoId: ngoUid)),
          );
          return;
        }

        final request = await targetService.findNgoRequestByEmail(email);
        if (!context.mounted) return;
        if (request != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestDetailScreen(request: request),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO details not available yet.')),
        );
      } catch (_) {
        if (!context.mounted) return;
        if (loaderOpen) {
          Navigator.pop(context);
          loaderOpen = false;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open details right now.')),
        );
      } finally {
        if (!context.mounted) return;
        if (loaderOpen) {
          Navigator.pop(context);
          loaderOpen = false;
        }
      }
    }
  }
}

/// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ NOTIFICATION TILE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ðŸ”” ICON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mainGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: mainGreen,
            ),
          ),

          const SizedBox(width: 12),

          /// ðŸ“ TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
