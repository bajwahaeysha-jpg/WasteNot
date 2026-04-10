import 'package:flutter/material.dart';
import 'package:wastenot/services/session_service.dart';
import 'add_donation_screen.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _donationCard(
            context,
            image: "assets/images/Orphanages.jpg",
            tag: "URGENT",
            title: "Orphanages: Protecting children in need",
            description:
                "Children in orphanages urgently need support with shelter, food and education. Your donation helps provide safety and hope.",
          ),

          const SizedBox(height: 20),

          _donationCard(
            context,
            image: "assets/images/hunger.jpg",
            tag: "",
            showButton: false,
            title: "Hunger Crisis Is Rising",
            description:
                "Hunger has increased in vulnerable communities. Thousands struggle daily. Together we can reduce hunger and save lives.",
          ),
        ],
      ),
    );
  }

  Widget _donationCard(
    BuildContext context, {
    required String image,
    required String tag,
    required String title,
    required String description,
    bool showButton = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              if (tag.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 14),

                if (showButton)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (SessionService.user?.isSuspended == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Your account is suspended. You cannot donate right now.",
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddDonationScreen()),
                        );
                      },
                      child: const Text(
                        "Donate Now",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
