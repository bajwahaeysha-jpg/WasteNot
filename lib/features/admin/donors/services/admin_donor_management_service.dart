import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/core/utils/meal_parser.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/notification_service.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/services/user_account_lifecycle_service.dart';

enum DonorStatusFilter { all, active, suspended, deleted }

class AdminManagedDonor {
  const AdminManagedDonor({
    required this.user,
    required this.totalMealsDonated,
    required this.successRate,
    required this.averageRating,
    this.donorType,
    this.city,
    this.about,
  });

  final AppUserModel user;
  final int totalMealsDonated;
  final int successRate;
  final double averageRating;
  final String? donorType;
  final String? city;
  final String? about;

  String get id => user.uid;
  String get name => user.displayName;
  String get email => user.email;
  String get phone => user.phone ?? '';
  String get imageUrl => user.profileImageUrl ?? '';
  bool get isDeleted => user.isDeleted;
  String get statusLabel =>
      isDeleted ? 'Deleted' : (user.isSuspended ? 'Suspended' : 'Active');
  bool get isSuspended => user.isSuspended;
  String get locationLabel => city ?? user.address ?? 'Unknown location';
  String get aboutLabel =>
      about?.trim().isNotEmpty == true
          ? about!.trim()
          : 'No donor description is available right now.';
}

