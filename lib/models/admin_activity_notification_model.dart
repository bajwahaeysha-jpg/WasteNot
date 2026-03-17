import 'package:cloud_firestore/cloud_firestore.dart';

class AdminActivityNotification {
  const AdminActivityNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.targetAudience,
    required this.createdAt,
    required this.sentBy,
    required this.sentByName,
    required this.source,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;

  /// "donor", "ngo", or "both"
  final String targetAudience;

  final DateTime createdAt;

  /// UID of the admin that sent this notification (or "admin"/"system")
  final String sentBy;
  final String sentByName;

  /// Optional categorization ("activity_log" by default).
  final String source;

  /// Optional notification type for UI icon mapping.
  final String type;

  /// Reserved for future per-user read receipts. Kept for forward compatibility.
  final bool isRead;

  static DateTime _dateFromDynamic(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  factory AdminActivityNotification.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return AdminActivityNotification(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Notification',
      message: (data['message'] as String?) ?? '',
      targetAudience: (data['targetAudience'] as String?) ?? 'both',
      createdAt: _dateFromDynamic(data['createdAt']),
      sentBy: (data['sentBy'] as String?) ?? 'admin',
      sentByName: (data['sentByName'] as String?) ?? 'System Admin',
      source: (data['source'] as String?) ?? 'activity_log',
      type: (data['type'] as String?) ?? 'admin_activity',
      isRead: (data['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'notificationId': id,
      'title': title,
      'message': message,
      'targetAudience': targetAudience,
      'createdAt': Timestamp.fromDate(createdAt),
      'sentBy': sentBy,
      'sentByName': sentByName,
      'source': source,
      'type': type,
      'isRead': isRead,
    };
  }

  Map<String, dynamic> toUiMap() {
    return <String, dynamic>{
      'id': id,
      'notificationId': id,
      'title': title,
      'message': message,
      'targetAudience': targetAudience,
      'createdAt': Timestamp.fromDate(createdAt),
      'sentBy': sentBy,
      'sentByName': sentByName,
      'source': source,
      'type': type,
      'isRead': isRead,
    };
  }
}

