import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/admin_activity_notification_model.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class ActivityLogNotificationService {
  ActivityLogNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _adminNotifications =>
      _firestore.collection('admin_notifications');

  CollectionReference<Map<String, dynamic>> get _adminActivityLogs =>
      _firestore.collection('admin_activity_logs');

  /// Admin side: creates a single admin notification document (with `targetAudience`)
  /// and also writes an entry into `admin_activity_logs` so the Activity Log screen
  /// continues to work without UI changes.
  Future<void> sendAdminActivityNotification({
    required String title,
    required String message,
    required String targetAudience, // "donor", "ngo", "both"
    String source = 'activity_log',
    String type = 'admin_activity',
  }) async {
    final normalizedAudience = _normalizeAudience(targetAudience);
    final admin = SessionService.user;

    final notificationRef = _adminNotifications.doc();
    final logRef = _adminActivityLogs.doc();
    final batch = _firestore.batch();

    batch.set(notificationRef, <String, dynamic>{
      'notificationId': notificationRef.id,
      'title': title.trim(),
      'message': message.trim(),
      'targetAudience': normalizedAudience,
      'createdAt': FieldValue.serverTimestamp(),
      'sentBy': admin?.uid ?? 'admin',
      'sentByName': admin?.displayName ?? 'System Admin',
      'type': type,
      'source': source,
      'isRead': false,
    });

    batch.set(logRef, <String, dynamic>{
      'actionType': 'admin_sent_notification',
      'title': title.trim(),
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
      // Used by AdminActivityLogEntry.fromFirestore
      'receiverName': _receiverLabelForAudience(normalizedAudience),
      // Keep raw audience for any future filtering.
      'targetAudience': normalizedAudience,
      // Optional, but consistent with other log entries.
      'source': source,
    });

    await batch.commit();
  }

  /// Donor side: returns personal notifications (existing `notifications` collection)
  /// plus admin activity notifications targeted to "donor" or "both".
  Stream<List<Map<String, dynamic>>> notificationsForDonor({
    String? uid,
    String? email,
  }) {
    return _notificationsForAudience(
      audience: 'donor',
      uid: uid,
      email: email,
    );
  }

  /// NGO side: returns personal notifications (existing `notifications` collection)
  /// plus admin activity notifications targeted to "ngo" or "both".
  Stream<List<Map<String, dynamic>>> notificationsForNgo({
    String? uid,
    String? email,
  }) {
    return _notificationsForAudience(
      audience: 'ngo',
      uid: uid,
      email: email,
    );
  }

  Stream<List<Map<String, dynamic>>> _notificationsForAudience({
    required String audience, // "donor" or "ngo"
    String? uid,
    String? email,
  }) {
    final personalStream = FirestoreService().notificationsForUser(
      uid: uid,
      email: email,
    );

    // whereIn avoids OR query issues in Flutter.
    final adminStream = _adminNotifications
        .where('targetAudience', whereIn: <String>[audience, 'both'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // `createdAt` can be null immediately after write due to serverTimestamp.
        return <String, dynamic>{
          'id': doc.id,
          ...data,
          'title': _safeString(data['title'], fallback: 'Notification'),
          'message':
              _safeString(data['message'], fallback: 'No message available'),
          'type': _safeString(data['type'], fallback: 'admin_activity'),
          'source': _safeString(data['source'], fallback: 'activity_log'),
        };
      }).toList();
    });

    return _mergeAndSortByCreatedAt(
      streams: <Stream<List<Map<String, dynamic>>>>[
        personalStream,
        adminStream,
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _mergeAndSortByCreatedAt({
    required List<Stream<List<Map<String, dynamic>>>> streams,
  }) {
    late StreamController<List<Map<String, dynamic>>> controller;
    final latestValues = List<List<Map<String, dynamic>>>.filled(
      streams.length,
      const <Map<String, dynamic>>[],
      growable: false,
    );
    final subscriptions = <StreamSubscription<List<Map<String, dynamic>>>>[];

    void emit() {
      final merged = <Map<String, dynamic>>[];
      for (final list in latestValues) {
        merged.addAll(list);
      }

      merged.sort((a, b) {
        final ad = _dateFromCreatedAt(a['createdAt']);
        final bd = _dateFromCreatedAt(b['createdAt']);
        return bd.compareTo(ad);
      });

      controller.add(merged);
    }

    controller = StreamController<List<Map<String, dynamic>>>.broadcast(
      onListen: () {
        for (var i = 0; i < streams.length; i++) {
          final index = i;
          final sub = streams[index].listen(
            (value) {
              latestValues[index] = value;
              emit();
            },
            onError: controller.addError,
          );
          subscriptions.add(sub);
        }
      },
      onCancel: () async {
        for (final sub in subscriptions) {
          await sub.cancel();
        }
      },
    );

    return controller.stream;
  }

  DateTime _dateFromCreatedAt(Object? rawValue) {
    if (rawValue is Timestamp) return rawValue.toDate();
    if (rawValue is DateTime) return rawValue;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _safeString(Object? value, {required String fallback}) {
    if (value == null) return fallback;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  String _normalizeAudience(String raw) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'donor':
      case 'donors':
        return 'donor';
      case 'ngo':
      case 'ngos':
        return 'ngo';
      case 'both':
      case 'donors & ngos':
      case 'donors and ngos':
        return 'both';
      default:
        return 'both';
    }
  }

  String _receiverLabelForAudience(String audience) {
    switch (audience) {
      case 'donor':
        return 'Donors';
      case 'ngo':
        return 'NGOs';
      case 'both':
      default:
        return 'Donors & NGOs';
    }
  }

  /// Optional helper if you want to use the typed model elsewhere.
  AdminActivityNotification parseAdminNotificationDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AdminActivityNotification.fromFirestore(doc);
  }
}

