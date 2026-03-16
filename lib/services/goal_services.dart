import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';

class MonthlyGoal {
  const MonthlyGoal({
    required this.uid,
    required this.role,
    required this.monthlyTarget,
    required this.achievedCount,
    required this.createdAt,
    required this.updatedAt,
    required this.monthKey,
  });

  final String uid;
  final String role;
  final int monthlyTarget;
  final int achievedCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String monthKey;

  MonthlyGoal copyWith({
    String? uid,
    String? role,
    int? monthlyTarget,
    int? achievedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? monthKey,
  }) {
    return MonthlyGoal(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      achievedCount: achievedCount ?? this.achievedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      monthKey: monthKey ?? this.monthKey,
    );
  }

  Map<String, dynamic> toFirestore({
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'uid': uid,
      'role': role,
      'monthlyTarget': monthlyTarget,
      'achievedCount': achievedCount,
      'createdAt': Timestamp.fromDate(createdAt ?? this.createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? this.updatedAt),
      'monthKey': monthKey,
    };
  }

  factory MonthlyGoal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = _dateFromFirestore(data['createdAt']) ?? DateTime.now();
    final updatedAt = _dateFromFirestore(data['updatedAt']) ?? createdAt;

    return MonthlyGoal(
      uid: (data['uid'] as String?)?.trim() ?? doc.id,
      role: (data['role'] as String?)?.trim() ?? 'donor',
      monthlyTarget: _toInt(data['monthlyTarget']),
      achievedCount: _toInt(data['achievedCount']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      monthKey: (data['monthKey'] as String?)?.trim() ?? '',
    );
  }
}

class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.achievedCount,
    required this.donationsCount,
    required this.monthKey,
  });

  final MonthlyGoal? goal;
  final int achievedCount;
  final int donationsCount;
  final String monthKey;

  int get monthlyTarget => goal?.monthlyTarget ?? 0;
  bool get hasGoal => monthlyTarget > 0;
}

class GoalService {
  GoalService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection('monthly_goals');
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  String currentMonthKey([DateTime? date]) {
    return _monthKey(date ?? DateTime.now());
  }

  Future<MonthlyGoal> saveDonorGoal({
    required AppUserModel donor,
    required int monthlyTarget,
  }) {
    if (!donor.isDonor) {
      throw const GoalException('Only donor accounts can set donor goals.');
    }
    return _saveGoal(user: donor, monthlyTarget: monthlyTarget);
  }

  Future<MonthlyGoal> saveNgoGoal({
    required AppUserModel ngo,
    required int monthlyTarget,
  }) {
    if (!ngo.isNgo) {
      throw const GoalException('Only NGO accounts can set NGO goals.');
    }
    return _saveGoal(user: ngo, monthlyTarget: monthlyTarget);
  }

  Future<MonthlyGoal?> getCurrentUserMonthlyGoal({
    required AppUserModel user,
    DateTime? now,
  }) async {
    final monthKey = _monthKey(now ?? DateTime.now());
    final doc = await _goalDoc(user.uid, monthKey).get();
    if (!doc.exists) {
      return null;
    }
    return MonthlyGoal.fromFirestore(doc);
  }

