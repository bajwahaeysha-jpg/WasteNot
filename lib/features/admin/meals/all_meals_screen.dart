import 'package:flutter/material.dart';
import 'package:wastenot/core/utils/meal_parser.dart';
import 'package:wastenot/services/donation_services.dart';

class AllMealsScreen extends StatefulWidget {
  const AllMealsScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  State<AllMealsScreen> createState() => _AllMealsScreenState();
}

class _AllMealsScreenState extends State<AllMealsScreen> {
  final DonationService _donationService = DonationService();
  late final Future<_ImpactStats> _impactStatsFuture;

  @override
  void initState() {
    super.initState();
    _impactStatsFuture = _loadImpactStats();
  }

  Future<List<DonationModel>> getCompletedDonations() async {
    final donations = await _donationService.getAllDonations(
      status: DonationStatus.completed,
    );
    return donations
        .where((donation) => donation.status == DonationStatus.completed.value)
        .toList();
  }

  int calculateTotalMeals(List<DonationModel> donations) {
    return donations.fold<int>(
      0,
      (sum, donation) => sum + parseMealValue(donation.quantity),
    );
  }

  int calculateTodayMeals(List<DonationModel> donations) {
    final now = DateTime.now();
    return donations
        .where(
          (donation) =>
              donation.createdAt.year == now.year &&
              donation.createdAt.month == now.month &&
              donation.createdAt.day == now.day,
        )
        .fold<int>(
          0,
          (sum, donation) => sum + parseMealValue(donation.quantity),
        );
  }

  int calculatePeopleFed(int meals) {
    if (meals <= 0) {
      return 0;
    }
    return meals + (meals.isEven ? 2 : 3);
  }

  _FoodWeight calculateFoodWeight(int meals) {
    final totalKg = meals * 0.3;
    return _FoodWeight(totalKg: totalKg, totalTons: totalKg / 1000);
  }

  Future<_ImpactStats> _loadImpactStats() async {
    try {
      final completedDonations = await getCompletedDonations();
      final totalMeals = calculateTotalMeals(completedDonations);
      final todayMeals = calculateTodayMeals(completedDonations);
      final totalPeopleFed = calculatePeopleFed(totalMeals);
      final todayPeopleFed = calculatePeopleFed(todayMeals);
      final totalFoodWeight = calculateFoodWeight(totalMeals);
      final todayFoodWeight = calculateFoodWeight(todayMeals);

      return _ImpactStats(
        totalMeals: totalMeals,
        todayMeals: todayMeals,
        totalPeopleFed: totalPeopleFed,
        todayPeopleFed: todayPeopleFed,
        totalFoodWeight: totalFoodWeight,
        todayFoodWeight: todayFoodWeight,
      );
    } catch (_) {
      return const _ImpactStats.empty();
    }
  }

  String _formatCount(int value) {
    final text = value.toString();
    if (text.length <= 3) {
      return text;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  String _formatTodayChange(int value) {
    if (value <= 0) {
      return '0 today';
    }
    return '+${_formatCount(value)} today';
  }

  String _formatFoodValue(_FoodWeight weight) {
    if (weight.totalKg >= 1000) {
      return '${_formatWeightNumber(weight.totalTons)} tons';
    }
    return '${_formatWeightNumber(weight.totalKg)} kg';
  }

  String _formatFoodTodayChange(_FoodWeight weight) {
    if (weight.totalKg <= 0) {
      return '0 today';
    }
    return '+${_formatFoodValue(weight)}';
  }

  String _formatWeightNumber(double value) {
    final hasDecimal = value % 1 != 0;
    return hasDecimal ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: AllMealsScreen.mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Impact",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<_ImpactStats>(
        future: _impactStatsFuture,
        builder: (context, snapshot) {
          final stats = snapshot.data ?? const _ImpactStats.empty();

          return ListView(
            children: [
              Container(
                height: 200,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/Orphanages.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Together, we can end hunger",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "See the total impact created through WasteNot",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _impactRow(
                        value: _formatCount(stats.totalMeals),
                        label: "Meals saved",
                        change: _formatTodayChange(stats.todayMeals),
                      ),
                      const Divider(height: 28),
                      _impactRow(
                        value: _formatCount(stats.totalPeopleFed),
                        label: "People fed",
                        change: _formatTodayChange(stats.todayPeopleFed),
                      ),
                      const Divider(height: 28),
                      _impactRow(
                        value: _formatFoodValue(stats.totalFoodWeight),
                        label: "Food rescued this month",
                        change: _formatFoodTodayChange(stats.todayFoodWeight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Food Distribution",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 80,
                              child: Container(
                                height: 12,
                                color: const Color(0xFF0B4B3F),
                              ),
                            ),
                            Expanded(
                              flex: 20,
                              child: Container(
                                height: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          _LegendDot(
                            color: Color(0xFF0B4B3F),
                            text: "Orphans 80%",
                          ),
                          SizedBox(width: 18),
                          _LegendDot(
                            color: Colors.orange,
                            text: "Others 20%",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _impactRow({
    required String value,
    required String label,
    required String change,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AllMealsScreen.mainGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          change,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B4B3F),
          ),
        ),
      ],
    );
  }
}

class _ImpactStats {
  const _ImpactStats({
    required this.totalMeals,
    required this.todayMeals,
    required this.totalPeopleFed,
    required this.todayPeopleFed,
    required this.totalFoodWeight,
    required this.todayFoodWeight,
  });

  const _ImpactStats.empty()
      : totalMeals = 0,
        todayMeals = 0,
        totalPeopleFed = 0,
        todayPeopleFed = 0,
        totalFoodWeight = const _FoodWeight(totalKg: 0, totalTons: 0),
        todayFoodWeight = const _FoodWeight(totalKg: 0, totalTons: 0);

  final int totalMeals;
  final int todayMeals;
  final int totalPeopleFed;
  final int todayPeopleFed;
  final _FoodWeight totalFoodWeight;
  final _FoodWeight todayFoodWeight;
}

class _FoodWeight {
  const _FoodWeight({
    required this.totalKg,
    required this.totalTons,
  });

  final double totalKg;
  final double totalTons;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
