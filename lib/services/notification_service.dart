import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/services/session_service.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<bool> isNotificationEnabled(String userId) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      return true;
    }

    try {
      final doc = await _users.doc(trimmedId).get();
      if (!doc.exists) {
        return true;
      }
      final value = doc.data()?['notificationsEnabled'];
      if (value is bool) {
        return value;
      }
    } catch (_) {}

    return true;
  }

  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
  }) async {
    final trimmedId = receiverId.trim();
    if (trimmedId.isEmpty) {
      return;
    }

    final enabled = await isNotificationEnabled(trimmedId);
    if (!enabled) {
      return;
    }

    final sender = SessionService.user;
    final notificationRef = _notifications.doc();
    await notificationRef.set(<String, dynamic>{
      'notificationId': notificationRef.id,
      'receiverId': trimmedId,
      'title': title.trim(),
      'body': body.trim(),
      'timestamp': FieldValue.serverTimestamp(),

      // Compatibility fields for existing UI/services.
      'uid': trimmedId,
      'userId': trimmedId,
      'message': body.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'read': false,
      'sentBy': sender?.uid,
      'sentByName': sender?.displayName,
    });
  }
}
