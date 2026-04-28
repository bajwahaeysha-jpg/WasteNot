import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';

class ExpiredDonationDetailScreen extends StatelessWidget {
  const ExpiredDonationDetailScreen({
    super.key,
    required this.donation,
  });

  final DonationModel donation;

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Donation Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _infoRow('Donor', donation.donorName),
            _infoRow('NGO', donation.acceptedByNgoName ?? 'Not accepted'),
            _infoRow('Location', donation.locationAddress ?? 'Location not set'),
            const Divider(height: 30),
            _infoRow(
              'Food',
              donation.foodItems.isEmpty
                  ? 'Not provided'
                  : donation.foodItems.join(', '),
            ),
            _infoRow('People Fed', donation.quantity),
            _infoRow('Donated On', _formatDate(donation.createdAt)),
            if (donation.expiryAt != null)
              _infoRow('Expired On', _formatDate(donation.expiryAt!)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 165, 0, 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This donation expired before collection. Consider scheduling earlier to reduce food waste.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Food Preview',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
              child: donation.imageUrls.isEmpty
                  ? const Icon(Icons.image_not_supported, size: 42)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        donation.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image, size: 42),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.day}/${value.month}/${value.year}';
}
