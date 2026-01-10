import 'package:flutter/material.dart';
import 'accepted_dummy_data.dart';

class AcceptedDonationDetailScreen extends StatelessWidget {
  final AcceptedDonation donation;

  const AcceptedDonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donation Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Header =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(donation.date),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const Text(
                  "Completed",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1),

            _row("Donor", donation.place),
            _row("Accepted by", "Khair Foundation"),
            _row("Location", "Gulshan-e-Iqbal, Karachi"),

            const Divider(thickness: 1),

            _row("Uploaded at", "5:33 PM"),
            _row("Accepted at", "5:45 PM"),
            _row("Picked up at", "6:13 PM"),

            const Divider(thickness: 1),

            // ===== Donation Description =====
            const Text("Donation Description",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),

            const SizedBox(height: 12),

            const Text("Pictures",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),

            const SizedBox(height: 8),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _PhotoTile("assets/images/food.jpg"),
                  _PhotoTile("assets/images/food.jpg"),
                  _PhotoTile("assets/images/food.jpg"),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _row("Food", donation.food),
            _row("Servings", "80"),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.black)),
          ),
          const Text(":  ", style: TextStyle(color: Colors.black)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }
}

class _PhotoTile extends StatelessWidget {
  final String path;

  const _PhotoTile(this.path);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
    );
  }
}
