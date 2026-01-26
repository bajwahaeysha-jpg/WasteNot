import 'package:flutter/material.dart';
import 'expired_donation_detail_screen.dart';

class ExpiredDonationsListScreen extends StatefulWidget {
  const ExpiredDonationsListScreen({super.key});

  @override
  State<ExpiredDonationsListScreen> createState() =>
      _ExpiredDonationsListScreenState();
}

class _ExpiredDonationsListScreenState
    extends State<ExpiredDonationsListScreen> {
  static const Color mainGreen = Color(0xFF0F5F54);

  final List<Map<String, String>> donations = [
    {
      "title": "Cooked Rice",
      "donor": "Allah Malik",
      "time": "Expired 2 hrs ago",
    },
    {
      "title": "Bread Packs",
      "donor": "Hotel Sialkot",
      "time": "Expired 5 hrs ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Expired Donations",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final d = donations[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.timer_off, color: Colors.white),
                ),
                const SizedBox(width: 12),

                /// 🧾 Donation Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d["title"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Donor: ${d["donor"]}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d["time"]!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔍 Review Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Review"),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpiredDonationDetailScreen(
                          donation: d,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        donations.removeAt(index);
                      });

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "Donation ${result["action"]} successfully",
                          ),
                          duration: const Duration(seconds: 10), // ⏱️ auto close
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
