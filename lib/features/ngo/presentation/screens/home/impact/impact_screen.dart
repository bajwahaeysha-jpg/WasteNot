import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/impact_services.dart';
import 'package:wastenot/services/session_service.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Impact', style: TextStyle(color: Colors.white)),
      ),
      body: ValueListenableBuilder<AppUserModel?>(
        valueListenable: SessionService.currentUser,
        builder: (context, user, _) {
          final ngoId = user?.uid;

          if (ngoId == null || ngoId.trim().isEmpty) {
            return const Center(child: Text('Unable to load impact data.'));
          }

          return StreamBuilder<NgoImpactData>(
            stream: ImpactServices().streamNgoImpact(ngoId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final impact = snapshot.data ??
                  const NgoImpactData(
                    totalAcceptedDonations: 0,
                    totalMeals: 0,
                    totalPeopleServed: 0,
                    weeklyActivity: [],
                  );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// PERFORMANCE
                    const Text(
                      "Performance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: List.generate(impact.metrics.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _MetricCard(
                              metric: impact.metrics[index],
                              index: index,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    /// ACTIVITY
                    const Text(
                      "Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Your activity of last seven days",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7A8783)),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 220,
                        child: _WeeklyChart(points: impact.weeklyActivity),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// GLOBAL IMPACT
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Together, we can end hunger",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/Orphanages.jpg',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Total meals saved",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF7A8783),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${impact.totalMeals}",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "+ Today",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                const Text(
                                  "Due to these donations, many orphans and needy people have been served. Your contribution is making a real difference.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Color(0xFF4E5D59),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// METRIC CARD
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.index,
  });

  final NgoImpactMetric metric;
  final int index;

  IconData _getIcon(String label) {
    if (label.toLowerCase().contains("meal")) return Icons.restaurant;
    if (label.toLowerCase().contains("donation")) return Icons.volunteer_activism;
    return Icons.people;
  }

  static const bgColors = [
    Color(0xFFFFF6F8),
    Color(0xFFF7F5FF),
    Color(0xFFFFFBF0),
  ];

  static const iconColors = [
    Color(0xFFE57373),
    Color(0xFF9575CD),
    Color(0xFFFFCA28),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = bgColors[index % 3];
    final iconColor = iconColors[index % 3];

    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ImpactScreen.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(metric.label),
                  size: 18,
                  color: iconColor,
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              metric.label,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// GRAPH
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.points});

  final List<NgoWeeklyImpactPoint> points;

  @override
  Widget build(BuildContext context) {
    final data = points.isEmpty ? _emptyWeek : points;

    final maxCount = data.fold<int>(
      0,
      (max, p) => p.count > max ? p.count : max,
    );

    final maxY = (maxCount == 0 ? 5 : maxCount + 1).toDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Text(data[i].label);
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),

        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].count.toDouble(),
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFA5D6A7),
                    Color(0xFF81C784),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _emptyWeek = List.generate(
    7,
    (i) => NgoWeeklyImpactPoint(
      date: DateTime.now(),
      label: '',
      count: 0,
    ),
  );
}