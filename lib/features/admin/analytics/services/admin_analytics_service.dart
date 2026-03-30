import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsMetric {
  const AdminAnalyticsMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class AdminGrowthPoint {
  const AdminGrowthPoint({
    required this.date,
    required this.label,
    required this.donorCount,
    required this.ngoCount,
  });

  final DateTime date;
  final String label;
  final int donorCount;
  final int ngoCount;
}

class AdminAnalyticsData {
  const AdminAnalyticsData({
    required this.totalMeals,
    required this.successRate,
    required this.totalDonations,
    required this.totalDonors,
    required this.totalNgos,
    required this.weeklyGrowth,
  });

  final int totalMeals;
  final int successRate;
  final int totalDonations;
  final int totalDonors;
  final int totalNgos;
  final List<AdminGrowthPoint> weeklyGrowth;

  List<AdminAnalyticsMetric> get metrics => <AdminAnalyticsMetric>[
        AdminAnalyticsMetric(
          label: 'Total Meals',
          value: totalMeals.toString(),
        ),
        AdminAnalyticsMetric(
          label: 'Success Rate',
          value: '$successRate%',
        ),
        AdminAnalyticsMetric(
          label: 'Total Donations',
          value: totalDonations.toString(),
        ),
      ];
}

class AdminAnalyticsService {
  AdminAnalyticsService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<AdminAnalyticsData> streamAnalytics() {
    final controller = StreamController<AdminAnalyticsData>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? userSub;

    QuerySnapshot<Map<String, dynamic>>? latestDonations;
    QuerySnapshot<Map<String, dynamic>>? latestUsers;

    void emitIfReady() {
      final donations = latestDonations;
      final users = latestUsers;
      if (donations == null || users == null || controller.isClosed) {
        return;
      }

      controller.add(_buildAnalyticsData(donations, users));
    }

    controller.onListen = () {
      donationSub = _donations.snapshots().listen(
        (snapshot) {
          latestDonations = snapshot;
          emitIfReady();
        },
        onError: controller.addError,
      );

      userSub = _users.snapshots().listen(
        (snapshot) {
          latestUsers = snapshot;
          emitIfReady();
        },
        onError: controller.addError,
      );
    };

    controller.onCancel = () async {
      await donationSub?.cancel();
      await userSub?.cancel();
    };

    return controller.stream;
  }

  AdminAnalyticsData _buildAnalyticsData(
    QuerySnapshot<Map<String, dynamic>> donationSnapshot,
    QuerySnapshot<Map<String, dynamic>> userSnapshot,
  ) {
    final donationDocs = donationSnapshot.docs;
    final userDocs = userSnapshot.docs;

    final successfulDonations = donationDocs.where(
      (doc) => _isAcceptedOrCompletedDonation(doc.data()),
    );

    final totalDonations = donationDocs.length;
    final successfulCount = successfulDonations.length;
    final totalMeals = successfulDonations.fold<int>(
      0,
      (sum, doc) => sum + quantityToMeals(doc.data()['quantity']),
    );
    final successRate = totalDonations == 0
        ? 0
        : ((successfulCount / totalDonations) * 100).round();

    final totalDonors = userDocs.where((doc) => _isDonor(doc.data())).length;
    final totalNgos = userDocs.where((doc) => _isNgo(doc.data())).length;

    return AdminAnalyticsData(
      totalMeals: totalMeals,
      successRate: successRate,
      totalDonations: totalDonations,
      totalDonors: totalDonors,
      totalNgos: totalNgos,
      weeklyGrowth: _buildWeeklyGrowth(userDocs),
    );
  }

  int quantityToMeals(dynamic quantity) {
    final text = quantity?.toString().trim() ?? '';
    if (text.isEmpty) {
      return 0;
    }

    final matches = RegExp(r'\d+').allMatches(text).toList();
    if (matches.isEmpty) {
      return 0;
    }

    if (matches.length >= 2 && text.contains('-')) {
      final start = int.parse(matches.first.group(0)!);
      final end = int.parse(matches[1].group(0)!);
      return ((start + end) / 2).round();
    }

    return int.parse(matches.first.group(0)!);
  }

  bool _isAcceptedOrCompletedDonation(Map<String, dynamic> data) {
    final status = (data['status'] as String?)?.trim().toLowerCase();
    if (status == 'accepted' || status == 'completed') {
      return true;
    }

    final hasAcceptedAt = _dateFromFirestore(data['acceptedAt']) != null;
    final acceptedByNgoId = (data['acceptedByNgoId'] as String?)?.trim();
    final legacyNgoId = (data['ngoId'] as String?)?.trim();

    return hasAcceptedAt &&
        (acceptedByNgoId?.isNotEmpty == true || legacyNgoId?.isNotEmpty == true) &&
        status != 'expired' &&
        status != 'rejected';
  }

  bool _isDonor(Map<String, dynamic> data) {
    if (data['isDonor'] == true) {
      return true;
    }
    final role = (data['role'] as String?)?.trim().toLowerCase();
    return role == 'donor';
  }

  bool _isNgo(Map<String, dynamic> data) {
    if (data['isNgo'] == true) {
      return true;
    }
    final role = (data['role'] as String?)?.trim().toLowerCase();
    return role == 'ngo';
  }

  List<AdminGrowthPoint> _buildWeeklyGrowth(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final donorCounts = <DateTime, int>{};
    final ngoCounts = <DateTime, int>{};

    for (var index = 0; index < 7; index++) {
      final day = start.add(Duration(days: index));
      donorCounts[day] = 0;
      ngoCounts[day] = 0;
    }

    for (final doc in userDocs) {
      final data = doc.data();
      final createdAt = _dateFromFirestore(data['createdAt']);
      if (createdAt == null) {
        continue;
      }

      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (day.isBefore(start) || day.isAfter(today)) {
        continue;
      }

      if (_isDonor(data)) {
        donorCounts.update(day, (value) => value + 1, ifAbsent: () => 1);
      }
      if (_isNgo(data)) {
        ngoCounts.update(day, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return donorCounts.keys
        .map(
          (day) => AdminGrowthPoint(
            date: day,
            label: _weekdayLabel(day.weekday),
            donorCount: donorCounts[day] ?? 0,
            ngoCount: ngoCounts[day] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _weekdayLabel(int weekday) {
    const labels = <int, String>{
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return labels[weekday] ?? '';
  }
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
