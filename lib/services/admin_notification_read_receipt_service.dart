import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user read receipts for broadcast admin notifications stored in
/// `admin_notifications` (targetAudience donor/ngo/both).
///
/// IMPORTANT: We do NOT mark `admin_notifications.isRead` because that would
/// affect every user. Read state is stored per user in `admin_notification_reads`.
class AdminNotificationReadReceiptService {
  AdminNotificationReadReceiptService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reads =>
      _firestore.collection('admin_notification_reads');

  String _docId(String uid, String notificationId) {
    final safeUid = uid.trim();
    final safeNotif = notificationId.trim();
    return 'read_${safeUid}_$safeNotif';
  }

  Future<void> markBroadcastNotificationRead({
    required String uid,
    required String notificationId,
    required String audience, // "donor" or "ngo"
  }) async {
    final safeUid = uid.trim();
    final safeNotif = notificationId.trim();
    final safeAudience = audience.trim().toLowerCase();
    if (safeUid.isEmpty || safeNotif.isEmpty) return;

    final ref = _reads.doc(_docId(safeUid, safeNotif));
    await ref.set(
      <String, dynamic>{
        'uid': safeUid,
        'notificationId': safeNotif,
        'audience': safeAudience,
        'readAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Streams the set of read broadcast notificationIds for the given user/audience.
  Stream<Set<String>> streamReadIds({
    required String uid,
    required String audience, // "donor" or "ngo"
    int limit = 500,
  }) {
    final safeUid = uid.trim();
    final safeAudience = audience.trim().toLowerCase();
    if (safeUid.isEmpty) return const Stream<Set<String>>.empty();

    return _reads
        .where('uid', isEqualTo: safeUid)
        .where('audience', isEqualTo: safeAudience)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => (d.data()['notificationId'] as String?) ?? '')
            .where((id) => id.trim().isNotEmpty)
            .toSet());
  }
}

