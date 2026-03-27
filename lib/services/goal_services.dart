import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';

class MonthlyGoal {
  const MonthlyGoal({
    required this.userId,
    required this.role,
    required this.month,
    required this.targetMeals,
    required this.createdAt,
    this.displayDays,
    this.monthEndNotificationSentAt,
  });

  final String userId;
  final String role;
  final String month;
  final int targetMeals;
  final DateTime createdAt;
  final int? displayDays;
  final DateTime? monthEndNotificationSentAt;

  String get documentId => '${userId}_$month';

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'role': role,
      'month': month,
      'targetMeals': targetMeals,
      'createdAt': Timestamp.fromDate(createdAt),
      'displayDays': displayDays,
      'monthEndNotificationSentAt': monthEndNotificationSentAt == null
          ? null
          : Timestamp.fromDate(monthEndNotificationSentAt!),
    };
  }

  factory MonthlyGoal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final month = _readMonth(data, fallback: '');
    final userId = _readUserId(data, fallback: doc.id.split('_').first);

    return MonthlyGoal(
      userId: userId,
      role: _readRole(data, fallback: 'donor'),
      month: month,
      targetMeals: _toInt(data['targetMeals'] ?? data['monthlyTarget']),
      createdAt: _dateFromFirestore(data['createdAt']) ?? DateTime.now(),
      displayDays: _nullableInt(data['displayDays']),
      monthEndNotificationSentAt:
          _dateFromFirestore(data['monthEndNotificationSentAt']),
    );
  }
}

class GoalProgress {
  const GoalProgress({
    required this.month,
    required this.goal,
    required this.achievedCount,
    required this.isLoading,
  });

  final String month;
  final MonthlyGoal? goal;
  final int achievedCount;
  final bool isLoading;
  

  bool get hasGoal => goal != null && goal!.month == month;
  int get targetMeals => goal?.targetMeals ?? 0;
  int get monthlyTarget => targetMeals;
  int? get displayDays => goal?.displayDays;
  double get completionRatio {
    if (targetMeals <= 0) {
      return 0;
    }
    return achievedCount / targetMeals;
  }

  int get completionPercent {
    if (targetMeals <= 0) {
      return 0;
    }
    return (completionRatio * 100).round();
  }
}

class GoalService {
  GoalService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String goalsCollection = 'goals';
  static const Duration _monthCheckInterval = Duration(minutes: 1);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection(goalsCollection);
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  String currentMonthKey([DateTime? date]) => _monthKey(date ?? DateTime.now());

  String currentMonthLabel([DateTime? date]) {
    final effectiveDate = date ?? DateTime.now();
    return DateFormat('MMMM').format(effectiveDate);
  }

  Future<MonthlyGoal?> getCurrentUserMonthlyGoal({
    required AppUserModel user,
    DateTime? now,
  }) async {
    final month = currentMonthKey(now);
    final doc = await _goalDoc(user.uid, month).get();
    if (!doc.exists) {
      return null;
    }

    final goal = MonthlyGoal.fromFirestore(doc);
    if (goal.month != month || goal.targetMeals <= 0) {
      return null;
    }
    return goal;
  }

  Stream<MonthlyGoal?> streamCurrentUserMonthlyGoal({
    required AppUserModel user,
  }) {
    return _monthTicker().asyncExpand((month) {
      return _goalDoc(user.uid, month).snapshots().map((doc) {
        if (!doc.exists) {
          return null;
        }
        final goal = MonthlyGoal.fromFirestore(doc);
        if (goal.month != month || goal.targetMeals <= 0) {
          return null;
        }
        return goal;
      });
    });
  }

  Stream<GoalProgress> streamCurrentUserMonthlyGoalProgress({
    required AppUserModel user,
  }) {
    late StreamController<GoalProgress> controller;
    StreamSubscription<String>? monthSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? goalSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationSub;

    var activeMonth = currentMonthKey();
    MonthlyGoal? latestGoal;
    GoalProgress? lastEmitted;
    var achievedCount = 0;
    var goalLoaded = false;
    var donationsLoaded = false;

    void emit() {
  final newData = GoalProgress(
    month: activeMonth,
    goal: latestGoal,
    achievedCount: achievedCount,
    isLoading: !(goalLoaded && donationsLoaded),
  );

  // 👇 MAGIC LINE (IMPORTANT)
  if (newData.goal == null && lastEmitted != null) {
    controller.add(lastEmitted!);
    return;
  }

  lastEmitted = newData;
  controller.add(newData);
}

    Future<void> bindMonth(String month) async {
      
activeMonth = month;
latestGoal = null;
achievedCount = 0;
goalLoaded = false;
donationsLoaded = false;


      await goalSub?.cancel();
      await donationSub?.cancel();

      goalSub = _goalDoc(user.uid, month).snapshots().listen(
        (doc) {
          if (!doc.exists) {
            latestGoal = null;
          } else {
            final goal = MonthlyGoal.fromFirestore(doc);
            latestGoal = goal.month == month && goal.targetMeals > 0 ? goal : null;
          }
          goalLoaded = true;
          emit();
        },
        onError: controller.addError,
      );

      final start = _monthStartFromKey(month);
      final end = _monthEndFromKey(month);

      Query<Map<String, dynamic>> query = _donations
          .where('status', isEqualTo: DonationStatus.completed.value)
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'completedAt',
            isLessThan: Timestamp.fromDate(end),
          );

      if (user.isDonor) {
        query = query.where('donorId', isEqualTo: user.uid);
      } else if (user.isNgo) {
        query = query.where('acceptedByNgoId', isEqualTo: user.uid);
      }

      donationSub = query.snapshots().listen(
        (snapshot) {
          final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
          achievedCount = _calculateAchievedCount(user: user, donations: donations);
          donationsLoaded = true;
          emit();
        },
        onError: controller.addError,
      );
    }

