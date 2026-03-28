import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final DonationService _donationService = DonationService();
  bool _isAccepting = false;
  late Future<DonationModel> _donationFuture;

  @override
  void initState() {
    super.initState();
    _donationFuture = _donationService.getDonationById(widget.donation.donationId);
  }

  Future<void> _acceptDonation(DonationModel donation) async {
    final ngo = SessionService.user;
    if (ngo == null || !ngo.isNgo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in as an NGO first.')),
      );
      return;
    }

    setState(() => _isAccepting = true);
    try {
      await _donationService.acceptDonation(
        donationId: donation.donationId,
        ngo: ngo,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation accepted successfully.')),
      );
      Navigator.pop(context, true);
    } on DonationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<DonationModel>(
        future: _donationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _donationFuture = _donationService.getDonationById(
                      widget.donation.donationId,
                    );
                  });
                },
                child: const Text('Retry'),
              ),
            );
          }

          final donation = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pictures',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: donation.imageUrls.isEmpty
                        ? _photoPlaceholder()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: donation.imageUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) => _photo(
                              donation.imageUrls[index],
                            ),
                          ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    donation.foodItems.join(', '),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    donation.description ?? 'No description provided.',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _info('Donor', donation.donorName),
                  _info('Email', donation.donorEmail),
                  _info('Phone', donation.donorPhone ?? 'Not provided'),
                  _info('Status', donation.status.toUpperCase()),
                  _info('Servings', donation.quantity),
                  _info('Pickup Location', donation.location ?? 'Not provided'),
                  _info('Uploaded', _formatDateTime(donation.createdAt)),
                  if (donation.expiryAt != null)
                    _info('Expiry', _formatDateTime(donation.expiryAt!)),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C45),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: donation.isAccepted ||
                                !donation.isActive ||
                                _isAccepting
                            ? null
                            : () => _acceptDonation(donation),
                        child: _isAccepting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                donation.isAccepted
                                    ? 'Already Accepted'
                                    : 'Accept Donation',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _photo(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        path,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 90,
          height: 90,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Row(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(right: 12),
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.grey.shade300,
          ),
          child: const Icon(Icons.image_not_supported),
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
