import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/models/accepted_donation_model.dart';
import 'accepted_donation_detail_screen.dart';

const Color mainGreen = Color(0xFF0E5E53);

class AcceptedDonationsScreen extends StatelessWidget {
  const AcceptedDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> donations = [

      // ===== Today =====
      {
        "date": "Today",
        "data": AcceptedDonation(
          food: "Chicken Biryani",
          place: "Allah Malik Restaurant",
          time: "12:30 PM",
          image: "assets/images/biryani.jpg",
          donor: "Allah Malik Restaurant",
          acceptedBy: "Khair Foundation",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "5:33 PM",
          acceptedAt: "5:45 PM",
          pickedAt: "6:13 PM",
          servings: 80,
        ),
      },
      {
        "date": "Today",
        "data": AcceptedDonation(
          food: "Chicken Sajji Rice",
          place: "Allah Malik Restaurant",
          time: "11:15 AM",
          image: "assets/images/chicken sajji.jpg",
          donor: "Allah Malik Restaurant",
          acceptedBy: "SOS Village",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "4:40 PM",
          acceptedAt: "5:00 PM",
          pickedAt: "5:30 PM",
          servings: 60,
        ),
      },

      // ===== Yesterday =====
      {
        "date": "Yesterday",
        "data": AcceptedDonation(
          food: "Fresh Meal",
          place: "Allah Malik Restaurant",
          time: "9:40 AM",
          image: "assets/images/meals.jpg",
          donor: "Allah Malik Restaurant",
          acceptedBy: "Khair Foundation",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "3:20 PM",
          acceptedAt: "3:45 PM",
          pickedAt: "4:10 PM",
          servings: 40,
        ),
      },
      {
        "date": "Yesterday",
        "data": AcceptedDonation(
          food: "Cooked Rice",
          place: "Allah Malik Restaurant",
          time: "8:20 PM",
          image: "assets/images/cooked rice.png",
          donor: "Allah Malik Restaurant",
          acceptedBy: "SOS Village",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "7:10 PM",
          acceptedAt: "7:40 PM",
          pickedAt: "8:05 PM",
          servings: 50,
        ),
      },

      // ===== 4/01/2026 =====
      {
        "date": "4/01/2026",
        "data": AcceptedDonation(
          food: "Chicken Biryani",
          place: "Allah Malik Restaurant",
          time: "2:10 PM",
          image: "assets/images/biryani.jpg",
          donor: "Allah Malik Restaurant",
          acceptedBy: "Khair Foundation",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "1:40 PM",
          acceptedAt: "1:55 PM",
          pickedAt: "2:30 PM",
          servings: 70,
        ),
      },

      // ===== 3/01/2026 =====
      {
        "date": "3/01/2026",
        "data": AcceptedDonation(
          food: "Chicken Sajji Rice",
          place: "Allah Malik Restaurant",
          time: "1:45 PM",
          image: "assets/images/chicken sajji.jpg",
          donor: "Allah Malik Restaurant",
          acceptedBy: "SOS Village",
          location: "Kotli Loharan, Sialkot",
          uploadedAt: "12:50 PM",
          acceptedAt: "1:10 PM",
          pickedAt: "1:30 PM",
          servings: 55,
        ),
      },
    ];

    String lastDate = "";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text("Accepted Donations", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final item = donations[index];
          final AcceptedDonation d = item["data"];
          final String date = item["date"];

          final bool showHeader = date != lastDate;
          lastDate = date;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (showHeader)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    date,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcceptedDonationDetailScreen(donation: d),
                  ),
                ),
                child: _donationCard(d),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _donationCard(AcceptedDonation d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(d.image, height: 48, width: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.food, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(d.place, style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          Text(
            d.time,
            style: const TextStyle(color: mainGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
