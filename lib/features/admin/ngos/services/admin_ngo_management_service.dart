import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/features/admin/shared/services/admin_user_notification_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/notification_service.dart';
import 'package:wastenot/services/session_service.dart';

enum NgoStatusFilter { all, active, suspended }

class AdminManagedNgo {
  const AdminManagedNgo({
    required this.user,
    required this.totalMealsReceived,
    required this.successRate,
    this.city,
    this.about,
  });

  final AppUserModel user;
  final int totalMealsReceived;
  final int successRate;
  final String? city;
  final String? about;

  String get id => user.uid;
  String get name => user.displayName;
  String get email => user.email;
  String get phone => user.phone ?? '';
  String get imageUrl => user.profileImageUrl ?? '';
  bool get isSuspended => user.isSuspended;
  String get statusLabel => isSuspended ? 'Suspended' : 'Active';
  String get locationLabel => city ?? user.address ?? 'Unknown location';
  String get aboutLabel =>
      about?.trim().isNotEmpty == true
          ? about!.trim()
          : 'No NGO description is available right now.';
}

class AdminNgoManagementService {
  AdminNgoManagementService({
    FirebaseFirestore? firestore,
    AdminUserNotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService =
            notificationService ??
                AdminUserNotificationService(firestore: firestore);

  final FirebaseFirestore _firestore;
  final AdminUserNotificationService _notificationService;
  final NotificationService _notificationGate = NotificationService();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _adminActivityLogs =>
      _firestore.collection('admin_activity_logs');
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  Stream<List<AdminManagedNgo>> streamNgos({
    NgoStatusFilter filter = NgoStatusFilter.all,
  }) {
    return _users.where('role', isEqualTo: 'ngo').snapshots().asyncExpand((
      usersSnapshot,
    ) {
      final ngoDocs = usersSnapshot.docs;

      if (ngoDocs.isEmpty) {
        return Stream.value(const <AdminManagedNgo>[]);
      }

      final ngoStreams = ngoDocs.map((doc) {
        return streamManagedNgoLive(doc.id)
            .where((ngo) => ngo != null)
            .map((ngo) => ngo!);
      }).toList();

      late StreamController<List<AdminManagedNgo>> controller;
      final latestNgos = <String, AdminManagedNgo>{};
      final subscriptions = <StreamSubscription<AdminManagedNgo>>[];

      void emitNgos() {
        final ngos = latestNgos.values
            .where((ngo) => _matchesFilter(ngo, filter))
            .toList()
          ..sort((a, b) => b.user.createdAt.compareTo(a.user.createdAt));

        controller.add(ngos);
      }

      controller = StreamController<List<AdminManagedNgo>>.broadcast(
        onListen: () {
          for (final ngoStream in ngoStreams) {
            final subscription = ngoStream.listen(
              (ngo) {
                latestNgos[ngo.id] = ngo;
                emitNgos();
              },
              onError: controller.addError,
            );
            subscriptions.add(subscription);
          }
        },
        onCancel: () async {
          for (final subscription in subscriptions) {
            await subscription.cancel();
          }
        },
      );

      return controller.stream;
    });
  }

  Stream<AdminManagedNgo?> streamNgoById(String ngoId) {
    return streamManagedNgoLive(ngoId);
  }

  Stream<AdminManagedNgo?> streamManagedNgoLive(String ngoId) {
    late StreamController<AdminManagedNgo?> controller;

    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationSub;

    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    QuerySnapshot<Map<String, dynamic>>? donationSnapshot;

    Future<void> emitUpdatedNgo() async {
      if (userDoc == null) return;

      if (!userDoc!.exists) {
        controller.add(null);
        return;
      }

      final ngo = _buildManagedNgoFromSources(
        userDoc: userDoc!,
        donationDocs: donationSnapshot?.docs ?? const [],
      );

      controller.add(ngo);
    }

    controller = StreamController<AdminManagedNgo?>.broadcast(
      onListen: () {
        userSub = _users.doc(ngoId).snapshots().listen((doc) async {
          userDoc = doc;
          await emitUpdatedNgo();
        });

        // Assumption: donations store the assigned/accepted NGO id in `ngoId`.
        donationSub = _donations
            .where('ngoId', isEqualTo: ngoId)
            .snapshots()
            .listen((snapshot) async {
          donationSnapshot = snapshot;
          await emitUpdatedNgo();
        });
      },
      onCancel: () async {
        await userSub?.cancel();
        await donationSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> suspendNgo({
    required String ngoId,
    required String ngoName,
    required String reason,
    String? details,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();
    final userRef = _users.doc(ngoId);
    final logRef = _adminActivityLogs.doc();
    final trimmedReason = reason.trim();
    final trimmedDetails = details?.trim();
    final message = trimmedDetails != null && trimmedDetails.isNotEmpty
        ? '$trimmedReason\n$trimmedDetails'
        : trimmedReason;

    batch.set(userRef, <String, dynamic>{
      'status': 'suspended',
      'isSuspended': true,
      'suspensionReason': trimmedReason,
      'suspensionDetails': trimmedDetails,
      'suspendedAt': FieldValue.serverTimestamp(),
      'suspendedBy': admin?.uid ?? 'admin',
      'suspendedByName': admin?.displayName ?? 'System Admin',
    }, SetOptions(merge: true));

    final canNotify = await _notificationGate.isNotificationEnabled(ngoId);
    if (canNotify) {
      _notificationService.addUserNotificationToBatch(
        batch: batch,
        userId: ngoId,
        userRole: 'ngo',
        title: 'Account Suspended',
        message: message,
        type: 'ngo_suspension',
        source: 'admin_ngo_management',
      );
    }

    batch.set(logRef, <String, dynamic>{
      'activityId': logRef.id,
      'actionType': 'admin_suspended_ngo',
      'type': 'ngo_suspension',
      'targetUserId': ngoId,
      'targetUserRole': 'ngo',
      'receiverName': ngoName,
      'title': 'NGO Suspended',
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': admin?.uid ?? 'admin',
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
      'source': 'admin_ngo_management',
    });

    await batch.commit();
  }

  Future<void> unsuspendNgo({
    required String ngoId,
    required String ngoName,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();
    final userRef = _users.doc(ngoId);
    final logRef = _adminActivityLogs.doc();

    batch.set(userRef, <String, dynamic>{
      'status': 'active',
      'isSuspended': false,
      'suspensionReason': FieldValue.delete(),
      'suspensionDetails': FieldValue.delete(),
      'suspendedAt': FieldValue.delete(),
      'suspendedBy': FieldValue.delete(),
      'suspendedByName': FieldValue.delete(),
      'unsuspendedAt': FieldValue.serverTimestamp(),
      'unsuspendedBy': admin?.uid ?? 'admin',
    }, SetOptions(merge: true));

    final canNotify = await _notificationGate.isNotificationEnabled(ngoId);
    if (canNotify) {
      _notificationService.addUserNotificationToBatch(
        batch: batch,
        userId: ngoId,
        userRole: 'ngo',
        title: 'Account Re-enabled',
        message:
            'Your NGO account has been re-enabled. You can use the app again.',
        type: 'ngo_unsuspension',
        source: 'admin_ngo_management',
      );
    }

    batch.set(logRef, <String, dynamic>{
      'activityId': logRef.id,
      'actionType': 'admin_unsuspended_ngo',
      'type': 'ngo_unsuspension',
      'targetUserId': ngoId,
      'targetUserRole': 'ngo',
      'receiverName': ngoName,
      'title': 'NGO Re-enabled',
      'message': 'Admin restored NGO access.',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': admin?.uid ?? 'admin',
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
      'source': 'admin_ngo_management',
    });

    await batch.commit();
  }

  Future<void> sendNotificationToNgo({
    required String ngoId,
    required String ngoName,
    required String title,
    required String message,
  }) {
    return _notificationService.sendNotificationToNgoAndLog(
      ngoId: ngoId,
      ngoName: ngoName,
      title: title,
      message: message,
    );
  }

  AdminManagedNgo _buildManagedNgoFromSources({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs,
  }) {
    final user = AppUserModel.fromFirestore(userDoc);
    final data = userDoc.data() ?? <String, dynamic>{};

    var totalMeals = 0;
    var completed = 0;
    final totalDonations = donationDocs.length;

    for (final donationDoc in donationDocs) {
      final donation = donationDoc.data();
      totalMeals += _mealCountFromDonation(donation);
      if (_isCompletedDonation(donation['status'])) {
        completed += 1;
      }
    }

    // Reasonable default formula: completed / total donations.
    final successRate = totalDonations == 0
        ? 0
        : ((completed / totalDonations) * 100).round();

    final status = (data['status'] as String?)?.toLowerCase();
    final suspended = (data['isSuspended'] as bool?) ?? status == 'suspended';

    final normalizedUser = user.copyWith(
      status: suspended ? 'suspended' : (status ?? 'active'),
      isSuspended: suspended,
    );

    return AdminManagedNgo(
      user: normalizedUser,
      totalMealsReceived: totalMeals,
      successRate: successRate,
      city: _stringValue(data, const ['city', 'location', 'address']),
      about: _stringValue(data, const [
        'about',
        'description',
        'bio',
        'organizationDescription',
      ]),
    );
  }

  bool _matchesFilter(AdminManagedNgo ngo, NgoStatusFilter filter) {
    switch (filter) {
      case NgoStatusFilter.active:
        return !ngo.isSuspended;
      case NgoStatusFilter.suspended:
        return ngo.isSuspended;
      case NgoStatusFilter.all:
        return true;
    }
  }

  int _mealCountFromDonation(Map<String, dynamic> donation) {
    for (final key in const ['servings', 'meals', 'mealCount', 'totalMeals']) {
      final value = donation[key];
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  bool _isCompletedDonation(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'completed' ||
        normalized == 'picked_up' ||
        normalized == 'pickedup' ||
        normalized == 'delivered' ||
        normalized == 'success';
  }

  String? _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

