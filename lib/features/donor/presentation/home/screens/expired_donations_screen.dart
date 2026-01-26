import 'package:flutter/material.dart';
import 'expired_donation_detail_screen.dart';

class ExpiredDonationsScreen extends StatelessWidget {
  const ExpiredDonationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {
    final expiredDonations = [
      {
        "ngo": "Saadat Welfare",
        "food": "Chicken Sajji Rice",
        "people": 30,
        "date": "03/01/2026",
        "logo": "assets/images/sadat logo.jpg",
      },
      {
        "ngo": "Khair Foundation",
        "food": "Fresh Meals",
        "people": 24,
        "date": "10/11/2025",
        "logo": "assets/images/khair logo.png",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text("Expired Donations", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔔 ALERT BANNER
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "These donations expired before collection. Please try to donate earlier next time.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          ...expiredDonations.map(
            (d) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpiredDonationDetailScreen(donation: d),
                  ),
                );
              },
              child: _ExpiredCard(d),
            ),
          ),

          const SizedBox(height: 24),

          // 🍽️ WASTE OF FOOD CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Row(
                children: [
                  Icon(Icons.restaurant, color: mainGreen),
                  SizedBox(width: 6),
                  Text("Waste of Food", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Every expired donation means lost meals for people in need. "
                "Help us reduce waste by scheduling donations earlier and coordinating with NGOs.",
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ExpiredCard extends StatelessWidget {
  final Map<String, dynamic> d;
  const _ExpiredCard(this.d);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(d["logo"]),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Text(d["ngo"], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("EXPIRED", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text("Food: ${d["food"]}"),
        Text("People Fed: ${d["people"]}"),

        const SizedBox(height: 6),

        Text("Donated On: ${d["date"]}", style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }
}
