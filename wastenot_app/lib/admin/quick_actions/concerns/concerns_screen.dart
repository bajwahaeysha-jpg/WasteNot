import 'package:flutter/material.dart';
import 'concern_detail_screen.dart';

class ConcernsScreen extends StatelessWidget {
  const ConcernsScreen({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    final concerns = [
      {
        "title": "Food not picked up",
        "location": "Gulberg",
        "status": "Pending",
      },
      {
        "title": "Late delivery",
        "location": "DHA Phase 5",
        "status": "In Review",
      },
      {
        "title": "Incorrect quantity delivered",
        "location": "Johar Town",
        "status": "Resolved",
      },
      {
        "title": "Packaging damaged during transit",
        "location": "Model Town",
        "status": "Pending",
      },
      {
        "title": "Driver unreachable",
        "location": "Bahria Town",
        "status": "In Review",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          "Concerns",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: concerns.length,
        itemBuilder: (_, i) => _concernCard(context, concerns[i]),
      ),
    );
  }

  // ───────────── CONCERN CARD ─────────────

  Widget _concernCard(BuildContext context, Map concern) {
    final String status = concern['status'];

    Color statusColor = status == "Resolved"
        ? Colors.green
        : status == "Pending"
            ? Colors.orange
            : Colors.blue;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConcernDetailScreen(concern: concern),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// STATUS DOT
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 14),

            /// CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concern['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        concern['location'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// STATUS CHIP
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
