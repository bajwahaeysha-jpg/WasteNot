import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.totalAcceptedDonations,
    required this.totalMeals,
    required this.totalPeopleServed,
    required this.weeklyActivity,
  });

  final int totalAcceptedDonations;
  final int totalMeals;
  final int totalPeopleServed;
  final List<NgoWeeklyImpactPoint> weeklyActivity;

  List<NgoImpactMetric> get metrics => <NgoImpactMetric>[
        NgoImpactMetric(
          label: 'Accepted Donations',
          value: totalAcceptedDonations,
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
          totalAcceptedDonations: 0,
          totalMeals: 0,
          totalPeopleServed: 0,
          weeklyActivity: <NgoWeeklyImpactPoint>[],
        ),
      );
    }

    return _donations.snapshots().map((snapshot) {
      final acceptedDocs = snapshot.docs
          .where((doc) => _isAcceptedDonationForNgo(doc.data(), normalizedNgoId))
          .toList();

      final totalAcceptedDonations = acceptedDocs.length;
      final totalMeals = acceptedDocs.fold<int>(
        0,
        (sum, doc) => sum + quantityToMeals(doc.data()['quantity']),
      );
      final weeklyActivity = _buildWeeklyActivity(acceptedDocs);

      return NgoImpactData(
        totalAcceptedDonations: totalAcceptedDonations,
        totalMeals: totalMeals,
        totalPeopleServed: totalMeals,
        weeklyActivity: weeklyActivity,
      );
    });
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

  bool _isAcceptedDonationForNgo(Map<String, dynamic> data, String ngoId) {
    final directNgoId = (data['ngoId'] as String?)?.trim();
    final acceptedByNgoId = (data['acceptedByNgoId'] as String?)?.trim();
    final status = (data['status'] as String?)?.trim().toLowerCase();
    final hasAcceptedAt = _dateFromFirestore(data['acceptedAt']) != null;

    final matchesNgo = directNgoId == ngoId || acceptedByNgoId == ngoId;
    if (!matchesNgo) {
      return false;
    }

    if (status == 'accepted') {
      return true;
    }

    // Keep impact compatible with the current donation flow, where acceptance
    // is represented by acceptedByNgoId + acceptedAt and completion may follow.
    return acceptedByNgoId == ngoId &&
        hasAcceptedAt &&
        status != 'expired' &&
        status != 'rejected';
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
          _dateFromFirestore(data['acceptedAt']) ??
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
