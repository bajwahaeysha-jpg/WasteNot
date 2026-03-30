import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/dashboard_stat_card.dart';
import '../../../../widgets/pressable_scale.dart';
import '../../alerts/alert_screen.dart';
import '../../donations/all_donations_screen.dart';
import '../../meals/all_meals_screen.dart';
import '../../ngos/all_ngos_screen.dart';
import '../../quick_actions/requests/requests_screen.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔔 ALERT BOX (gap reduce)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 6), // 🔥 FIXED (10 → 6)
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6D5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1E0A6)),
            ),
            child: Column(
              children: const [
                _AlertRow(text: "2 urgent requests need approval"),
                _AlertRow(text: "Pickup scheduled in 30 minutes"),
                _AlertRow(text: "Weekly impact report is ready"),
              ],
            ),
          ),
        ),

        /// 📊 STATS GRID
        StreamBuilder<_AdminHomeStats>(
          stream: _AdminHomeStatsService().streamStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? const _AdminHomeStats();

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              /// 🔥 HEIGHT FIX (ye bhi gap cause karta hai)
              childAspectRatio: 1.75,

              /// 🔥 TIGHT GRID
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,

              children: [
                _buildCard(
                  context,
                  screen: const AllDonationsScreen(),
                  title: "Donations",
                  value: _formatCompactNumber(stats.totalDonations),
                  icon: Icons.volunteer_activism,
                  iconColor: Colors.green,
                ),
                _buildCard(
                  context,
                  screen: const AllMealsScreen(),
                  title: "Meals",
                  value: _formatCompactNumber(stats.totalMeals),
                  icon: Icons.restaurant,
                  iconColor: Colors.teal,
                ),
                _buildCard(
                  context,
                  screen: const AllNGOsScreen(),
                  title: "NGOs",
                  value: _formatCompactNumber(stats.totalNgos),
                  icon: Icons.groups,
                  iconColor: Colors.blue,
                ),
                _buildCard(
                  context,
                  screen: RequestsScreen(),
                  title: "Requests",
                  value: _formatCompactNumber(stats.totalRequests),
                  icon: Icons.pending_actions,
                  iconColor: Colors.orange,
                ),
              ],
            );
          },
        ),

        /// 🔥 REMOVE EXTRA SPACE COMPLETELY
        const SizedBox(height: 6),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 3), // 🔥 tighter
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF39C12),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
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
    this.totalRequests = 0,
  });

  final int totalDonations;
  final int totalMeals;
  final int totalNgos;
  final int totalRequests;
}

class _AdminHomeStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<_AdminHomeStats> streamStats() {
    return _firestore.collection('donations').snapshots().asyncMap((donationsSnap) async {
      final ngosSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'ngo')
          .get();

      final requestsSnap =
          await _firestore.collection('requests').get();

      int totalMeals = 0;

      for (var doc in donationsSnap.docs) {
        final data = doc.data();
        final meals = data['meals'] ?? data['mealCount'] ?? data['totalMeals'];
        if (meals is int) {
          totalMeals += meals;
        }
      }

      return _AdminHomeStats(
        totalDonations: donationsSnap.size,
        totalMeals: totalMeals,
        totalNgos: ngosSnap.size,
        totalRequests: requestsSnap.size,
      );
    });
  }
}

String _formatCompactNumber(int value) {
  if (value >= 1000000) {
    final v = value / 1000000;
    return "${v.toStringAsFixed(1)}M";
  } else if (value >= 1000) {
    final v = value / 1000;
    return "${v.toStringAsFixed(1)}k";
  }
  return value.toString();
}