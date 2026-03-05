import 'package:flutter/material.dart';

class SuspendNGOScreen extends StatefulWidget {

  final Map ngo;

  const SuspendNGOScreen({super.key, required this.ngo});

  @override
  State<SuspendNGOScreen> createState() => _SuspendNGOScreenState();
}

class _SuspendNGOScreenState extends State<SuspendNGOScreen> {

  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController detailCtrl = TextEditingController();

  static const primary = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Suspend NGO",
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

          /// REASON TITLE
          const Text(
            "Reason for Suspension",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          /// REASON FIELD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),

            child: TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: "Enter suspension reason",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// DETAILS TITLE
          const Text(
            "Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          /// DETAILS BOX
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),

            child: TextField(
              controller: detailCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write detailed explanation here...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// INFO CARD
          Container(
            padding: const EdgeInsets.all(16),

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

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "NGO Information",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                _detailRow("Name", widget.ngo['name']),
                const SizedBox(height: 8),
                _detailRow("Location", widget.ngo['location']),

                const SizedBox(height: 12),

                Text(
                  "The NGO will be suspended and notified regarding this action.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// SUSPEND BUTTON
          SizedBox(
            height: 50,
            width: double.infinity,

            child: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),

              onPressed: () {

                if (reasonCtrl.text.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter suspension reason"),
                    ),
                  );

                  return;
                }

                Navigator.pop(context);
              },

              icon: const Icon(Icons.block),
              label: const Text(
                "Suspend & Notify NGO",
                style: TextStyle(
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

  Widget _detailRow(String label, String value) {

    return Row(
      children: [

        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}