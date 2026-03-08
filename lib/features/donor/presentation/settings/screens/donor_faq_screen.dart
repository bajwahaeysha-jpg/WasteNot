import 'package:flutter/material.dart';

class DonorFaqScreen extends StatelessWidget {
  const DonorFaqScreen({super.key});

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
                  child: const Center(
                    child: Icon(
                      Icons.help_outline,
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "What is WasteNot?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "WasteNot is a platform that connects food donors with NGOs to reduce food waste and help feed communities in need.",
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),

                  SizedBox(height: 18),

                  Text(
                    "Who can use WasteNot?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Food businesses, individuals, and NGOs can use WasteNot to donate, accept, and distribute surplus food safely.",
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),

                  SizedBox(height: 18),

                  Text(
                    "Is WasteNot free to use?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Yes. WasteNot is completely free for NGOs and donors to use.",
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),

                  SizedBox(height: 18),

                  Text(
                    "How do I contact support?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "You can contact our support team through the Contact Us section in Settings.",
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),

                  SizedBox(height: 18),

                  Text(
                    "How is my data protected?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "We use industry-standard security measures to protect your data and privacy.",
                    style: TextStyle(color: Colors.black54, height: 1.4),
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