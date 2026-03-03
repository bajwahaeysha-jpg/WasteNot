import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/models/accepted_donation_model.dart';
import 'donation_detail_screen.dart';

class YourDonationsScreen extends StatefulWidget {
  const YourDonationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<YourDonationsScreen> createState() => _YourDonationsScreenState();
}

class _YourDonationsScreenState extends State<YourDonationsScreen> {

  final List<AcceptedDonation> donations = [
    AcceptedDonation(
      food: "Cooked Rice",
      place: "SOS Village",
      time: "Today",
      image: "assets/images/biryani.jpg",
      donor: "SOS Village",
      acceptedBy: "NGO",
      location: "Sialkot",
      uploadedAt: "10:00 AM",
      acceptedAt: "10:30 AM",
      servings: 25,
      status: "ACTIVE",
    ),
    AcceptedDonation(
      food: "Fresh Meal",
      place: "Khair Foundation",
      time: "Today",
      image: "assets/images/biryani.jpg",
      donor: "Khair Foundation",
      acceptedBy: "NGO",
      location: "Sialkot",
      uploadedAt: "11:00 AM",
      acceptedAt: "11:30 AM",
      pickedAt: "12:15 PM",
      servings: 40,
      status: "COMPLETED",
    ),
    AcceptedDonation(
      food: "Chicken Biryani",
      place: "Al-Khidmat Foundation",
      time: "Today",
      image: "assets/images/biryani.jpg",
      donor: "Al-Khidmat Foundation",
      acceptedBy: "NGO",
      location: "Sialkot",
      uploadedAt: "1:00 PM",
      acceptedAt: "1:20 PM",
      servings: 30,
      status: "ACTIVE",
    ),
    AcceptedDonation(
      food: "Chicken Sajji Rice",
      place: "SOS Village",
      time: "Yesterday",
      image: "assets/images/biryani.jpg",
      donor: "SOS Village",
      acceptedBy: "NGO",
      location: "Sialkot",
      uploadedAt: "4:00 PM",
      acceptedAt: "4:20 PM",
      pickedAt: "5:10 PM",
      servings: 30,
      status: "COMPLETED",
    ),
        AcceptedDonation(
      food: "Chicken Biryani",
      place: "Khair Foundation",
      time: "03/01/2026",
      image: "assets/images/biryani.jpg",
      donor: "Khair Foundation",
      acceptedBy: "NGO",
      location: "Sialkot",
      uploadedAt: "2:00 PM",
      acceptedAt: "2:20 PM",
      pickedAt: "3:10 PM",
      servings: 20,
      status: "COMPLETED",
    ),
 ];

  int get total => donations.length;
  int get active => donations.where((e) => e.status == "ACTIVE").length;
  int get completed => donations.where((e) => e.status == "COMPLETED").length;

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: YourDonationsScreen.mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text("Your Donations", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🔢 TOP STATS
          Row(children: [
            _Stat("Total", total, Icons.volunteer_activism, Colors.blueGrey),
            const SizedBox(width: 10),
            _Stat("Active", active, Icons.autorenew, YourDonationsScreen.mainGreen),
            const SizedBox(width: 10),
            _Stat("Completed", completed, Icons.check_circle, Colors.teal),
          ]),

          const SizedBox(height: 18),

          ...donations.map((d) => DonationCard(
                donation: d,
                onUpdated: refresh,
              )),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _Stat(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 6)],
        ),
        child: Column(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: .15), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  final AcceptedDonation donation;
  final VoidCallback onUpdated;

  const DonationCard({super.key, required this.donation, required this.onUpdated});

  bool get isActive => donation.status == "ACTIVE";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationDetailScreen(
              donation: donation,
              onStatusChanged: onUpdated,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.groups)),
            const SizedBox(width: 10),
            Expanded(child: Text(donation.place, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? YourDonationsScreen.mainGreen : Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(donation.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
            )
          ]),
          const SizedBox(height: 8),
          Text("Food: ${donation.food}"),
          Text("People Fed: ${donation.servings}"),
          const SizedBox(height: 6),
          Text("Donated On: ${donation.time}", style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}
