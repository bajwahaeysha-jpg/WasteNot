import 'package:flutter/material.dart';
import 'ngo_approval_detail_screen.dart';

class NgoApprovalListScreen extends StatefulWidget {
  const NgoApprovalListScreen({super.key});

  @override
  State<NgoApprovalListScreen> createState() =>
      _NgoApprovalListScreenState();
}

class _NgoApprovalListScreenState extends State<NgoApprovalListScreen> {
  static const Color mainGreen = Color(0xFF0F5F54);

  final List<Map<String, String>> ngos = [
    {
      "name": "Khair Foundation",
      "status": "Pending",
      "image": "assets/images/ngo1.png",
    },
    {
      "name": "SOS Village",
      "status": "Pending",
      "image": "assets/images/ngo3.png",
    },
    {
      "name": "Edhi Welfare",
      "status": "Pending",
      "image": "assets/images/ngo2.png",
    },
  ];

  Map<String, String>? _lastRemoved;
  int? _lastIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "NGO Approvals",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ngos.length,
        itemBuilder: (context, index) {
          final ngo = ngos[index];

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

                /// 🖼 NGO LOGO
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: AssetImage(ngo["image"]!),
                ),

                const SizedBox(width: 12),

                /// 🏢 NGO NAME
                Expanded(
                  child: Text(
                    ngo["name"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                /// 🟢 REVIEW BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Review"),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NgoApprovalDetailScreen(
                          ngoName: ngo["name"]!,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      _lastRemoved = ngo;
                      _lastIndex = index;

                      setState(() {
                        ngos.removeAt(index);
                      });

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "NGO ${result["action"]} successfully",
                          ),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                ngos.insert(
                                  _lastIndex!,
                                  _lastRemoved!,
                                );
                              });
                            },
                          ),
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
