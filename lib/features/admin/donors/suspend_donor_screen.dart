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

  static const Color mainGreen = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Suspend Donor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// TITLE
          const Text(
            "Reason for Suspension",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          /// REASON BOX
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),

            child: TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter suspension reason...",
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 28),

          /// DONOR DETAILS CARD
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Donor Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                _detailRow("Name", widget.donor['name']),
                const SizedBox(height: 12),

                _detailRow("Location", widget.donor['location']),
                const SizedBox(height: 12),

                _detailRow("Phone", widget.donor['phone']),

                const SizedBox(height: 16),

                Text(
                  "This donor will be suspended and notified about this action.",
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

          /// SUSPEND BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(

              onPressed: () {

                if (reasonController.text.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter suspension reason"),
                    ),
                  );

                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuspendSuccessScreen(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),

              child: const Text(
                "Suspend Donor",
                style: TextStyle(
                  fontSize: 16,
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

  /// DETAIL ROW
  Widget _detailRow(String label, String value) {

    return Row(
      children: [

        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}