    controller = StreamController<GoalProgress>.broadcast(
      onListen: () {
        monthSub = _monthTicker().listen(
          (month) {
            unawaited(bindMonth(month));
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await monthSub?.cancel();
        await goalSub?.cancel();
        await donationSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<MonthlyGoal> saveDonorGoal({
    required AppUserModel donor,
    required int targetMeals,
    int? displayDays,
  }) {
    if (!donor.isDonor) {
      throw const GoalException('Only donor accounts can set donor goals.');
    }

    return _createGoal(
      user: donor,
      targetMeals: targetMeals,
      displayDays: displayDays,
    );
  }
  
Future<GoalProgress> getCurrentUserMonthlyGoalProgressOnce({
  required AppUserModel user,
}) async {
  final month = currentMonthKey();

  final goalDoc = await _goalDoc(user.uid, month).get();
  MonthlyGoal? goal;

  if (goalDoc.exists) {
    final g = MonthlyGoal.fromFirestore(goalDoc);
    if (g.month == month && g.targetMeals > 0) {
      goal = g;
    }
  }

  final start = _monthStartFromKey(month);
  final end = _monthEndFromKey(month);

  Query<Map<String, dynamic>> query = _donations
      .where('status', isEqualTo: DonationStatus.completed.value)
      .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('completedAt', isLessThan: Timestamp.fromDate(end));

  if (user.isDonor) {
    query = query.where('donorId', isEqualTo: user.uid);
  } else if (user.isNgo) {
    query = query.where('acceptedByNgoId', isEqualTo: user.uid);
  }

  final snapshot = await query.get();
  final donations =
      snapshot.docs.map(DonationModel.fromFirestore).toList();

  final achieved = _calculateAchievedCount(
    user: user,
    donations: donations,
  );

  return GoalProgress(
    month: month,
    goal: goal,
    achievedCount: achieved,
    isLoading: false,
  );
}
  Future<MonthlyGoal> saveNgoGoal({
    required AppUserModel ngo,
    required int targetMeals,
    int? displayDays,
  }) {
    if (!ngo.isNgo) {
      throw const GoalException('Only NGO accounts can set NGO goals.');
    }

    return _createGoal(
      user: ngo,
      targetMeals: targetMeals,
      displayDays: displayDays,
    );
  }

  Future<MonthlyGoal> _createGoal({
    required AppUserModel user,
    required int targetMeals,
    int? displayDays,
  }) async {
    if (targetMeals <= 0) {
      throw const GoalException('Monthly target must be greater than zero.');
    }

    if (displayDays != null && displayDays <= 0) {
      throw const GoalException('Display days must be greater than zero.');
    }

    final now = DateTime.now();
    final month = currentMonthKey(now);
    final docRef = _goalDoc(user.uid, month);

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final existing = MonthlyGoal.fromFirestore(snapshot);
          if (existing.month == month && existing.targetMeals > 0) {
            throw const GoalException(
              'A goal has already been set for this month.',
            );
          }
        }

        final goal = MonthlyGoal(
          userId: user.uid,
          role: user.role,
          month: month,
          targetMeals: targetMeals,
          createdAt: now,
          displayDays: displayDays,
        );

        transaction.set(docRef, goal.toFirestore());
        return goal;
      });
    } on FirebaseException catch (error) {
      throw GoalException(
        error.message ?? 'Unable to save goal right now. Please try again.',
      );
    }
  }

  int _calculateAchievedCount({
    required AppUserModel user,
    required List<DonationModel> donations,
  }) {
    if (user.isDonor) {
      return donations.length;
    }

    if (user.isNgo) {
      return donations.fold<int>(
        0,
        (sum, donation) => sum + _parseMealsToInt(donation.quantity),
      );
    }

    return 0;
  }

  DocumentReference<Map<String, dynamic>> _goalDoc(String userId, String month) {
    return _goals.doc('${userId}_$month');
  }

  Stream<String> _monthTicker() {
    return (() async* {
      var lastMonth = currentMonthKey();
      yield lastMonth;

      await for (final _ in Stream<void>.periodic(_monthCheckInterval)) {
        final nextMonth = currentMonthKey();
        if (nextMonth == lastMonth) {
          continue;
        }
        lastMonth = nextMonth;
        yield nextMonth;
      }
    })();
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

DateTime _monthStartFromKey(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  final year = int.tryParse(parts[0]) ?? DateTime.now().year;
  final month = int.tryParse(parts[1]) ?? DateTime.now().month;
  return DateTime(year, month);
}

DateTime _monthEndFromKey(String monthKey) {
  final start = _monthStartFromKey(monthKey);
  return DateTime(start.year, start.month + 1);
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

int? _nullableInt(dynamic value) {
  final parsed = _toInt(value);
  if (parsed <= 0) {
    return null;
  }
  return parsed;
}

String _readMonth(Map<String, dynamic> data, {required String fallback}) {
  final raw = data['month'] ?? data['monthKey'];
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  return value;
}

String _readUserId(Map<String, dynamic> data, {required String fallback}) {
  final raw = data['userId'] ?? data['uid'];
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  return value;
}

String _readRole(Map<String, dynamic> data, {required String fallback}) {
  final value = data['role']?.toString().trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  return value;
}

int _parseMealsToInt(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return 0;
  }

  final direct = int.tryParse(value);
  if (direct != null) {
    return direct;
  }

  final matches = RegExp(r'\d+').allMatches(value).toList();
  if (matches.isEmpty) {
    return 0;
  }

  if (matches.length == 1) {
    return int.parse(matches.first.group(0)!);
  }

  return int.parse(matches.last.group(0)!);
}
