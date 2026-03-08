import 'package:flutter/material.dart';

class DonorAboutScreen extends StatelessWidget {
  const DonorAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Column(
                    children: const [

                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 70,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "WasteNot",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "About WasteNot",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "WasteNot is a social impact platform built to reduce food waste and fight hunger by connecting food donors with NGOs who distribute surplus food to communities in need.",
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "To ensure no edible food is wasted and every community has access to nutritious meals through collaboration, transparency, and technology.",
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "Why WasteNot?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Millions of tons of food are wasted every year while millions go hungry. WasteNot bridges this gap by making food rescue simple, efficient, and impactful.",
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "Version",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "1.0.0",
                    style: TextStyle(color: Colors.grey),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}