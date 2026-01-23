import 'package:flutter/material.dart';
import 'your_donations_screen.dart';
import 'accepted_donations_screen.dart';
import 'expired_donations_screen.dart';
import 'emergency_detail_screen.dart';
import '../../donate/screens/add_donation_screen.dart';
import '../../messages/screens/chat_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  final String donorName = "Allah Malik Hotel";

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recentDonations = [
      {"ngo": "SOS Village", "time": "Donated 30 mins ago", "logo": "assets/images/sos logo.png"},
      {"ngo": "Khair Foundation", "time": "Donated 2 hours ago", "logo": "assets/images/khair logo.png"},
      {"ngo": "SOS Village", "time": "Donated yesterday", "logo": "assets/images/sos logo.png"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: DonorHomeScreen.mainGreen,
        title: const Text("WasteNot", style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 10),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("A", style: TextStyle(color: DonorHomeScreen.mainGreen)),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // 🔍 Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search donations, locations, features...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Welcome Back!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Allah Malik Hotel, ready to make a difference?"),

          const SizedBox(height: 16),

          // 🎁 Summary Cards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourDonationsScreen())),
                  child: const _SummaryCard("Your Donations", Icons.card_giftcard, Colors.purple),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcceptedDonationsScreen())),
                  child: const _SummaryCard("Accepted Donations", Icons.check_circle, Colors.green),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiredDonationsScreen())),
                  child: const _SummaryCard("Expired Donations", Icons.error_outline, Colors.redAccent),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // 🧑‍🤝‍🧑 Emergency Help
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyDetailScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text("Emergency Help", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("See all", style: TextStyle(color: DonorHomeScreen.mainGreen)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("assets/images/emergency.webp", height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                const Text("Donations For Flood Affectes", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Target: 5000", style: TextStyle(color: DonorHomeScreen.mainGreen)),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          const _MakeDifferenceCard(),

          const SizedBox(height: 24),

          const _SectionHeader("Local Donation Opportunities"),
          const SizedBox(height: 8),
          const Text("Assist local charities and help those in the Sialkot community."),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(
              child: _DonationCard(
                "SOS Village",
                "Help provide meals to orphaned children.",
                "assets/images/sos.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        donorName: donorName,
                        ngoName: "SOS Village",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DonationCard(
                "Sialkot Shelter",
                "Support a local shelter with essential supplies.",
                "assets/images/sialkot.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        donorName: donorName,
                        ngoName: "Sialkot Shelter",
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),

          const SizedBox(height: 24),

          const _SectionHeader("Recent Donations"),
          const SizedBox(height: 12),

          ...recentDonations.map((d) => _RecentDonationTile(d["ngo"]!, d["time"]!, d["logo"]!)),

          const SizedBox(height: 16),

          const _ImpactSection(),
        ]),
      ),
    );
  }
}

/* ================= COMPONENTS ================= */

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text("View all >", style: TextStyle(color: Colors.grey)),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SummaryCard(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final String title, subtitle, image;
  final VoidCallback onDonate;

  const _DonationCard(this.title, this.subtitle, this.image, this.onDonate);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, height: 90, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DonorHomeScreen.mainGreen),
            onPressed: onDonate,
            child: const Text("Donate Now", style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class _RecentDonationTile extends StatelessWidget {
  final String name, time, logo;
  const _RecentDonationTile(this.name, this.time, this.logo);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.white, backgroundImage: AssetImage(logo)),
      title: Text(name),
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _MakeDifferenceCard extends StatelessWidget {
  const _MakeDifferenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.favorite, color: DonorHomeScreen.mainGreen),
          SizedBox(width: 6),
          Text("Make a Difference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        const Text("Fight food waste and hunger by donating your surplus food to those in need."),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DonorHomeScreen.mainGreen),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDonationScreen()));
            },
            child: const Text("Donate Surplus Food", style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.insights, color: DonorHomeScreen.mainGreen),
          SizedBox(width: 6),
          Text("Your Impact This Month", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          _ImpactItem(title: "Donations Made", value: "12"),
          _ImpactItem(title: "People Fed", value: "240"),
        ]),
        const SizedBox(height: 14),
        const Text("Monthly Goal Progress", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.48,
            minHeight: 10,
            backgroundColor: Colors.grey,
            color: DonorHomeScreen.mainGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text("48% completed — Keep it up! 🌟"),
      ]),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final String title, value;
  const _ImpactItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DonorHomeScreen.mainGreen)),
      Text(title, style: const TextStyle(color: Colors.grey)),
    ]);
  }
}
