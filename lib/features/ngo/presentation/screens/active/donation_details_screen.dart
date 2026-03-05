import 'package:flutter/material.dart';
import 'donation_model.dart';

class DonationDetailsScreen extends StatelessWidget {
  final Donation donation;

  const DonationDetailsScreen({super.key, required this.donation});

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
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// PICTURES TITLE
              const Text(
                "Pictures",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              /// PICTURES ROW
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _photo(donation.imageUrl),
                    _photo(donation.imageUrl),
                    _photo(donation.imageUrl),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// FOOD NAME
              Text(
                donation.foodName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                donation.description,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),

              /// INFO SECTION
              _info("Uploaded", donation.uploadTime),
              _info("Status", donation.status),
              _info("Servings", "${donation.servings} people"),
              _info("Pickup Location", donation.location),

              const SizedBox(height: 30),

              /// CANCEL BUTTON
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel Donation",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// INFO ROW
  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// PHOTO TILE
  Widget _photo(String path) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}