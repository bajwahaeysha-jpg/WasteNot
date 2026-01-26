import 'package:flutter/material.dart';
import 'donor_profile_screen.dart';

class AllDonorsScreen extends StatefulWidget {
  const AllDonorsScreen({super.key});

  @override
  State<AllDonorsScreen> createState() => _AllDonorsScreenState();
}

class _AllDonorsScreenState extends State<AllDonorsScreen> {
  String selectedStatus = "All";

  final donors = [
    {
      "name": "Allah Malik",
      "type": "Restaurant",
      "location": "Cantt",
      "meals": 145,
      "rating": 4.6,
      "status": "Active",
      "logo": "assets/images/allah_malak.png",
    },
    {
      "name": "Javson Hotel",
      "type": "Hotel",
      "location": "City Housing",
      "meals": 210,
      "rating": 4.8,
      "status": "Active",
      "logo": "assets/images/hotel_javson.png",
    },
    {
      "name": "Sialkot Food Services",
      "type": "Catering",
      "location": "Sialkot",
      "meals": 98,
      "rating": 4.3,
      "status": "Suspended",
      "logo": "assets/images/sialkot_donor.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedStatus == "All"
        ? donors
        : donors.where((d) => d['status'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "All Donors",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) => _donorCard(filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── FILTER BAR ─────────

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Center(
        child: Wrap(
          spacing: 10,
          children: [
            _statusChip("All"),
            _statusChip("Active"),
            _statusChip("Suspended"),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final bool selected = selectedStatus == status;

    return GestureDetector(
      onTap: () => setState(() => selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F5F54) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF0F5F54)),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF0F5F54),
          ),
        ),
      ),
    );
  }

  // ───────── DONOR CARD ─────────

  Widget _donorCard(Map d) {
    final bool active = d['status'] == "Active";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          MaterialPageRoute(builder: (_) => DonorProfileScreen(donor: d)),
        ),
        child: Row(
          children: [

            /// 🖼️ DONOR LOGO (same size, UI unchanged)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0F5F54).withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  d['logo'],
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 📋 DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${d['type']} • ${d['location']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Meals: ${d['meals']} • Rating: ${d['rating']} ⭐",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// 🟢 STATUS
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                d['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