  Stream<MonthlyGoal?> streamCurrentUserMonthlyGoal({
    required AppUserModel user,
    DateTime? now,
  }) {
    final monthKey = _monthKey(now ?? DateTime.now());
    return _goalDoc(user.uid, monthKey).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return MonthlyGoal.fromFirestore(doc);
    });
  }

  Stream<GoalProgress> streamCurrentUserMonthlyGoalProgress({
    required AppUserModel user,
  }) {
    final controller = StreamController<GoalProgress>();
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? goalSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationSub;
    MonthlyGoal? latestGoal;
    int latestAchieved = 0;
    int latestDonationsCount = 0;

    void emit() {
      controller.add(
        GoalProgress(
          goal: latestGoal,
          achievedCount: latestAchieved,
          donationsCount: latestDonationsCount,
          monthKey: currentMonthKey(),
        ),
      );
    }

    controller.onListen = () async {
      await resetOrCreateMonthlyGoalIfNeeded(user: user);
      final monthKey = currentMonthKey();

      goalSub = _goalDoc(user.uid, monthKey).snapshots().listen((doc) {
        latestGoal = doc.exists ? MonthlyGoal.fromFirestore(doc) : null;
        emit();
      }, onError: controller.addError);

      Query<Map<String, dynamic>> donationQuery =
          _donations.where('status', isEqualTo: DonationStatus.completed.value);
      if (user.isDonor) {
        donationQuery = donationQuery.where('donorId', isEqualTo: user.uid);
      } else if (user.isNgo) {
        donationQuery =
            donationQuery.where('acceptedByNgoId', isEqualTo: user.uid);
      }

      donationSub = donationQuery.snapshots().listen((snapshot) async {
        final donations =
            snapshot.docs.map(DonationModel.fromFirestore).toList();
        final progress = _calculateProgressForMonth(
          user: user,
          donations: donations,
          now: DateTime.now(),
        );
        latestAchieved = progress.achievedCount;
        latestDonationsCount = progress.donationsCount;
        emit();
        if (latestGoal != null &&
            latestGoal!.achievedCount != latestAchieved) {
          await updateAchievedCount(
            user: user,
            achievedCount: latestAchieved,
            monthKey: latestGoal!.monthKey,
          );
        }
      }, onError: controller.addError);
    };

    controller.onCancel = () async {
      await goalSub?.cancel();
      await donationSub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Future<void> updateAchievedCount({
    required AppUserModel user,
    required int achievedCount,
    String? monthKey,
  }) async {
    final effectiveMonthKey = monthKey ?? currentMonthKey();
    final docRef = _goalDoc(user.uid, effectiveMonthKey);
    final now = DateTime.now();
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'role': user.role,
        'monthKey': effectiveMonthKey,
        'monthlyTarget': 0,
        'achievedCount': achievedCount,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      return;
    }

    await docRef.update({
      'achievedCount': achievedCount,
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> incrementDonorAchievedCount({
    required String uid,
    int delta = 1,
    DateTime? now,
  }) {
    return _incrementAchievedCount(
      uid: uid,
      role: 'donor',
      delta: delta,
      now: now,
    );
  }

  Future<void> incrementNgoAchievedCount({
    required String uid,
    int delta = 1,
    DateTime? now,
  }) {
    return _incrementAchievedCount(
      uid: uid,
      role: 'ngo',
      delta: delta,
      now: now,
    );
  }

  Future<MonthlyGoal> resetOrCreateMonthlyGoalIfNeeded({
    required AppUserModel user,
    DateTime? now,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    final monthKey = _monthKey(effectiveNow);
    final docRef = _goalDoc(user.uid, monthKey);
    final doc = await docRef.get();

    if (doc.exists) {
      return MonthlyGoal.fromFirestore(doc);
    }

    final achievedCount = await _computeAchievedCountForUser(
      user: user,
      now: effectiveNow,
    );

    final payload = MonthlyGoal(
      uid: user.uid,
      role: user.role,
      monthlyTarget: 0,
      achievedCount: achievedCount,
      createdAt: effectiveNow,
      updatedAt: effectiveNow,
      monthKey: monthKey,
    );

    await docRef.set(payload.toFirestore());
    return payload;
  }

  Future<MonthlyGoal> _saveGoal({
    required AppUserModel user,
    required int monthlyTarget,
  }) async {
    if (monthlyTarget <= 0) {
      throw const GoalException('Monthly target must be greater than zero.');
    }

    final now = DateTime.now();
    final monthKey = _monthKey(now);
    final docRef = _goalDoc(user.uid, monthKey);
    final existing = await docRef.get();

    MonthlyGoal goal;
    if (existing.exists) {
      final previous = MonthlyGoal.fromFirestore(existing);
      goal = previous.copyWith(
        monthlyTarget: monthlyTarget,
        updatedAt: now,
      );
    } else {
      final achievedCount = await _computeAchievedCountForUser(
        user: user,
        now: now,
      );
      goal = MonthlyGoal(
        uid: user.uid,
        role: user.role,
        monthlyTarget: monthlyTarget,
        achievedCount: achievedCount,
        createdAt: now,
        updatedAt: now,
        monthKey: monthKey,
      );
    }

    await docRef.set(goal.toFirestore());
    return goal;
  }

  Future<void> _incrementAchievedCount({
    required String uid,
    required String role,
    required int delta,
    DateTime? now,
  }) async {
    if (delta == 0) {
      return;
    }

    final effectiveNow = now ?? DateTime.now();
    final monthKey = _monthKey(effectiveNow);
    final docRef = _goalDoc(uid, monthKey);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'uid': uid,
          'role': role,
          'monthKey': monthKey,
          'monthlyTarget': 0,
          'achievedCount': delta,
          'createdAt': Timestamp.fromDate(effectiveNow),
          'updatedAt': Timestamp.fromDate(effectiveNow),
        });
        return;
      }

      transaction.update(docRef, {
        'achievedCount': FieldValue.increment(delta),
        'updatedAt': Timestamp.fromDate(effectiveNow),
      });
    });
  }

  Future<int> _computeAchievedCountForUser({
    required AppUserModel user,
    required DateTime now,
  }) async {
    Query<Map<String, dynamic>> query =
        _donations.where('status', isEqualTo: DonationStatus.completed.value);

    if (user.isDonor) {
      query = query.where('donorId', isEqualTo: user.uid);
    } else if (user.isNgo) {
      query = query.where('acceptedByNgoId', isEqualTo: user.uid);
    }

    final snapshot = await query.get();
    final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
    final progress = _calculateProgressForMonth(
      user: user,
      donations: donations,
      now: now,
    );
    return progress.achievedCount;
  }

  GoalProgress _calculateProgressForMonth({
    required AppUserModel user,
    required List<DonationModel> donations,
    required DateTime now,
  }) {
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);

    final monthlyDonations = donations.where((donation) {
      if (donation.status != DonationStatus.completed.value) {
        return false;
      }
      if (user.isDonor && donation.donorId != user.uid) {
        return false;
      }
      if (user.isNgo && donation.acceptedByNgoId != user.uid) {
        return false;
      }

      final completedAt = donation.completedAt ?? donation.createdAt;
      if (completedAt.isBefore(start)) {
        return false;
      }
      return completedAt.isBefore(end);
    }).toList();

    final achievedCount = monthlyDonations.fold<int>(
      0,
      (sum, donation) => sum + _parseServingCount(donation.quantity),
    );

    return GoalProgress(
      goal: null,
      achievedCount: achievedCount,
      donationsCount: monthlyDonations.length,
      monthKey: _monthKey(now),
    );
  }

  DocumentReference<Map<String, dynamic>> _goalDoc(
    String uid,
    String monthKey,
  ) {
    return _goals.doc('${uid}_$monthKey');
  }
}

class GoalException implements Exception {
  const GoalException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _monthKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}

DateTime? _dateFromFirestore(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

int _parseServingCount(String quantity) {
  final trimmed = quantity.trim();
  if (trimmed.isEmpty) {
    return 0;
  }

  final lower = trimmed.toLowerCase();
  final matches = RegExp(r'\d+').allMatches(lower).toList();
  if (matches.isEmpty) {
    return 0;
  }

  if (lower.contains('more than')) {
    return int.parse(matches.last.group(0)!);
  }

  if (lower.contains('-') && matches.length >= 2) {
    return int.parse(matches.last.group(0)!);
  }

  return int.parse(matches.first.group(0)!);
}
