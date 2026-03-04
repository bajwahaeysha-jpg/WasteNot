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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54), // ✅ color unchanged
        title: const Text(
          "Suspend NGO",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Reason (Heading only) ─────
            const Text(
              "Reason",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: "Enter reason",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 16),

            // ───── Detail (Big box) ─────
            const Text(
              "Details",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: detailCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write detailed explanation here...",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const Spacer(),

            // ───── Button ─────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5F54), // ✅ unchanged
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Suspend & Send Notification",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
