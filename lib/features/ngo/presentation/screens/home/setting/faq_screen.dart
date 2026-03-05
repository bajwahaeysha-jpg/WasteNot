import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const Color primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // Header section
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

                  const Center(
                    child: Icon(
                      Icons.help_outline,
                      size: 85, // slightly refined
                      color: Colors.white,
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
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 20),

                  _FaqItem(
                    question: "What is WasteNot?",
                    answer:
                        "WasteNot is a platform that connects food donors with NGOs to "
                        "reduce food waste and help feed communities in need.",
                  ),

                  _FaqItem(
                    question: "Who can use WasteNot?",
                    answer:
                        "Food businesses, individuals, and NGOs can use WasteNot to donate, "
                        "accept, and distribute surplus food safely.",
                  ),

                  _FaqItem(
                    question: "Is WasteNot free to use?",
                    answer:
                        "Yes. WasteNot is completely free for NGOs and donors to use.",
                  ),

                  _FaqItem(
                    question: "How do I contact support?",
                    answer:
                        "You can contact our support team through the Contact Us section in Settings.",
                  ),

                  _FaqItem(
                    question: "How is my data protected?",
                    answer:
                        "We use industry-standard security measures to protect your data and privacy.",
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

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}