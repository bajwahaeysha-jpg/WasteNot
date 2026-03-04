import 'package:flutter/material.dart';

class RateUsScreen extends StatelessWidget {
  const RateUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // Header
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Center(
                    child: Icon(Icons.star_rate, size: 90, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "Enjoying WasteNot?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Your feedback helps us improve and reach more communities.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 36),
              Icon(Icons.star, color: Colors.amber, size: 36),
              Icon(Icons.star, color: Colors.amber, size: 36),
              Icon(Icons.star, color: Colors.amber, size: 36),
              Icon(Icons.star_border, size: 36),
            ],
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              
            },
            child: const Text(
              "Rate on Play Store",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
