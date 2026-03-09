import 'package:flutter/material.dart';

class AllMealsScreen extends StatelessWidget {
  const AllMealsScreen({super.key});

  static const Color mainGreen =  Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
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
      body: ListView(
        children: [

          /// ───── HERO IMAGE ─────
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

          /// ───── MAIN TITLE ─────
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

          /// ───── TOTAL STATS ─────
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
                    value: "3,000+",
                    label: "Meals saved",
                    change: "+120 today",
                  ),
                  const Divider(height: 28),

                  _impactRow(
                    value: "3,000",
                    label: "People fed",
                    change: "+80 today",
                  ),
                  const Divider(height: 28),

                  _impactRow(
                    value: "40 tons",
                    label: "Food rescued this month",
                    change: "+5 tons",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// ───── FOOD DISTRIBUTION ─────
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

                  /// ─── SINGLE SEGMENT BAR ───
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 80,
                          child: Container(
                            height: 12,
                            color: Colors.green,
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

                  /// ─── LEGEND ───
                  Row(
                    children: const [
                      _LegendDot(
                        color: Colors.green,
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
      ),
    );
  }

  // ───────── IMPACT ROW ─────────

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
                color: mainGreen,
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
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

/// ───────── LEGEND DOT ─────────

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
