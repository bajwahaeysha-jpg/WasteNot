import 'package:flutter/material.dart';

class ExpiredDonationDetailScreen extends StatelessWidget {
  const ExpiredDonationDetailScreen({super.key, required Map<String, Object> donation});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text("Donation Details", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Status Chip
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text("EXPIRED", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),

          const SizedBox(height: 10),

          _infoRow("NGO", "Saadat Welfare"),
          _infoRow("Location", "Sialkot"),

          const Divider(height: 30),

          _infoRow("Food", "Chicken Sajji Rice"),
          _infoRow("People Fed", "30"),
          _infoRow("Donated On", "03/01/2026"),

          const SizedBox(height: 20),

          // Warning Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 165, 0, 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This donation expired before collection. Consider scheduling earlier to reduce food waste.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Food Preview Title
          const Text("Food Preview", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Smaller Food Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 6,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage("assets/images/chicken sajji.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(title, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
