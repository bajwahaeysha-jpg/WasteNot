import 'package:flutter/material.dart';
import 'expire_success_screen.dart';

class ExpireReasonScreen extends StatefulWidget {
  final Map<String, dynamic> donation;
  const ExpireReasonScreen({super.key, required this.donation});

  @override
  State<ExpireReasonScreen> createState() => _ExpireReasonScreenState();
}

class _ExpireReasonScreenState extends State<ExpireReasonScreen> {
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ white icons
        title: const Text(
          "Expire Donation",
          style: TextStyle(
            color: Colors.white, // ✅ white text
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ───── TITLE ─────
            const Text(
              "Reason for Expiring",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please provide a clear reason. This will be sent "
              "as a notification to the donor and NGO.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            /// ───── INPUT ─────
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter reason here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 26),

            /// ───── DONATION SUMMARY (CLEAN, NO CONTAINER) ─────
            const Text(
              "Donation Summary",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            _infoRow("Donor", widget.donation['donor']),
            _infoRow("Food", widget.donation['items']),
            _infoRow(
              "Servings",
              widget.donation['quantity'].toString(),
            ),

            const Spacer(),

            /// ───── ACTION BUTTON ─────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a reason first"),
                      ),
                    );
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpireSuccessScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  "Mark Expired & Notify",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // ✅ white text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
