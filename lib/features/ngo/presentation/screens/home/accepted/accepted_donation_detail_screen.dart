import 'package:flutter/material.dart';
import 'accepted_dummy_data.dart';

class AcceptedDonationDetailScreen extends StatelessWidget {
  final AcceptedDonation donation;

  const AcceptedDonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Donation Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ===== Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(donation.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Completed",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),

              /// ===== Basic Info =====
              _row("Donor", donation.place),
              _row("Accepted by", "Khair Foundation"),
              _row("Location", "Gulshan-e-Iqbal, Karachi"),

              const SizedBox(height: 8),
              const Divider(),

              /// ===== Times =====
              _row("Uploaded at", "5:33 PM"),
              _row("Accepted at", "5:45 PM"),
              _row("Picked up at", "6:13 PM"),

              const SizedBox(height: 10),
              const Divider(),

              /// ===== Donation Description =====
              const Text(
                "Donation Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Pictures",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

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

              const SizedBox(height: 18),

              /// ===== Food Info =====
              _row("Food", donation.food),
              _row("Servings", "80"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87),
            ),
          ),

          const Text(":  "),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
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
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}