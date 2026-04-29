import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/services/admin_notification_read_receipt_service.dart';

class NotificationBadgeService {
  NotificationBadgeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _adminNotifications =>
      _firestore.collection('admin_notifications');

  Stream<int> donorBellCount({
    required String? uid,
    required String? email,
    int limit = 99,
  }) {
    return _userBellCount(
      uid: uid,
      email: email,
      audience: 'donor',
      limit: limit,
    );
  }

  Stream<int> ngoBellCount({
    required String? uid,
    required String? email,
    int limit = 99,
  }) {
    return _userBellCount(
      uid: uid,
      email: email,
      audience: 'ngo',
      limit: limit,
    );
  }

  /// Admin bell count (used for header badge). This counts recent activity logs.
  /// For this feature we count admin registration notifications stored in
  /// `admin_notifications` (targetAudience == "admin", source == "register").
  Stream<int> adminBellCount({int limit = 99}) {
    return _adminNotifications
        .where('targetAudience', isEqualTo: 'admin')
        .where('source', isEqualTo: 'register')
        // No orderBy: avoids waiting for serverTimestamp to materialize.
        .limit(limit + 1)
        .snapshots()
        .map(_unreadCountFromSnapshot);
  }

  Stream<int> _userBellCount({
    required String? uid,
    required String? email,
    required String audience, // "donor" or "ngo"
    required int limit,
  }) {
    final personalCountStream = _personalNotificationCount(
      uid: uid,
      email: email,
      limit: limit,
    );

    final adminAudienceCountStream = _adminAudienceNotificationCount(
      audience: audience,
      uid: uid,
      limit: limit,
    );

    return _combineCounts(personalCountStream, adminAudienceCountStream);
  }

  Stream<int> _personalNotificationCount({
    required String? uid,
    required String? email,
    required int limit,
  }) {
    if (uid != null && uid.trim().isNotEmpty) {
      return _notifications
          .where('receiverId', isEqualTo: uid.trim())
          .limit(limit + 1)
          .snapshots()
          .map(_unreadCountFromSnapshot);
    }

    return const Stream<int>.empty();
  }

  Stream<int> _adminAudienceNotificationCount({
    required String audience,
    required String? uid,
    required int limit,
  }) {
    final notifications = _adminNotifications
        .where('targetAudience', whereIn: <String>[audience, 'both'])
        .limit(limit + 1)
        .snapshots();

    final safeUid = uid?.trim();
    if (safeUid == null || safeUid.isEmpty) {
      // Without a UID we can't track per-user read receipts.
      return notifications.map((snap) => snap.size);
    }

    final reads = AdminNotificationReadReceiptService().streamReadIds(
      uid: safeUid,
      audience: audience,
      limit: 2000,
    );

    return _combineBroadcastUnread(notifications, reads);
  }

  Stream<int> _combineBroadcastUnread(
    Stream<QuerySnapshot<Map<String, dynamic>>> notifications,
    Stream<Set<String>> readIds,
  ) {
    late StreamController<int> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subA;
    StreamSubscription<Set<String>>? subB;
    var lastNotifs = const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var lastReads = <String>{};

    void emit() {
      final unread = lastNotifs.where((doc) => !lastReads.contains(doc.id)).length;
      controller.add(unread);
    }

    controller = StreamController<int>.broadcast(
      onListen: () {
        subA = notifications.listen(
          (snap) {
            lastNotifs = snap.docs;
            emit();
          },
          onError: controller.addError,
        );
        subB = readIds.listen(
          (ids) {
            lastReads = ids;
            emit();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
      },
    );

    return controller.stream;
  }

  static int _unreadCountFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    var unread = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final isRead = data['isRead'] == true || data['read'] == true;
      if (!isRead) unread++;
    }
    return unread;
  }

  Stream<int> _combineCounts(Stream<int> a, Stream<int> b) {
    late StreamController<int> controller;
    StreamSubscription<int>? subA;
    StreamSubscription<int>? subB;
    var lastA = 0;
    var lastB = 0;

    void emit() => controller.add(lastA + lastB);

    controller = StreamController<int>.broadcast(
      onListen: () {
        subA = a.listen(
          (value) {
            lastA = value;
            emit();
          },
          onError: controller.addError,
        );
        subB = b.listen(
          (value) {
            lastB = value;
            emit();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
      },
    );

    return controller.stream;
  }
}
