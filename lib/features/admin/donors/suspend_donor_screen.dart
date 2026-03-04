import 'package:flutter/material.dart';
import 'suspend_success_screen.dart';

class SuspendDonorScreen extends StatefulWidget {
  final Map<String, dynamic> donor;
  const SuspendDonorScreen({super.key, required this.donor});

  @override
  State<SuspendDonorScreen> createState() => _SuspendDonorScreenState();
}

class _SuspendDonorScreenState extends State<SuspendDonorScreen> {
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        title: const Text(
          "Suspend Donor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// ───── REASON BOX ─────
          const Text(
            "Reason to Suspend",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600, // ✅ heading bold
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter detailed reason here...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// ───── DETAILS CARD ─────
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600, // ✅ heading bold
                  ),
                ),
                const SizedBox(height: 14),

                _detailRow("Donor Name", widget.donor['name']),
                const SizedBox(height: 12),
                _detailRow("Location", widget.donor['location']),

                const SizedBox(height: 16),

                Text(
                  "This donor will be suspended based on the provided reason. "
                  "A notification will be sent to inform them about this action.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// ───── ACTION BUTTON ─────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuspendSuccessScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                "Suspend & Send Notification",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ───── DETAIL ROW (FIXED TYPOGRAPHY) ─────
  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500, // ✅ label slightly strong
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal, // ✅ value NOT bold
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
