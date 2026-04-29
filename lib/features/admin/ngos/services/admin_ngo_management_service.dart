import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/core/utils/meal_parser.dart';
import 'package:wastenot/features/admin/shared/services/admin_user_notification_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/notification_service.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/services/user_account_lifecycle_service.dart';

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
    UserAccountLifecycleService? userAccountLifecycleService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService =
            notificationService ??
                AdminUserNotificationService(firestore: firestore),
        _userAccountLifecycleService =
            userAccountLifecycleService ?? UserAccountLifecycleService();

  final FirebaseFirestore _firestore;
  final AdminUserNotificationService _notificationService;
  final NotificationService _notificationGate = NotificationService();
  final UserAccountLifecycleService _userAccountLifecycleService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _adminActivityLogs =>
      _firestore.collection('admin_activity_logs');
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  Stream<AdminNgoStats> getNgoStats(String ngoId) {
    return _streamNgoDonationDocs(ngoId).map(_calculateNgoStats);
  }

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
    StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
        donationSub;

    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs = const [];

    Future<void> emitUpdatedNgo() async {
      if (userDoc == null) return;

      if (!userDoc!.exists) {
        controller.add(null);
        return;
      }

      final ngo = _buildManagedNgoFromSources(
        userDoc: userDoc!,
        donationDocs: donationDocs,
      );

      controller.add(ngo);
    }

    controller = StreamController<AdminManagedNgo?>.broadcast(
      onListen: () {
        userSub = _users.doc(ngoId).snapshots().listen((doc) async {
          userDoc = doc;
          await emitUpdatedNgo();
        });

        donationSub = _streamNgoDonationDocs(ngoId).listen((snapshotDocs) async {
          donationDocs = snapshotDocs;
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

  Future<void> deleteNgoAccount({
    required String ngoId,
    required String ngoName,
  }) async {
    await _userAccountLifecycleService.adminDeleteUserAccount(
      uid: ngoId,
      role: 'ngo',
    );
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
    final stats = _calculateNgoStats(donationDocs);

    final status = (data['status'] as String?)?.toLowerCase();
    final suspended = (data['isSuspended'] as bool?) ?? status == 'suspended';

    final normalizedUser = user.copyWith(
      status: suspended ? 'suspended' : (status ?? 'active'),
      isSuspended: suspended,
    );

    return AdminManagedNgo(
      user: normalizedUser,
      totalMealsReceived: stats.totalMeals,
      successRate: stats.successRate,
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
    for (final key in const [
      'servings',
      'quantity',
      'meals',
      'mealCount',
      'totalMeals',
    ]) {
      final parsed = parseMealValue(donation[key]);
      if (parsed > 0) {
        return parsed;
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

  bool _isMealEligibleForNgo(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'accepted' || normalized == 'completed';
  }

  bool _isAcceptedDonationForSuccess(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'accepted' ||
        normalized == 'completed' ||
        normalized == 'not_completed';
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _streamNgoDonationDocs(
    String ngoId,
  ) {
    late StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
        controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? acceptedBySub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? legacyNgoSub;
    var acceptedByDocs = const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var legacyNgoDocs = const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    void emit() {
      final merged = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final doc in acceptedByDocs) {
        merged[doc.id] = doc;
      }
      for (final doc in legacyNgoDocs) {
        merged[doc.id] = doc;
      }
      controller.add(merged.values.toList());
    }

    controller = StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>.broadcast(
      onListen: () {
        acceptedBySub = _donations
            .where('acceptedByNgoId', isEqualTo: ngoId)
            .snapshots()
            .listen((snapshot) {
          acceptedByDocs = snapshot.docs;
          emit();
        }, onError: controller.addError);

        legacyNgoSub = _donations
            .where('ngoId', isEqualTo: ngoId)
            .snapshots()
            .listen((snapshot) {
          legacyNgoDocs = snapshot.docs;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await acceptedBySub?.cancel();
        await legacyNgoSub?.cancel();
      },
    );

    return controller.stream;
  }

  AdminNgoStats _calculateNgoStats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs,
  ) {
    var totalMeals = 0;
    var acceptedCount = 0;
    var completedCount = 0;

    for (final donationDoc in donationDocs) {
      final donation = donationDoc.data();
      final status = donation['status'];

      if (_isMealEligibleForNgo(status)) {
        totalMeals += _mealCountFromDonation(donation);
      }
      if (_isAcceptedDonationForSuccess(status)) {
        acceptedCount += 1;
      }
      if (_isCompletedDonation(status)) {
        completedCount += 1;
      }
    }

    final successRate = acceptedCount == 0
        ? 0
        : ((completedCount / acceptedCount) * 100).round();

    return AdminNgoStats(
      totalMeals: totalMeals,
      acceptedCount: acceptedCount,
      completedCount: completedCount,
      successRate: successRate,
    );
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

class AdminNgoStats {
  const AdminNgoStats({
    required this.totalMeals,
    required this.acceptedCount,
    required this.completedCount,
    required this.successRate,
  });

  final int totalMeals;
  final int acceptedCount;
  final int completedCount;
  final int successRate;
}

