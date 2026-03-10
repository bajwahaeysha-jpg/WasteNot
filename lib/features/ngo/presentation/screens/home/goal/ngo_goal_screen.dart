import 'package:flutter/material.dart';

class NgoGoalScreen extends StatefulWidget {
  const NgoGoalScreen({super.key});

  @override
  State<NgoGoalScreen> createState() => _NgoGoalScreenState();
}

class _NgoGoalScreenState extends State<NgoGoalScreen> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Set your monthly donation target",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "This will help track your impact for this month.",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 22),

            /// Goal Field
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: "Enter target e.g. 150",
                filled: true,
                fillColor: Colors.white,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F4C45),
                    width: 1.5,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F4C45),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// Save Button
            Center(
              child: SizedBox(
                width: 170,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {
                    final value = int.tryParse(controller.text);
                    if (value == null || value <= 0) return;

                    Navigator.pop(context, value);
                  },

                  child: const Text(
                    "Save Goal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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