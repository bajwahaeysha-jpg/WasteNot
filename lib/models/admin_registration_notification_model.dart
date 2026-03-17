import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegistrationNotification {
  const AdminRegistrationNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedUserId,
    required this.relatedUserName,
    required this.relatedUserRole,
    required this.createdAt,
    required this.isRead,
    required this.source,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final String relatedUserId;
  final String relatedUserName;
  final String relatedUserRole; // "donor" | "ngo"
  final DateTime createdAt;
  final bool isRead;
  final String source; // "register"

  static DateTime _dateFromDynamic(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  factory AdminRegistrationNotification.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return AdminRegistrationNotification(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Notification',
      message: (data['message'] as String?) ?? '',
      type: (data['type'] as String?) ?? 'registration',
      relatedUserId: (data['relatedUserId'] as String?) ?? '',
      relatedUserName: (data['relatedUserName'] as String?) ?? '',
      relatedUserRole: (data['relatedUserRole'] as String?) ?? '',
      createdAt: _dateFromDynamic(data['createdAt']),
      isRead: (data['isRead'] as bool?) ?? false,
      source: (data['source'] as String?) ?? 'register',
    );
  }
}

