import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class ActiveScreen extends StatelessWidget {
  const ActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donationService = DonationService();
    final currentUser = SessionService.user;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final donorId = currentUser?.isDonor == true ? userId : null;
    final ngoId = currentUser?.isNgo == true ? userId : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        title: const Text(
          "Active Operations",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<DonationModel>>(
        stream: donationService
    .streamDonationsByStatus(
      status: DonationStatus.accepted,
      donorId: donorId,
      ngoId: ngoId,
    )
    .map((list) =>
        list.where((item) => item.isCompleted != true).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('No active operations'));
          }

          final operations = snapshot.data ?? <DonationModel>[];
          if (operations.isEmpty) {
            return const Center(child: Text('No active operations'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: operations.length,
            itemBuilder: (context, index) {
              final item = operations[index];
              return _operationCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _operationCard(BuildContext context, DonationModel item) {
    final imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls.first : null;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationDetailsScreen(donation: item),
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
              child: imageUrl == null
                  ? Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    )
                  : Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.donorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.isAccepted ? 'Pickup in progress' : 'Waiting for pickup',
                    style: const TextStyle(color: Colors.grey),
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
  final DonationModel donation;

  const DonationDetailsScreen({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    final images = donation.imageUrls;
    final ngoName = (donation.acceptedByNgoName?.trim().isNotEmpty ?? false)
        ? donation.acceptedByNgoName!.trim()
        : 'Not assigned';
    final location = donation.locationAddress ?? '';
    final description = donation.description?.trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
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

            /// 🔹 Pictures
            const Text(
              "Pictures",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 95,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.isEmpty ? 1 : images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (images.isEmpty) {
                    return _imageBox(null);
                  }
                  return _imageBox(images[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Location
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

            const SizedBox(height: 12),

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
                const SizedBox(width: 8),
                const Text(
                  "1.2 km",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Estimated Time",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "2 mins",
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(height: 30),

            /// 🔹 Info Rows
            _infoRow("Donor", donation.donorName),
            _infoRow("Serving Plate", "Serving Plate"),
            _infoRow("Servings", donation.quantity),

            /// ✅ CHANGED (Contact → Accepted by)
            _infoRow("Accepted by", ngoName),

            const SizedBox(height: 20),

            /// 🔹 Description
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 70, // 🔥 always 2 lines space
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                description.isEmpty
                    ? "No description provided"
                    : description,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🔹 Image Box
  Widget _imageBox(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: url == null
          ? Container(
              width: 90,
              height: 90,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported),
            )
          : Image.network(
              url,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image),
              ),
            ),
    );
  }

  /// 🔹 Info Row
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
