import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/admin_registration_notification_model.dart';
import 'package:wastenot/services/session_service.dart';

class AdminRegistrationNotificationService {
  AdminRegistrationNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _adminNotifications =>
      _firestore.collection('admin_notifications');

  /// Creates an admin notification when a DONOR registers.
  /// Uses a deterministic doc id to avoid duplicates if called twice.
  Future<void> createDonorRegistered({
    required String uid,
    required String name,
  }) async {
    final docId = 'register_donor_$uid';
    await _createIfMissing(
      docId: docId,
      title: 'New Donor Registered',
      message: 'A new donor has registered.',
      type: 'new_donor_registered',
      relatedUserId: uid,
      relatedUserName: name.trim(),
      relatedUserRole: 'donor',
    );
  }

  /// Creates an admin notification when an NGO submits registration/signup.
  /// There may not be a UID yet in your flow, so we store email as `relatedUserId`.
  Future<void> createNgoRegistered({
    required String email,
    required String organizationName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final safeEmail = normalizedEmail.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final docId = 'register_ngo_$safeEmail';
    await _createIfMissing(
      docId: docId,
      title: 'New NGO Registered',
      message: 'A new NGO has registered.',
      type: 'new_ngo_registered',
      relatedUserId: normalizedEmail,
      relatedUserName: organizationName.trim(),
      relatedUserRole: 'ngo',
    );
  }

  Stream<List<AdminRegistrationNotification>> streamAdminRegistrationNotifications({
    int limit = 100,
  }) {
    return _adminNotifications
        .where('targetAudience', isEqualTo: 'admin')
        .where('source', isEqualTo: 'register')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map(AdminRegistrationNotification.fromFirestore)
              .toList();
          // Avoid orderBy(serverTimestamp) delay; sort client-side.
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  /// Total count (badge). Stream-based so it updates in real time.
  Stream<int> streamAdminRegistrationCount({int limit = 99}) {
    return _adminNotifications
        .where('targetAudience', isEqualTo: 'admin')
        .where('source', isEqualTo: 'register')
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

  Future<void> markRegistrationNotificationRead({
    required String notificationId,
  }) async {
    final id = notificationId.trim();
    if (id.isEmpty) return;

    await _adminNotifications.doc(id).set(
      <String, dynamic>{
        'isRead': true,
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _createIfMissing({
    required String docId,
    required String title,
    required String message,
    required String type,
    required String relatedUserId,
    required String relatedUserName,
    required String relatedUserRole,
  }) async {
    final admin = SessionService.user;
    final ref = _adminNotifications.doc(docId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        return;
      }

      tx.set(ref, <String, dynamic>{
        'notificationId': docId,
        'title': title.trim(),
        'message': message.trim(),
        'type': type,
        'relatedUserId': relatedUserId,
        'relatedUserName': relatedUserName,
        'relatedUserRole': relatedUserRole,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'source': 'register',
        'targetAudience': 'admin',
        'sentBy': admin?.uid ?? 'system',
        'sentByName': admin?.displayName ?? 'System',
      });
    });
  }
}
