import 'package:flutter/material.dart';
import 'donation_issue_detail_screen.dart';

class DonationIssuesListScreen extends StatefulWidget {
  const DonationIssuesListScreen({super.key});

  @override
  State<DonationIssuesListScreen> createState() =>
      _DonationIssuesListScreenState();
}

class _DonationIssuesListScreenState extends State<DonationIssuesListScreen> {
  static const Color mainGreen = Color(0xFF0F5F54);

  final List<Map<String, String>> issues = [
    {
      "title": "Food quality issue",
      "donor": "Allah Malik",
      "ngo": "Khair Foundation",
      "time": "30 min ago",
    },
    {
      "title": "Late pickup",
      "donor": "Hotel Sialkot",
      "ngo": "SOS Village",
      "time": "2 hrs ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Donation Issues",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];

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
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.report_problem, color: Colors.white),
                ),
                const SizedBox(width: 12),

                /// 🧾 Issue Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue["title"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Donor: ${issue["donor"]}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "NGO: ${issue["ngo"]}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        issue["time"]!,
                        style: const TextStyle(
                          color: Colors.orange,
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
                        builder: (_) => DonationIssueDetailScreen(
                          issue: issue,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        issues.removeAt(index);
                      });

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "Issue ${result["action"]} successfully",
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
