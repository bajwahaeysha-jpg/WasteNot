import 'package:flutter/material.dart';
import 'donation_model.dart';

class DonationDetailsScreen extends StatelessWidget {
  final Donation donation;

  const DonationDetailsScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donation Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              donation.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donation.foodName,
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 8),
                  Text(donation.description),

                  const SizedBox(height: 16),

                  _info("Uploaded", donation.uploadTime),
                  _info("Status", donation.status),
                  _info("Servings", "${donation.servings} people"),
                  _info("Pickup Location", donation.location),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel Donation"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
