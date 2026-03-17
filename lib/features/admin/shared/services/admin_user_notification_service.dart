import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/services/session_service.dart';

class AdminUserNotificationService {
  AdminUserNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _adminActivityLogs =>
      _firestore.collection('admin_activity_logs');

  /// Adds a user notification document to an existing batch.
  /// This intentionally does NOT write to `admin_activity_logs` because not every
  /// notification is an "admin sent notification" (e.g. suspensions have their
  /// own log action types in the management services).
  void addUserNotificationToBatch({
    required WriteBatch batch,
    required String userId,
    required String userRole, // "donor" or "ngo"
    required String title,
    required String message,
    required String type,
    String source = 'admin',
    String? email,
  }) {
    final admin = SessionService.user;
    final notificationRef = _notifications.doc();

    batch.set(notificationRef, <String, dynamic>{
      // Compatibility with existing app reads (bell screens query by uid/email).
      'uid': userId,
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),

      // Suggested / future-proof fields.
      'notificationId': notificationRef.id,
      'userId': userId,
      'userRole': userRole,
      'title': title.trim(),
      'message': message.trim(),
      'type': type,
      'source': source,
      'audienceType': 'individual',
      'sentBy': admin?.uid ?? 'admin',
      'sentByName': admin?.displayName ?? 'System Admin',
      'sentByAdmin': true,
      'isRead': false,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin action: send a notification to ONE specific user and also log it into
  /// `admin_activity_logs` (so it appears in the admin Activity Log screen).
  Future<void> sendNotificationToUserAndLog({
    required String userId,
    required String userRole, // "donor" or "ngo"
    required String userName,
    required String title,
    required String message,
    required String type,
    String source = 'admin_user_notification',
    String? email,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();

    addUserNotificationToBatch(
      batch: batch,
      userId: userId,
      userRole: userRole,
      email: email,
      title: title,
      message: message,
      type: type,
      source: source,
    );

    final logRef = _adminActivityLogs.doc();
    batch.set(logRef, <String, dynamic>{
      'activityId': logRef.id,
      'actionType': 'admin_sent_notification',
      'type': type,
      'title': title.trim(),
      'message': message.trim(),
      'targetUserId': userId,
      'targetUserRole': userRole,
      'receiverName': userName,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': admin?.uid ?? 'admin',
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
      'source': source,
    });

    await batch.commit();
  }

  Future<void> sendNotificationToDonorAndLog({
    required String donorId,
    required String donorName,
    required String title,
    required String message,
    String? email,
  }) {
    return sendNotificationToUserAndLog(
      userId: donorId,
      userRole: 'donor',
      userName: donorName,
      title: title,
      message: message,
      type: 'admin_donor_notification',
      source: 'admin_user_notification',
      email: email,
    );
  }

  Future<void> sendNotificationToNgoAndLog({
    required String ngoId,
    required String ngoName,
    required String title,
    required String message,
    String? email,
  }) {
    return sendNotificationToUserAndLog(
      userId: ngoId,
      userRole: 'ngo',
      userName: ngoName,
      title: title,
      message: message,
      type: 'admin_ngo_notification',
      source: 'admin_user_notification',
      email: email,
    );
  }
}

