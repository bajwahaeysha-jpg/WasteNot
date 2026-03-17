import 'package:cloud_firestore/cloud_firestore.dart';

/// Marks individual (per-user) notifications as read in `notifications`.
/// This is used for direct notifications stored in the `notifications` collection.
class NotificationReadService {
  NotificationReadService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<void> markUserNotificationRead({
    required String notificationId,
  }) async {
    final id = notificationId.trim();
    if (id.isEmpty) return;

    await _notifications.doc(id).set(
      <String, dynamic>{
        'isRead': true,
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

