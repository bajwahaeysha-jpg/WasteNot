import 'package:flutter/material.dart';

class DonorRateScreen extends StatelessWidget {
  const DonorRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Rate Us",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Enjoying WasteNot?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.star, size: 34, color: Colors.amber),
            Icon(Icons.star, size: 34, color: Colors.amber),
            Icon(Icons.star, size: 34, color: Colors.amber),
            Icon(Icons.star, size: 34, color: Colors.amber),
            Icon(Icons.star_border, size: 34, color: Colors.amber),
          ]),
        ]),
      ),
    );
  }
}
