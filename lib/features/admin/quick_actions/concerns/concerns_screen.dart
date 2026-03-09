import 'package:flutter/material.dart';

class ConcernsScreen extends StatefulWidget {
  const ConcernsScreen({super.key});

  @override
  State<ConcernsScreen> createState() => _ConcernsScreenState();
}

class _ConcernsScreenState extends State<ConcernsScreen> {
  static const Color mainGreen = Color(0xFF0F4C45);

  final List<Map<String, dynamic>> concerns = [
    {
      "title": "Orphanages need consistent food support",
      "description":
          "Multiple orphanages are reporting irregular food availability. "
          "This concern helps the admin team understand gaps in food distribution.",
      "raisedBy": "SOS Children’s Villages",
      "image": "assets/images/Orphanages.jpg",
    },
    {
      "title": "Increase in food wastage reported",
      "description":
          "NGOs are reporting frequent food wastage due to poor coordination. "
          "Monitoring this helps reduce unnecessary food loss.",
      "raisedBy": "Javson Hotel",
      "image": "assets/images/food_waste.png",
    },
    {
      "title": "Shortage of meals during weekends",
      "description":
          "Some NGOs experience food shortages during weekends and holidays. "
          "This concern highlights demand spikes across cities.",
      "raisedBy": "Khair Foundation",
      "image": "assets/images/hunger.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          "Concerns",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: concerns.length,
        itemBuilder: (_, i) => _concernCard(concerns[i], i),
      ),
    );
  }

  // ───────── CONCERN CARD (ADMIN VIEW) ─────────

  Widget _concernCard(Map concern, int index) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.asset(
                concern['image'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    concern['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPTION
                  Text(
                    concern['description'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// RAISED BY
                  Text(
                    "Concern raised by ${concern['raisedBy']}",
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: mainGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── REMOVE CONFIRMATION ─────────

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Concern"),
        content: const Text(
          "This concern will be permanently removed. "
          "Do you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => concerns.removeAt(index));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}
