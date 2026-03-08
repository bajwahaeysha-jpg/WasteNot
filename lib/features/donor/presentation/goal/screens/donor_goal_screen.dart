import 'package:flutter/material.dart';

class DonorGoalScreen extends StatefulWidget {
  const DonorGoalScreen({super.key});

  @override
  State<DonorGoalScreen> createState() => _DonorGoalScreenState();
}

class _DonorGoalScreenState extends State<DonorGoalScreen> {

  final TextEditingController controller = TextEditingController();

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Set Monthly Goal",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Set your monthly donation target",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "This will help track your impact for this month.",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter target e.g. 150",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: SizedBox(
                width: 160,
                height: 44,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                  ),

                  onPressed: () {

                    final value = int.tryParse(controller.text);

                    if (value == null || value <= 0) return;

                    Navigator.pop(context, value);

                  },

                  child: const Text(
                    "Save Goal",
                    style: TextStyle(color: Colors.white),
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