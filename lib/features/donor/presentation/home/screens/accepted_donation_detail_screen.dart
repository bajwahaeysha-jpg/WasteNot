import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';

const Color mainGreen = Color(0xFF0E5E53);

class AcceptedDonationDetailScreen extends StatelessWidget {
  const AcceptedDonationDetailScreen({super.key, required this.donation});

  final DonationModel donation;

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
            _info('Donor', donation.donorName),
            _info('Accepted by', donation.acceptedByNgoName ?? 'Not available'),
            _info('Location', donation.locationAddress ?? 'Location not set'),
            const Divider(height: 30),
            _info('Uploaded at', _formatDateTime(donation.createdAt)),
            _info(
              'Accepted at',
              donation.acceptedAt == null
                  ? 'Not available'
                  : _formatDateTime(donation.acceptedAt!),
            ),
            if (donation.completedAt != null)
              _info('Picked up at', _formatDateTime(donation.completedAt!)),
            const Divider(height: 30),
            const Text(
              'Donation Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _info(
              'Food',
              donation.foodItems.isEmpty
                  ? 'Not provided'
                  : donation.foodItems.join(', '),
            ),
            _info('Servings', donation.quantity),
            if ((donation.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(donation.description!),
            ],
            const SizedBox(height: 20),
            const Text(
              'Pictures',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (donation.imageUrls.isEmpty)
              Container(
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No images uploaded'),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: donation.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      child: Image.network(
                        donation.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
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
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} $hour:$minute $suffix';
}
