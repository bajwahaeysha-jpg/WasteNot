import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';

class AcceptedDonationDetailScreen extends StatelessWidget {
  const AcceptedDonationDetailScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  Widget build(BuildContext context) {
    final isCompleted = donation.isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Donation Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(donation.createdAt),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isCompleted ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      donation.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              _row('Donor', donation.donorName),
              _row('Accepted by', donation.acceptedByNgoName ?? 'This NGO'),
              _row('Location', donation.location ?? 'Not provided'),
              const SizedBox(height: 8),
              const Divider(),
              _row('Uploaded at', _formatDateTime(donation.createdAt)),
              _row(
                'Accepted at',
                donation.acceptedAt == null
                    ? 'Not available'
                    : _formatDateTime(donation.acceptedAt!),
              ),
              if (donation.completedAt != null)
                _row('Picked up at', _formatDateTime(donation.completedAt!)),
              const SizedBox(height: 10),
              const Divider(),
              const Text(
                'Donation Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('Pictures', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              if (donation.imageUrls.isEmpty)
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No images uploaded'),
                )
              else
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: donation.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) =>
                        _PhotoTile(donation.imageUrls[index]),
                  ),
                ),
              const SizedBox(height: 18),
              _row(
                'Food',
                donation.foodItems.isEmpty
                    ? 'Not provided'
                    : donation.foodItems.join(', '),
              ),
              _row('Servings', donation.quantity),
              if ((donation.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(donation.description!),
              ],
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
            child: Text(label, style: const TextStyle(color: Colors.black87)),
          ),
          const Text(':  '),
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

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        path,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 90,
          height: 90,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        ),
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
