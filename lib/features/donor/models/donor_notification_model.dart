import 'package:cloud_firestore/cloud_firestore.dart';

class DonorNotificationModel {
  const DonorNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.sentBy,
    required this.targetAudience,
    required this.sentByAdmin,
    required this.read,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime? createdAt;
  final String sentBy;
  final String targetAudience;
  final bool sentByAdmin;
  final bool read;

  static DonorNotificationModel fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return DonorNotificationModel(
      id: id,
      title: _string(data['title'], fallback: 'Notification'),
      message: _string(data['message'], fallback: 'No message available'),
      type: _string(data['type'], fallback: 'general'),
      createdAt: _dateTime(data['createdAt']),
      sentBy: _string(data['sentBy'], fallback: 'system'),
      targetAudience: _string(data['targetAudience'], fallback: ''),
      sentByAdmin: _bool(data['sentByAdmin'], fallback: false),
      read: _bool(data['read'] ?? data['isRead'], fallback: false),
    );
  }

  static String _string(Object? value, {required String fallback}) {
    if (value == null) return fallback;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static bool _bool(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  static DateTime? _dateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