class AdminActivityLogEntry {
  const AdminActivityLogEntry({
    required this.id,
    required this.title,
    required this.message,
    required this.receiver,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String receiver;
  final DateTime createdAt;

  factory AdminActivityLogEntry.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final createdAt = data['createdAt'];
    return AdminActivityLogEntry(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Notification',
      message: (data['message'] as String?) ?? '',
      receiver: (data['receiverName'] as String?) ??
          (data['targetName'] as String?) ??
          'Unknown',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}

class AdminDonorManagementService {
  AdminDonorManagementService({
    FirebaseFirestore? firestore,
    UserAccountLifecycleService? userAccountLifecycleService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userAccountLifecycleService =
            userAccountLifecycleService ?? UserAccountLifecycleService();

  final FirebaseFirestore _firestore;
  final NotificationService _notificationService = NotificationService();
  final UserAccountLifecycleService _userAccountLifecycleService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('feedback');
  CollectionReference<Map<String, dynamic>> get _adminActivityLogs =>
      _firestore.collection('admin_activity_logs');
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  Stream<AdminDonorStats> getDonorStats(String donorId) {
    return _donations
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((snapshot) => _calculateDonorStats(snapshot.docs));
  }

  Stream<List<AdminManagedDonor>> streamDonors({
    DonorStatusFilter filter = DonorStatusFilter.all,
  }) {
    return _users.where('role', isEqualTo: 'donor').snapshots().asyncExpand((
      usersSnapshot,
    ) {
      final donorDocs = usersSnapshot.docs;

      if (donorDocs.isEmpty) {
        return Stream.value(const <AdminManagedDonor>[]);
      }

      final donorStreams = donorDocs.map((doc) {
        return streamManagedDonorLive(doc.id)
            .where((donor) => donor != null)
            .map((donor) => donor!);
      }).toList();

      late StreamController<List<AdminManagedDonor>> controller;
      final latestDonors = <String, AdminManagedDonor>{};
      final subscriptions = <StreamSubscription<AdminManagedDonor>>[];

      void emitDonors() {
        final donors = latestDonors.values
            .where((donor) => _matchesFilter(donor, filter))
            .toList()
          ..sort((a, b) => b.user.createdAt.compareTo(a.user.createdAt));

        controller.add(donors);
      }

      controller = StreamController<List<AdminManagedDonor>>.broadcast(
        onListen: () {
          for (final donorStream in donorStreams) {
            final subscription = donorStream.listen(
              (donor) {
                latestDonors[donor.id] = donor;
                emitDonors();
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

  Stream<AdminManagedDonor?> streamDonorById(String donorId) {
    return streamManagedDonorLive(donorId);
  }

  Stream<AdminManagedDonor?> streamManagedDonorLive(String donorId) {
    late StreamController<AdminManagedDonor?> controller;

    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? feedbackSub;

    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    QuerySnapshot<Map<String, dynamic>>? donationSnapshot;
    QuerySnapshot<Map<String, dynamic>>? feedbackSnapshot;

    Future<void> emitUpdatedDonor() async {
      if (userDoc == null) {
        return;
      }

      if (!userDoc!.exists) {
        controller.add(null);
        return;
      }

      final donor = _buildManagedDonorFromSources(
        userDoc: userDoc!,
        donationDocs: donationSnapshot?.docs ?? const [],
        feedbackDocs: feedbackSnapshot?.docs ?? const [],
      );

      controller.add(donor);
    }

    controller = StreamController<AdminManagedDonor?>.broadcast(
      onListen: () {
        userSub = _users.doc(donorId).snapshots().listen((doc) async {
          userDoc = doc;
          await emitUpdatedDonor();
        });

        donationSub = _donations
            .where('donorId', isEqualTo: donorId)
            .snapshots()
            .listen((snapshot) async {
          donationSnapshot = snapshot;
          await emitUpdatedDonor();
        });

        feedbackSub = _feedback
            .where('donorId', isEqualTo: donorId)
            .snapshots()
            .listen((snapshot) async {
          feedbackSnapshot = snapshot;
          await emitUpdatedDonor();
        });
      },
      onCancel: () async {
        await userSub?.cancel();
        await donationSub?.cancel();
        await feedbackSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<AdminManagedDonor?> fetchDonorById(String donorId) async {
    final doc = await _users.doc(donorId).get();
    if (!doc.exists) {
      return null;
    }

    final feedbackQuery = await _feedback
        .where('donorId', isEqualTo: donorId)
        .get();
    final donationQuery = await _donations
        .where('donorId', isEqualTo: donorId)
        .get();

    return _buildManagedDonorFromSources(
      userDoc: doc,
      donationDocs: donationQuery.docs,
      feedbackDocs: feedbackQuery.docs,
    );
  }

  Future<void> suspendDonor({
    required String donorId,
    required String donorName,
    required String reason,
    String? details,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();
    final userRef = _users.doc(donorId);
    final logRef = _adminActivityLogs.doc();
    final trimmedReason = reason.trim();
    final trimmedDetails = details?.trim();
    final message = trimmedDetails != null && trimmedDetails.isNotEmpty
        ? '$trimmedReason\n$trimmedDetails'
        : trimmedReason;

    batch.set(userRef, {
      'status': 'suspended',
      'isSuspended': true,
      'suspensionReason': trimmedReason,
      'suspensionDetails': trimmedDetails,
      'suspendedAt': FieldValue.serverTimestamp(),
      'suspendedBy': admin?.uid ?? 'admin',
      'suspendedByName': admin?.displayName ?? 'System Admin',
    }, SetOptions(merge: true));

    final canNotify = await _notificationService.isNotificationEnabled(donorId);
    if (canNotify) {
      final notificationRef = _notifications.doc();
      batch.set(notificationRef, {
        'notificationId': notificationRef.id,
        'receiverId': donorId,
        'uid': donorId,
        'donorId': donorId,
        'title': 'Account Suspended',
        'body': message,
        'message': message,
        'type': 'donor_suspension',
        'sentByAdmin': true,
        'read': false,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    batch.set(logRef, {
      'actionType': 'admin_suspended_donor',
      'targetUserId': donorId,
      'receiverName': donorName,
      'title': 'Donor Suspended',
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
    });

    await batch.commit();
  }

  Future<void> unsuspendDonor({
    required String donorId,
    required String donorName,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();
    final userRef = _users.doc(donorId);
    final logRef = _adminActivityLogs.doc();

    batch.set(userRef, {
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

    final canNotify = await _notificationService.isNotificationEnabled(donorId);
    if (canNotify) {
      final notificationRef = _notifications.doc();
      batch.set(notificationRef, {
        'notificationId': notificationRef.id,
        'receiverId': donorId,
        'uid': donorId,
        'donorId': donorId,
        'title': 'Account Re-enabled',
        'body': 'Your donor account has been re-enabled. You can donate again.',
        'message': 'Your donor account has been re-enabled. You can donate again.',
        'type': 'donor_unsuspension',
        'sentByAdmin': true,
        'read': false,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    batch.set(logRef, {
      'actionType': 'admin_unsuspended_donor',
      'targetUserId': donorId,
      'receiverName': donorName,
      'title': 'Donor Re-enabled',
      'message': 'Admin restored donor access.',
      'createdAt': FieldValue.serverTimestamp(),
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
    });

    await batch.commit();
  }

  Future<void> deleteDonorAccount({
    required String donorId,
    required String donorName,
  }) async {
    await _userAccountLifecycleService.adminDeleteUserAccount(
      uid: donorId,
      role: 'donor',
    );
  }

  Future<void> sendNotificationToDonor({
    required String donorId,
    required String donorName,
    required String title,
    required String message,
  }) async {
    final admin = SessionService.user;
    final batch = _firestore.batch();
    final logRef = _adminActivityLogs.doc();

    final canNotify = await _notificationService.isNotificationEnabled(donorId);
    if (canNotify) {
      final notificationRef = _notifications.doc();
      batch.set(notificationRef, {
        'notificationId': notificationRef.id,
        'receiverId': donorId,
        'uid': donorId,
        'donorId': donorId,
        'title': title.trim(),
        'body': message.trim(),
        'message': message.trim(),
        'type': 'admin_donor_notification',
        'sentByAdmin': true,
        'read': false,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    batch.set(logRef, {
      'actionType': 'admin_sent_notification',
      'targetUserId': donorId,
      'receiverName': donorName,
      'title': title.trim(),
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'adminId': admin?.uid ?? 'admin',
      'adminName': admin?.displayName ?? 'System Admin',
    });

    await batch.commit();
  }

  Stream<List<AdminActivityLogEntry>> streamAdminActivityLogs() {
    return _adminActivityLogs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(AdminActivityLogEntry.fromFirestore).toList(),
        );
  }

  AdminManagedDonor _buildManagedDonorFromSources({
    required DocumentSnapshot<Map<String, dynamic>> userDoc,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> feedbackDocs,
  }) {
    final user = AppUserModel.fromFirestore(userDoc);
    final data = userDoc.data() ?? <String, dynamic>{};

    final ratings = feedbackDocs
        .map((item) => item.data()['rating'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();

    final averageRating = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    final stats = _calculateDonorStats(donationDocs);

    final status = (data['status'] as String?)?.trim().toLowerCase() ?? 'active';
    final deleted = status == 'deleted' || (data['isActive'] as bool?) == false;
    final suspended =
        !deleted &&
        ((data['isSuspended'] as bool?) ?? status == 'suspended');

    final normalizedUser = user.copyWith(
      status: deleted ? 'deleted' : (suspended ? 'suspended' : status),
      isActive: !deleted,
      isSuspended: suspended,
    );

    return AdminManagedDonor(
      user: normalizedUser,
      totalMealsDonated: stats.totalMeals,
      successRate: stats.successRate,
      averageRating: averageRating,
      donorType: _stringValue(data, const [
        'donorType',
        'businessType',
        'category',
        'type',
      ]),
      city: _stringValue(data, const ['city', 'location', 'address']),
      about: _stringValue(data, const [
        'about',
        'description',
        'bio',
        'organizationDescription',
      ]),
    );
  }

  bool _matchesFilter(AdminManagedDonor donor, DonorStatusFilter filter) {
    switch (filter) {
      case DonorStatusFilter.active:
        return !donor.isDeleted && !donor.isSuspended;
      case DonorStatusFilter.suspended:
        return !donor.isDeleted && donor.isSuspended;
      case DonorStatusFilter.deleted:
        return donor.isDeleted;
      case DonorStatusFilter.all:
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

  bool _isAcceptedDonationForSuccess(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'accepted' ||
        normalized == 'completed' ||
        normalized == 'not_completed';
  }

  AdminDonorStats _calculateDonorStats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs,
  ) {
    var totalMeals = 0;
    var acceptedCount = 0;
    var completedCount = 0;

    for (final donationDoc in donationDocs) {
      final donation = donationDoc.data();
      totalMeals += _mealCountFromDonation(donation);

      if (_isAcceptedDonationForSuccess(donation['status'])) {
        acceptedCount += 1;
      }
      if (_isCompletedDonation(donation['status'])) {
        completedCount += 1;
      }
    }

    final successRate = acceptedCount == 0
        ? 0
        : ((completedCount / acceptedCount) * 100).round();

    return AdminDonorStats(
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

class AdminDonorStats {
  const AdminDonorStats({
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
