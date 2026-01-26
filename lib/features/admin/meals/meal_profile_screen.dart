import 'package:flutter/material.dart';
import '../messages/chat_screen.dart';
import '../ngos/ngo_profile_screen.dart';

class MealProfileScreen extends StatelessWidget {
  final Map meal;
  const MealProfileScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final m = meal;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Meal Impact",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(_details(m)),
          const SizedBox(height: 16),
          _card(_impactSection(m)),
          const SizedBox(height: 16),
          _card(_adminActions(context, m)),
        ],
      ),
    );
  }

  // ───────────── DETAILS ─────────────

  Widget _details(Map m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meal ID: ${m['id']}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        _infoRow("NGO", m['ngo']),
        _infoRow("Donor", m['donor']),
        _infoRow("Location", m['location']),
        _infoRow("Date", m['date']),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── IMPACT SUMMARY ─────────────

  Widget _impactSection(Map m) {
    final progress = (m['meals'] / 150).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Impact Summary",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),

        /// 🍽️ Highlight Number
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5F54).withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "${m['meals']} Meals Saved",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5F54),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        /// 📊 Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: const Color(0xFF0F5F54),
            backgroundColor: Colors.grey.shade200,
          ),
        ),

        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toInt()}% of daily target achieved",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // ───────────── ADMIN ACTIONS ─────────────

  Widget _adminActions(BuildContext context, Map m) {
    return Column(
      children: [
        _centerButton(
          icon: Icons.analytics,
          label: "View NGO Performance",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NGOProfileScreen(
                  ngo: {
                    "name": m['ngo'],
                    "location": m['location'],
                    "mealsReceived": m['meals'],
                    "successRate": 92,
                    "status": "Approved",
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _centerButton(
          icon: Icons.message,
          label: "Message NGO",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(name: m['ngo']),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _centerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 240, // 🔹 smaller & centered
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F5F54),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ───────────── CARD WRAPPER ─────────────

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}
