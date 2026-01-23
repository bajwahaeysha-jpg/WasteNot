import 'package:flutter/material.dart';
import 'donation_profile_screen.dart';

class AllDonationsScreen extends StatelessWidget {
  const AllDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donations = [
      {
        "id": "#D1023",
        "donor": "Allah Malak Restaurant",
        "ngo": "Khair Foundation",
        "items": "Biryani, Roti",
        "quantity": 120,
        "status": "Delivered",
        "date": "12 Aug",
      },
      {
        "id": "#D1024",
        "donor": "Sialkot Food Services",
        "ngo": "Edhi Foundation",
        "items": "Bread, Cakes",
        "quantity": 80,
        "status": "In Transit",
        "date": "Today",
      },
      {
        "id": "#D1025",
        "donor": "Javson Hotel",
        "ngo": "Hope Relief",
        "items": "Rice, Curry",
        "quantity": 60,
        "status": "Expired",
        "date": "Yesterday",
      },
    ];

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
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: donations.length,
        itemBuilder: (_, i) => _donationCard(context, donations[i]),
      ),
    );
  }

  Widget _donationCard(BuildContext context, Map d) {
    final status = d['status'];

    Color statusColor;
    Color statusBg;

    if (status == "Delivered") {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade100;
    } else if (status == "In Transit") {
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationProfileScreen(donation: d),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🏷️ Donor → NGO
            Text(
              "${d['donor']} → ${d['ngo']}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            /// 📦 Items & Quantity
            Text(
              "${d['items']} • ${d['quantity']} meals",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            /// 📅 Date
            Text(
              "Date: ${d['date']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔖 Status Chip
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
