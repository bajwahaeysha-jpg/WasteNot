import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/features/goal/models/goal_model.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';

class GoalService {
  GoalService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String goalsCollection = 'goals';
  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection(goalsCollection);
  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  String currentMonthKey([DateTime? date]) => _monthKey(date ?? DateTime.now());

  String currentMonthLabel([DateTime? date]) {
    return DateFormat('MMMM yyyy').format(date ?? DateTime.now());
  }

  Future<MonthlyGoalRecord?> fetchCurrentMonthGoal({
    required AppUserModel user,
    DateTime? now,
  }) async {
    final month = currentMonthKey(now);
    final snapshot = await _goalDocument(user.uid, month).get();
    final directGoal = _goalFromSnapshot(snapshot, month);
    if (directGoal != null) {
      return directGoal;
    }

    return _findGoalByFields(userId: user.uid, month: month);
  }

  Future<GoalProgress> fetchCurrentMonthProgress({
    required AppUserModel user,
    DateTime? now,
  }) async {
    final month = currentMonthKey(now);
    final goal = await fetchCurrentMonthGoal(user: user, now: now);
    var achievedCount = 0;
    try {
      achievedCount = await _fetchAchievedCount(
        user: user,
        month: month,
      );
    } on FirebaseException {
      achievedCount = 0;
    }

    return GoalProgress(
      month: month,
      target: goal?.target ?? 0,
      achievedCount: achievedCount,
    );
  }

  Future<MonthlyGoalRecord> saveCurrentMonthGoal({
    required AppUserModel user,
    required int target,
  }) async {
    if (!user.isDonor && !user.isNgo) {
      throw const GoalException('Only donor and NGO accounts can set goals.');
    }
    if (target <= 0) {
      throw const GoalException('Monthly target must be greater than zero.');
    }

    final now = DateTime.now();
    final month = currentMonthKey(now);
    final docRef = _goalDocument(user.uid, month);

    try {
      final goal = await _firestore.runTransaction((transaction) async {
        final existingSnapshot = await transaction.get(docRef);
        if (existingSnapshot.exists) {
          final existingGoal = MonthlyGoalRecord.fromFirestore(existingSnapshot);
          if (existingGoal.month == month && existingGoal.target > 0) {
            throw const GoalException(
              'A goal has already been set for this month.',
            );
          }
        }

        final goal = MonthlyGoalRecord(
          userId: user.uid,
          role: user.role,
          month: month,
          target: target,
          createdAt: now,
        );
        transaction.set(docRef, goal.toFirestore());
        return goal;
      });

      refreshNotifier.value++;
      return goal;
    } on GoalException {
      rethrow;
    } on FirebaseException catch (error) {
      throw GoalException(
        error.message ?? 'Unable to save goal right now. Please try again.',
      );
    }
  }

  Future<int> _fetchAchievedCount({
    required AppUserModel user,
    required String month,
  }) async {
    final monthStart = _monthStartFromKey(month);
    final nextMonthStart = DateTime(monthStart.year, monthStart.month + 1);
    final completedDocs = await _fetchCompletedDonationDocsForUser(user: user);
    final monthlyDocs = completedDocs.where((doc) {
      final completedAt = _parseDate(doc.data()['completedAt']);
      if (completedAt == null) {
        return false;
      }
      return !completedAt.isBefore(monthStart) && completedAt.isBefore(nextMonthStart);
    }).toList();

    if (user.isDonor) {
      return monthlyDocs.length;
    }

    var totalMeals = 0;
    for (final doc in monthlyDocs) {
      final data = doc.data();
      totalMeals += _parseMealsToInt(
        data['meals'] ??
            data['mealCount'] ??
            data['totalMeals'] ??
            data['servings'] ??
            data['quantity'],
      );
    }
    return totalMeals;
  }

  DocumentReference<Map<String, dynamic>> _goalDocument(
    String userId,
    String month,
  ) {
    return _goals.doc('${userId}_$month');
  }

  MonthlyGoalRecord? _goalFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String month,
  ) {
    if (!snapshot.exists) {
      return null;
    }

    final goal = MonthlyGoalRecord.fromFirestore(snapshot);
    if (goal.month != month || goal.target <= 0) {
      return null;
    }
    return goal;
  }

  Future<MonthlyGoalRecord?> _findGoalByFields({
    required String userId,
    required String month,
  }) async {
    final candidates = <MonthlyGoalRecord>[];

    final userIdQuery = await _goals.where('userId', isEqualTo: userId).get();
    for (final doc in userIdQuery.docs) {
      final goal = _goalFromSnapshot(doc, month);
      if (goal != null) {
        candidates.add(goal);
      }
    }

    final uidQuery = await _goals.where('uid', isEqualTo: userId).get();
    for (final doc in uidQuery.docs) {
      final goal = _goalFromSnapshot(doc, month);
      if (goal != null &&
          !candidates.any((candidate) => candidate.documentId == goal.documentId)) {
        candidates.add(goal);
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return candidates.first;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchCompletedDonationDocsForUser({
    required AppUserModel user,
  }) async {
    if (user.isDonor) {
      final snapshot = await _donations.where('donorId', isEqualTo: user.uid).get();
      return snapshot.docs.where(_isCompletedDonationDoc).toList();
    }

    if (!user.isNgo) {
      return const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    }

    final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    final acceptedSnapshot = await _donations
        .where('acceptedByNgoId', isEqualTo: user.uid)
        .get();
    for (final doc in acceptedSnapshot.docs) {
      if (_isCompletedDonationDoc(doc)) {
        docsById[doc.id] = doc;
      }
    }

    final legacySnapshot = await _donations.where('ngoId', isEqualTo: user.uid).get();
    for (final doc in legacySnapshot.docs) {
      if (_isCompletedDonationDoc(doc)) {
        docsById[doc.id] = doc;
      }
    }

    return docsById.values.toList();
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

DateTime? _parseDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}

bool _isCompletedDonationDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final status = doc.data()['status']?.toString().trim().toLowerCase();
  return status == DonationStatus.completed.value;
}

int _parseMealsToInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is! String) {
    return 0;
  }

  final normalized = value.trim();
  if (normalized.isEmpty) {
    return 0;
  }

  final direct = int.tryParse(normalized);
  if (direct != null) {
    return direct;
  }

  final matches = RegExp(r'\d+').allMatches(normalized).toList();
  if (matches.isEmpty) {
    return 0;
  }
  if (matches.length >= 2 && normalized.contains('-')) {
    return int.parse(matches.first.group(0)!);
  }
  return int.parse(matches.first.group(0)!);
}
