import 'package:flutter/material.dart';
import '../../messages/screens/chat_screen.dart';

class EmergencyDetailScreen extends StatefulWidget {
  const EmergencyDetailScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      // 🟢 TOP BAR
      appBar: AppBar(
        backgroundColor: EmergencyDetailScreen.mainGreen,
        elevation: 0,
        title: const Text("Emergency Help", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            // 🧩 Gap between bar and image
            const SizedBox(height: 8),

            // 🖼 HERO IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                "assets/images/emergency.webp",
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            // 🧾 SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const Text("Donations For Flood Affectes",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),

                const SizedBox(height: 4),

                const Text("Target: 5000",
                    style: TextStyle(color: EmergencyDetailScreen.mainGreen)),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 0.45,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade200,
                  color: EmergencyDetailScreen.mainGreen,
                  borderRadius: BorderRadius.circular(10),
                ),

                const SizedBox(height: 6),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("256+ Donated"),
                    Text("60 days left"),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EmergencyDetailScreen.mainGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(
                            donorName: "Allah Malik Hotel",
                            ngoName: "SOS Village",
                          ),
                        ),
                      );
                    },
                    child: const Text("Donate Now",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // 🧑‍🤝‍🧑 ORGANIZATION
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/images/sos logo.png"),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text("SOS Village", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    Icon(Icons.verified, color: Colors.blue, size: 14),
                    SizedBox(width: 4),
                    Text("Verified ID", style: TextStyle(fontSize: 12)),
                  ]),
                ])
              ]),
            ),

            const SizedBox(height: 12),

            // 📝 DESCRIPTION
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Description",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("20 DEC 2025", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),

                Text(
                  showMore
                      ? "Due to recent floods in Pakistan, thousands of families have lost their homes, livelihoods, and access to basic necessities. "
                        "This initiative supports flood-affected communities by providing food assistance and helping reduce hunger through organized food donations. "
                        "With your help, we can ensure a safer future for vulnerable children across affected regions."
                      : "With your support, we can help ensure survival, dignity, and a more secure future for vulnerable families across the affected regions.",
                  style: const TextStyle(height: 1.35),
                ),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: () => setState(() => showMore = !showMore),
                  child: Text(
                    showMore ? "Show Less" : "Read More",
                    style: const TextStyle(
                      color: EmergencyDetailScreen.mainGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
