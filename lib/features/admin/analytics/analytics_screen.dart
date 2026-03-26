import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/analytics/services/admin_analytics_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const Color _primary = Color(0xFF0F4C45);
  static const Color _donorColor = Color(0xFF2E8B57);
  static const Color _ngoColor = Color(0xFF2F6BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Analytics',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<AdminAnalyticsData>(
        stream: AdminAnalyticsService().streamAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final analytics = snapshot.data ??
              const AdminAnalyticsData(
                totalMeals: 0,
                successRate: 0,
                totalDonations: 0,
                totalDonors: 0,
                totalNgos: 0,
                weeklyGrowth: [],
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 PERFORMANCE
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),

                /// ✅ SAME SIZE CARDS
                Row(
                  children: analytics.metrics.map((metric) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _PerformanceCard(metric: metric),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                /// 🔹 ACTIVITY
                const Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'This graph shows how many new donors and NGOs registered in the last 7 days.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔹 GRAPH CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      SizedBox(
                        height: 240,
                        child: _WeeklyGrowthChart(
                          points: analytics.weeklyGrowth,
                          donorColor: _donorColor,
                          ngoColor: _ngoColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(
                            color: _donorColor,
                            label: 'Donors (${analytics.totalDonors})',
                          ),
                          const SizedBox(height: 8),
                          _LegendItem(
                            color: _ngoColor,
                            label: 'NGOs (${analytics.totalNgos})',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ================= PERFORMANCE CARD =================

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.metric});

  final AdminAnalyticsMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            metric.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AnalyticsScreen._primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ================= GRAPH =================

class _WeeklyGrowthChart extends StatelessWidget {
  const _WeeklyGrowthChart({
    required this.points,
    required this.donorColor,
    required this.ngoColor,
  });

  final List<AdminGrowthPoint> points;
  final Color donorColor;
  final Color ngoColor;

  @override
  Widget build(BuildContext context) {
    final data = points.isEmpty ? _emptyWeek : points;

    final maxCount = data.fold<int>(
      0,
      (max, p) {
        final localMax =
            p.donorCount > p.ngoCount ? p.donorCount : p.ngoCount;
        return localMax > max ? localMax : max;
      },
    );

    /// 🔥 SMART 3,6,9 SCALING
    double maxY;
    double interval = 3;

    if (maxCount <= 6) {
      maxY = 9;
    } else if (maxCount <= 12) {
      maxY = 15;
    } else if (maxCount <= 30) {
      maxY = 30;
      interval = 6;
    } else {
      maxY = (maxCount + 6).toDouble();
      interval = 6;
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= data.length) return const SizedBox();
                return Text(data[index].label);
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].donorCount.toDouble(),
                color: donorColor,
                width: 8,
              ),
              BarChartRodData(
                toY: data[index].ngoCount.toDouble(),
                color: ngoColor,
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final List<AdminGrowthPoint> _emptyWeek =
      List.generate(
    7,
    (index) => AdminGrowthPoint(
      date: DateTime.now(),
      label: 'Day',
      donorCount: 0,
      ngoCount: 0,
    ),
  );
}

/// ================= LEGEND =================

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}