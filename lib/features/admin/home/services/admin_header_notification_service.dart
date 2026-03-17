import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin header bell icon backend (separate from UI).
/// Shows real-time badge count for new donor/NGO registrations.
class AdminHeaderNotificationService {
  AdminHeaderNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _adminNotifications =>
      _firestore.collection('admin_notifications');

  Stream<int> streamRegistrationBadgeCount({int limit = 99}) {
    return _adminNotifications
        .where('targetAudience', isEqualTo: 'admin')
        .where('source', isEqualTo: 'register')
        // No orderBy: avoids waiting for serverTimestamp to materialize.
        .limit(limit + 1)
        .snapshots()
        .map((snapshot) {
          var unread = 0;
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final isRead = data['isRead'] == true || data['read'] == true;
            if (!isRead) unread++;
          }
          return unread;
        });
  }
}
