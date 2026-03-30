import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/donations/expire_reason_screen.dart';
import 'package:wastenot/shared/widgets/location_map_preview.dart';
import 'package:wastenot/services/donation_services.dart';

class DonationProfileScreen extends StatefulWidget {
  const DonationProfileScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationProfileScreen> createState() => _DonationProfileScreenState();
}

class _DonationProfileScreenState extends State<DonationProfileScreen> {
  final DonationService _donationService = DonationService();
  late Future<DonationModel> _donationFuture;

  @override
  void initState() {
    super.initState();
    _donationFuture = _donationService.getDonationById(widget.donation.donationId);
  }

  Future<void> _expireDonation(DonationModel donation) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ExpireReasonScreen(donation: donation),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _donationFuture = _donationService.getDonationById(donation.donationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        title: const Text(
          'Donation Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DonationModel>(
        future: _donationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _donationFuture = _donationService.getDonationById(
                    widget.donation.donationId,
                  );
                }),
                child: const Text('Retry'),
              ),
            );
          }

          final d = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _row('Donor name', d.donorName),
              _row('Donor email', d.donorEmail),
              _row('Donor phone', d.donorPhone ?? 'Not provided'),
              _row('Donor address', d.donorAddress ?? 'Not provided'),
              _row('Location', d.locationAddress ?? d.donorAddress ?? 'Unknown'),
              const SizedBox(height: 12),
              LocationMapPreview(location: d.location, height: 160),
              const Divider(height: 32),
              _row('Created at', _formatDateTime(d.createdAt)),
              _row(
                'Expiry date',
                d.expiryAt == null ? 'Not available' : _formatDateTime(d.expiryAt!),
              ),
              _row(
                'Accepted at',
                d.acceptedAt == null
                    ? 'Not accepted yet'
                    : _formatDateTime(d.acceptedAt!),
              ),
              _row(
                'Completed at',
                d.completedAt == null
                    ? 'Not completed yet'
                    : _formatDateTime(d.completedAt!),
              ),
              const Divider(height: 32),
              const Text(
                'Donation Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _row(
                'Food',
                d.foodItems.isEmpty ? 'Not provided' : d.foodItems.join(', '),
              ),
              _row('Servings', d.quantity),
              _row('Status', d.status.toUpperCase()),
              _row('Details', d.description ?? 'No description provided'),
              const SizedBox(height: 24),
              const Text(
                'Accepted NGO Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _row('NGO name', d.acceptedByNgoName ?? 'Not accepted yet'),
              _row('NGO email', d.acceptedByNgoEmail ?? 'Not available'),
              _row('NGO phone', d.acceptedByNgoPhone ?? 'Not available'),
              _row('NGO address', d.acceptedByNgoAddress ?? 'Not available'),
              const SizedBox(height: 24),
              const Text(
                'Pictures',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _images(d.imageUrls),
              const SizedBox(height: 20),
              if (d.isActive)
                GestureDetector(
                  onTap: () => _expireDonation(d),
                  child: const Text(
                    'Mark as Expired',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _images(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No images uploaded'),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrls[index],
            width: 140,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 140,
              height: 120,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image),
            ),
          ),
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
