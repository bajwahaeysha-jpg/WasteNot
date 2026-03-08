import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // Header
          Container(
            height: 230,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F4C45),
                  Color(0xFF2E7D72),
                ],
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

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [

                        Icon(
                          Icons.volunteer_activism,
                          size: 80, // slightly refined
                          color: Colors.white,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "WasteNot",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "About WasteNot",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "WasteNot is a social impact platform built to reduce food waste "
                    "and fight hunger by connecting food donors with NGOs who distribute "
                    "surplus food to communities in need.",
                    style: TextStyle(height: 1.5, color: Colors.black),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "To ensure no edible food is wasted and every community has access "
                    "to nutritious meals through collaboration, transparency, and technology.",
                    style: TextStyle(height: 1.5, color: Colors.black),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Why WasteNot?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Millions of tons of food are wasted every year while millions go hungry. "
                    "WasteNot bridges this gap by making food rescue simple, efficient, and impactful.",
                    style: TextStyle(height: 1.5, color: Colors.black),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Version",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "1.0.0",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}