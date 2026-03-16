import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';

const Color mainGreen = Color(0xFF0E5E53);

class DonationDetailScreen extends StatefulWidget {
  const DonationDetailScreen({
    super.key,
    required this.donation,
    required this.onStatusChanged,
  });

  final DonationModel donation;
  final VoidCallback onStatusChanged;

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  final DonationService _donationService = DonationService();
  late Future<DonationModel> _donationFuture;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _donationFuture = _loadDonation();
  }

  Future<DonationModel> _loadDonation() {
    return _donationService.getDonationById(widget.donation.donationId);
  }

  Future<void> _markCompleted(DonationModel donation) async {
    if (_isCompleting) {
      return;
    }

    setState(() => _isCompleting = true);

    try {
      await _donationService.markDonationCompleted(
        donationId: donation.donationId,
      );
      if (!mounted) {
        return;
      }
      widget.onStatusChanged();
      setState(() {
        _donationFuture = _loadDonation();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation marked as completed.')),
      );
    } on DonationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

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
      body: FutureBuilder<DonationModel>(
        future: _donationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: ElevatedButton(
                onPressed: () => setState(() => _donationFuture = _loadDonation()),
                child: const Text('Retry'),
              ),
            );
          }

          final donation = snapshot.data!;
          final canComplete = donation.isActive && donation.isAccepted;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _statusChip(donation.status),
                      ),
                      _info('Donor', donation.donorName),
                      _info(
                        'Accepted by',
                        donation.acceptedByNgoName ?? 'Not accepted yet',
                      ),
                      _info('Location', donation.location ?? 'Not provided'),
                      const Divider(height: 30),
                      _info('Uploaded at', _formatDateTime(donation.createdAt)),
                      _info(
                        'Accepted at',
                        donation.acceptedAt == null
                            ? 'Not accepted yet'
                            : _formatDateTime(donation.acceptedAt!),
                      ),
                      if (donation.completedAt != null)
                        _info(
                          'Completed at',
                          _formatDateTime(donation.completedAt!),
                        ),
                      if (donation.expiryAt != null)
                        _info(
                          'Expiry date',
                          _formatDateTime(donation.expiryAt!),
                        ),
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
                      if ((donation.description ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(donation.description!),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pictures',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _ImageGallery(imageUrls: donation.imageUrls),
                    ],
                  ),
                ),
              ),
              if (canComplete)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        _isCompleting ? null : () => _markCompleted(donation),
                    child: _isCompleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Mark as Completed',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.blueGrey;
      case 'expired':
        return Colors.redAccent;
      default:
        return mainGreen;
    }
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No images uploaded'),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 120,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
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
