import 'package:flutter/material.dart';
import 'ngo_profile_screen.dart';

class AllNGOsScreen extends StatefulWidget {
  const AllNGOsScreen({super.key});

  @override
  State<AllNGOsScreen> createState() => _AllNGOsScreenState();
}

class _AllNGOsScreenState extends State<AllNGOsScreen> {
  String selectedStatus = "All";

  final ngos = [
    {
      "name": "Khair Foundation",
      "location": "Iqbal chowk, Sialkot",
      "mealsReceived": 1240,
      "successRate": 92,
      "status": "Approved",
      "logo": "assets/images/ngo1.png",
    },
    {
      "name": "Edhi Foundation",
      "location": "Defence road, Sialkot",
      "mealsReceived": 980,
      "successRate": 88,
      "status": "Approved",
      "logo": "assets/images/ngo2.png",
    },
    {
      "name": "SOS Children’s Village",
      "location": "Khadam Ali chok,Sialkot",
      "mealsReceived": 670,
      "successRate": 81,
      "status": "Suspended",
      "logo": "assets/images/ngo3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedStatus == "All"
        ? ngos
        : ngos.where((n) => n['status'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        title: const Text(
          "All NGOs",
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

          /// 🔹 FILTER BAR
          _filterBar(),

          /// 🔹 NGO LIST
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) => _ngoCard(filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── FILTER BAR ─────────────

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 10,
          children: [
            _statusChip("All"),
            _statusChip("Approved"),
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
          color: selected ? const Color(0xFF0F4C45) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF0F4C45)),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF0F4C45),
          ),
        ),
      ),
    );
  }

  // ───────────── NGO CARD ─────────────

  Widget _ngoCard(Map n) {
    final bool approved = n['status'] == "Approved";

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
          MaterialPageRoute(builder: (_) => NGOProfileScreen(ngo: n)),
        ),
        child: Row(
          children: [

            /// 🏢 NGO LOGO
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5F54).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                n['logo'],
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            /// 📋 NGO DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['location'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Meals: ${n['mealsReceived']} • Success: ${n['successRate']}%",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// 🟢 STATUS BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: approved
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                n['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: approved
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