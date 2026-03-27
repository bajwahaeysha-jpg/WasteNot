import 'package:cloud_firestore/cloud_firestore.dart';

class GoalProgress {
  const GoalProgress({
    required this.month,
    required this.target,
    required this.achievedCount,
  });

  final String month;
  final int target;
  final int achievedCount;

  bool get hasGoal => target > 0;

  double get progress {
    if (!hasGoal) {
      return 0;
    }
    return achievedCount / target;
  }

  int get percentage {
    if (!hasGoal) {
      return 0;
    }
    return (progress * 100).round();
  }

  GoalProgress copyWith({
    String? month,
    int? target,
    int? achievedCount,
  }) {
    return GoalProgress(
      month: month ?? this.month,
      target: target ?? this.target,
      achievedCount: achievedCount ?? this.achievedCount,
    );
  }

  factory GoalProgress.empty(String month) {
    return GoalProgress(
      month: month,
      target: 0,
      achievedCount: 0,
    );
  }
}

class MonthlyGoalRecord {
  const MonthlyGoalRecord({
    required this.userId,
    required this.role,
    required this.month,
    required this.target,
    required this.createdAt,
  });

  final String userId;
  final String role;
  final String month;
  final int target;
  final DateTime createdAt;

  String get documentId => '${userId}_$month';

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'userId': userId,
      'uid': userId,
      'role': role,
      'month': month,
      'monthKey': month,
      'target': target,
      'targetMeals': target,
      'monthlyTarget': target,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MonthlyGoalRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final month = _readString(data['month']) ??
        _readString(data['monthKey']) ??
        _monthFromDocumentId(snapshot.id) ??
        '';
    final userId = _readString(data['userId']) ??
        _readString(data['uid']) ??
        snapshot.id.split('_').first;

    return MonthlyGoalRecord(
      userId: userId,
      role: _readString(data['role']) ?? 'donor',
      month: month,
      target: _parseInt(
        data['target'] ?? data['targetMeals'] ?? data['monthlyTarget'],
      ),
      createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
    );
  }
}

String? _monthFromDocumentId(String documentId) {
  final separator = documentId.indexOf('_');
  if (separator < 0 || separator >= documentId.length - 1) {
    return null;
  }

  final value = documentId.substring(separator + 1).trim();
  if (value.isEmpty) {
    return null;
  }
  return value;
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

int _parseInt(dynamic value) {
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

String? _readString(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}
