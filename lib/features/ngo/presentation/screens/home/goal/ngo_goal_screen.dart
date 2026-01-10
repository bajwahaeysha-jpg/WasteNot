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
      appBar: AppBar(title: const Text("Set Monthly Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set your monthly donation target",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  onPressed: () {
                    final value = int.tryParse(controller.text);
                    if (value == null || value <= 0) return;
                    Navigator.pop(context, value);
                  },
                  child: const Text("Save Goal"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
