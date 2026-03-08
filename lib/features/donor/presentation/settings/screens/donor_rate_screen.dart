import 'package:flutter/material.dart';

class DonorRateScreen extends StatelessWidget {
  const DonorRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // GREEN HEADER WITH BACK BUTTON
          Stack(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 80, bottom: 60),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F5D4E),
                      Color(0xFF2E7D6E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),

              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          const Text(
            "Enjoying WasteNot?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Your feedback helps us improve and reach more communities.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Icon(Icons.star, size: 36, color: Colors.amber),
              Icon(Icons.star, size: 36, color: Colors.amber),
              Icon(Icons.star, size: 36, color: Colors.amber),
              Icon(Icons.star, size: 36, color: Colors.amber),
              Icon(Icons.star_border, size: 36, color: Colors.black),

            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "Rate on Play Store",
            style: TextStyle(
              color: Color(0xFF0F5D4E),
              decoration: TextDecoration.underline,
              fontSize: 16,
            ),
          ),

        ],
      ),
    );
  }
}