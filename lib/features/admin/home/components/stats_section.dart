import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/dashboard_stat_card.dart';
import '../../../../widgets/pressable_scale.dart';
import '../../donations/all_donations_screen.dart';
import '../../donors/all_donors_screen.dart';
import '../../meals/all_meals_screen.dart';
import '../../ngos/all_ngos_screen.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  static final _AdminHomeStatsService _statsService = _AdminHomeStatsService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_AdminHomeStats>(
      stream: _statsService.streamStats(),
      initialData: const _AdminHomeStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const _AdminHomeStats();
        final alerts = stats.alerts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6D5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1E0A6)),
              ),
              child: Column(
                children: alerts.isEmpty
                    ? const [_AlertRow(text: 'No alerts ðŸŽ‰')]
                    : alerts
                        .map((text) => _AlertRow(text: text))
                        .toList(growable: false),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.75,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              children: [
                _buildCard(
                  context,
                  screen: const AllDonationsScreen(),
                  title: 'Donations',
                  value: _formatCompactNumber(stats.totalDonations),
                  icon: Icons.volunteer_activism,
                  iconColor: const Color(0xFF0B4B3F),
                ),
                _buildCard(
                  context,
                  screen: const AllMealsScreen(),
                  title: 'Meals',
                  value: _formatCompactNumber(stats.totalMeals),
                  icon: Icons.restaurant,
                  iconColor: Colors.teal,
                ),
                _buildCard(
                  context,
                  screen: const AllNGOsScreen(),
                  title: 'NGOs',
                  value: _formatCompactNumber(stats.totalNgos),
                  icon: Icons.groups,
                  iconColor: Colors.blue,
                ),
                _buildCard(
                  context,
                  screen: const AllDonorsScreen(),
                  title: 'Donors',
                  value: _formatCompactNumber(stats.totalDonors),
                  icon: Icons.people_alt,
                  iconColor: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Widget screen,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return PressableScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: DashboardStatCard(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String text;

  const _AlertRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // ðŸ”¥ more spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF39C12),
            size: 20, // ðŸ”¥ bigger icon
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15, // ðŸ”¥ BIG FONT
                fontWeight: FontWeight.w500, // ðŸ”¥ better readability
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHomeStats {
  const _AdminHomeStats({
    this.totalDonations = 0,
    this.totalMeals = 0,
    this.totalNgos = 0,
    this.totalDonors = 0,
    this.totalRequests = 0,
    this.pendingNgoRequests = 0,
    this.expiredDonations = 0,
    this.completedLast24h = 0,
  });

  final int totalDonations;
  final int totalMeals;
  final int totalNgos;
  final int totalDonors;
  final int totalRequests;
  final int pendingNgoRequests;
  final int expiredDonations;
  final int completedLast24h;

  List<String> get alerts {
    final items = <String>[];

    if (pendingNgoRequests > 0) {
      items.add('$pendingNgoRequests new NGO request(s) need approval');
    }
    if (expiredDonations > 0) {
      items.add('$expiredDonations donation(s) expired');
    }
    if (completedLast24h > 0) {
      items.add('$completedLast24h donation(s) completed in last 24 hours');
    }

    return List.unmodifiable(items);
  }
}

class _AdminHomeStatsService {
  _AdminHomeStatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<_AdminHomeStats>? _statsStream;

  Stream<_AdminHomeStats> streamStats() {
    return _statsStream ??= _buildStatsStream().asBroadcastStream();
  }

  Stream<_AdminHomeStats> _buildStatsStream() {
    final controller = StreamController<_AdminHomeStats>();

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? donationsSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? usersSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? requestsSub;
    Timer? ticker;

    QuerySnapshot<Map<String, dynamic>>? latestDonations;
    QuerySnapshot<Map<String, dynamic>>? latestUsers;
    QuerySnapshot<Map<String, dynamic>>? latestRequests;

    void emitStats() {
      if (latestDonations == null || latestUsers == null || latestRequests == null) {
        return;
      }

      final now = DateTime.now();
      final completedSince = now.subtract(const Duration(hours: 24));

      var totalMeals = 0;
      var expiredDonations = 0;
      var completedLast24h = 0;

      for (final doc in latestDonations!.docs) {
        final data = doc.data();
        totalMeals += _readMealCount(data);

        final expiryTime = _readTimestamp(data['expiryTime']);
        if (expiryTime != null && expiryTime.isBefore(now)) {
          expiredDonations++;
        }

        final status = (data['status'] as String?)?.trim().toLowerCase();
        if (status == 'completed') {
          final completedAt = _readTimestamp(data['completedAt']);
          if (completedAt != null &&
              !completedAt.isBefore(completedSince) &&
              !completedAt.isAfter(now)) {
            completedLast24h++;
          }
        }
      }

      var totalNgos = 0;
      var totalDonors = 0;
      var pendingNgoRequests = 0;

      for (final doc in latestUsers!.docs) {
        final data = doc.data();
        final role = (data['role'] as String?)?.trim().toLowerCase();
        if (role == 'ngo') {
          totalNgos++;
          final status = (data['status'] as String?)?.trim().toLowerCase();
          if (status == 'pending') {
            pendingNgoRequests++;
          }
        } else if (role == 'donor') {
          totalDonors++;
        }
      }

      if (!controller.isClosed) {
        controller.add(
          _AdminHomeStats(
            totalDonations: latestDonations!.size,
            totalMeals: totalMeals,
            totalNgos: totalNgos,
            totalDonors: totalDonors,
            totalRequests: latestRequests!.size,
            pendingNgoRequests: pendingNgoRequests,
            expiredDonations: expiredDonations,
            completedLast24h: completedLast24h,
          ),
        );
      }
    }

    void addError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }

    controller.onListen = () {
      donationsSub = _firestore
          .collection('donations')
          .snapshots()
          .listen((snapshot) {
            latestDonations = snapshot;
            emitStats();
          }, onError: addError);

      usersSub = _firestore.collection('users').snapshots().listen((snapshot) {
        latestUsers = snapshot;
        emitStats();
      }, onError: addError);

      requestsSub = _firestore
          .collection('requests')
          .snapshots()
          .listen((snapshot) {
            latestRequests = snapshot;
            emitStats();
          }, onError: addError);

      ticker = Timer.periodic(const Duration(minutes: 1), (_) => emitStats());
    };

    controller.onCancel = () async {
      ticker?.cancel();
      await donationsSub?.cancel();
      await usersSub?.cancel();
      await requestsSub?.cancel();
    };

    return controller.stream;
  }

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static int _readMealCount(Map<String, dynamic> data) {
    for (final key in const ['servings', 'meals', 'mealCount', 'totalMeals']) {
      final value = data[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }
}

String _formatCompactNumber(int value) {
  if (value >= 1000000) {
    final v = value / 1000000;
    return '${v.toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    final v = value / 1000;
    return '${v.toStringAsFixed(1)}k';
  }
  return value.toString();
}
