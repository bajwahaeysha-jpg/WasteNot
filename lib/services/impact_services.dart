import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/core/utils/meal_parser.dart';

class NgoImpactMetric {
  const NgoImpactMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}

class NgoWeeklyImpactPoint {
  const NgoWeeklyImpactPoint({
    required this.date,
    required this.label,
    required this.count,
  });

  final DateTime date;
  final String label;
  final int count;
}

class NgoImpactData {
  const NgoImpactData({
    required this.totalCompletedDonations,
    required this.totalMeals,
    required this.totalPeopleServed,
    required this.weeklyActivity,
  });

  final int totalCompletedDonations;
  final int totalMeals;
  final int totalPeopleServed;
  final List<NgoWeeklyImpactPoint> weeklyActivity;

  List<NgoImpactMetric> get metrics => <NgoImpactMetric>[
        NgoImpactMetric(
          label: 'Accepted Donations',
          value: totalCompletedDonations,
        ),
        NgoImpactMetric(
          label: 'Meals',
          value: totalMeals,
        ),
        NgoImpactMetric(
          label: 'People Served',
          value: totalPeopleServed,
        ),
      ];
}

class ImpactServices {
  ImpactServices({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

  Stream<NgoImpactData> streamNgoImpact(String ngoId) {
    final normalizedNgoId = ngoId.trim();
    if (normalizedNgoId.isEmpty) {
      return Stream<NgoImpactData>.value(
        const NgoImpactData(
          totalCompletedDonations: 0,
          totalMeals: 0,
          totalPeopleServed: 0,
          weeklyActivity: <NgoWeeklyImpactPoint>[],
        ),
      );
    }

    return _donations.snapshots().map((snapshot) {
      final completedDocs = snapshot.docs
          .where((doc) => _isCompletedDonationForNgo(doc.data(), normalizedNgoId))
          .toList();

      final totalCompletedDonations = completedDocs.length;
      final totalMeals = completedDocs.fold<int>(
        0,
        (int sum, doc) => sum + parseMealValue(doc.data()['quantity']),
      );
      final weeklyActivity = _buildWeeklyActivity(completedDocs);

      return NgoImpactData(
        totalCompletedDonations: totalCompletedDonations,
        totalMeals: totalMeals,
        totalPeopleServed: totalMeals,
        weeklyActivity: weeklyActivity,
      );
    });
  }

  bool _isCompletedDonationForNgo(Map<String, dynamic> data, String ngoId) {
    final directNgoId = (data['ngoId'] as String?)?.trim();
    final acceptedByNgoId = (data['acceptedByNgoId'] as String?)?.trim();
    final status = (data['status'] as String?)?.trim().toLowerCase();

    final matchesNgo = directNgoId == ngoId || acceptedByNgoId == ngoId;
    if (!matchesNgo) {
      return false;
    }

    return status == 'completed';
  }

  List<NgoWeeklyImpactPoint> _buildWeeklyActivity(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final counts = <DateTime, int>{};

    for (var index = 0; index < 7; index++) {
      final day = start.add(Duration(days: index));
      counts[day] = 0;
    }

    for (final doc in docs) {
      final data = doc.data();
      final activityDate =
          _dateFromFirestore(data['completedAt']) ??
          _dateFromFirestore(data['createdAt']);
      if (activityDate == null) {
        continue;
      }

      final day = DateTime(
        activityDate.year,
        activityDate.month,
        activityDate.day,
      );
      if (day.isBefore(start) || day.isAfter(today)) {
        continue;
      }

      counts.update(day, (value) => value + 1, ifAbsent: () => 1);
    }

    return counts.entries
        .map(
          (entry) => NgoWeeklyImpactPoint(
            date: entry.key,
            label: _weekdayLabel(entry.key.weekday),
            count: entry.value,
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
