import 'package:flutter/material.dart';

class ActiveScreen extends StatelessWidget {
  const ActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final operations = [
      {
        "donor": "Allah Malik Restaurant",
        "ngo": "Khair Foundation",
        "meals": "20 Persons",
        "location": "Allama Iqbal Chowk, Sialkot",
        "images": [
          "assets/images/allah_malak.png",
          "assets/images/chicken sajji.jpg",
          "assets/images/daal.jpg"
        ],
      },
      {
        "donor": "Cafe Aroma",
        "ngo": "Edhi Foundation",
        "meals": "35 Persons",
        "location": "Gulberg Lahore",
        "images": [
          "assets/images/food.jpg",
          "assets/images/Chicken.jpg",
          "assets/images/cooked rice.png"
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        title: const Text(
          "Active Operations",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: operations.length,
        itemBuilder: (context, index) {
          final item = operations[index];
          return _operationCard(context, item);
        },
      ),
    );
  }

  Widget _operationCard(BuildContext context, Map item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationDetailsScreen(
              donorName: item["donor"],
              ngoName: item["ngo"],
              images: List<String>.from(item["images"]),
              location: item["location"],
              meals: item["meals"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                item["images"][0], // first image as thumbnail
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["donor"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Waiting for pickup",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// DONATION DETAILS SCREEN
////////////////////////////////////////////////////////

class DonationDetailsScreen extends StatelessWidget {
  final String donorName;
  final String ngoName;
  final List<String> images; // now a list of images
  final String location;
  final String meals;

  const DonationDetailsScreen({
    super.key,
    required this.donorName,
    required this.ngoName,
    required this.images,
    required this.location,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF145A50),
        title: const Text(
          "Donation Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pictures section
            const Text(
              "Pictures",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      images[index],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Location section
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                "assets/images/map_dummy.png",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            _infoRow("Donor", donorName),
            _infoRow("NGO", ngoName),
            _infoRow("Servings", meals),
            _infoRow("Precaution", "Refrigeration Needed"),
            _infoRow("Description", "Beef biryani with raita & salad"),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}