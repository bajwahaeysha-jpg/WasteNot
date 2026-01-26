import 'package:flutter/material.dart';
import 'meal_profile_screen.dart';

class AllMealsScreen extends StatelessWidget {
  const AllMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = [
      {
        "id": "#M2021",
        "ngo": "Khair Foundation",
        "donor": "Allah Malak Restaurant",
        "meals": 120,
        "location": "Sialkot,Cantt",
        "date": "Today",
      },
      {
        "id": "#M2022",
        "ngo": "Edhi Foundation",
        "donor": "Hotel Javson",
        "meals": 80,
        "location": "Sialkot",
        "date": "Yesterday",
      },
      {
        "id": "#M2023",
        "ngo": "SOS Children's Villages",
        "donor": "Sialkot Food Services",
        "meals": 65,
        "location": "Sialkot",
        "date": "12 Aug",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Meals Saved",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: meals.length,
        itemBuilder: (_, i) => _mealCard(context, meals[i]),
      ),
    );
  }

  Widget _mealCard(BuildContext context, Map m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealProfileScreen(meal: m),
          ),
        ),
        child: Row(
          children: [

            /// 🍽️ Meals Count
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF0F5F54).withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                "${m['meals']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5F54),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 📋 Meal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Meals Saved",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${m['ngo']}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Donor: ${m['donor']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${m['location']} • ${m['date']}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
