import 'package:flutter/material.dart';
import 'donation_profile_screen.dart';

class AllDonationsScreen extends StatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  State<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> donations = [
    {
      "donor": "Allah Malak Restaurant",
      "ngo": "Khair Foundation",
      "items": "Biryani, Roti",
      "quantity": 120,
      "status": "Completed",
      "date": "12 Aug",
    },
    {
      "donor": "Sialkot Food Services",
      "ngo": "Edhi Foundation",
      "items": "Bread, Cakes",
      "quantity": 80,
      "status": "Active",
      "date": "Today",
    },
    {
      "donor": "Javson Hotel",
      "ngo": "Hope Relief",
      "items": "Rice, Curry",
      "quantity": 60,
      "status": "Expired",
      "date": "Yesterday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDonations = selectedFilter == "All"
        ? donations
        : donations.where((d) => d['status'] == selectedFilter);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "All Donations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [

          /// 🔹 FILTER BAR (LEFT + ONE LINE)
          _statusFilterBar(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              itemCount: filteredDonations.length,
              itemBuilder: (_, i) =>
                  _donationCard(context, filteredDonations.elementAt(i)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── FILTER BAR ─────────

  Widget _statusFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip("All"),
            const SizedBox(width: 10),
            _filterChip("Active"),
            const SizedBox(width: 10),
            _filterChip("Expired"),
            const SizedBox(width: 10),
            _filterChip("Completed"),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool selected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F5F54) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF0F5F54)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                selected ? Colors.white : const Color(0xFF0F5F54),
          ),
        ),
      ),
    );
  }

  // ───────── DONATION CARD ─────────

  Widget _donationCard(BuildContext context, Map<String, dynamic> d) {
    final status = d['status'];

    Color statusColor;
    Color statusBg;

    if (status == "Completed") {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade100;
    } else if (status == "Active") {
      statusColor = Colors.orange.shade700;
      statusBg = Colors.orange.shade100;
    } else {
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade100;
    }

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationProfileScreen(donation: d),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${d['donor']} → ${d['ngo']}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${d['items']} • ${d['quantity']} meals",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Date: ${d['date']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
