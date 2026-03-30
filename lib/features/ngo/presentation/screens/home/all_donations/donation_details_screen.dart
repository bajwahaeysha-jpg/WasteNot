import 'package:flutter/material.dart';
import 'package:wastenot/services/location_estimate_service.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/shared/widgets/location_map_preview.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final DonationService _donationService = DonationService();
  final LocationEstimateService _locationEstimateService =
      const LocationEstimateService();
  bool _isAccepting = false;
  late Future<DonationModel> _donationFuture;

  @override
  void initState() {
    super.initState();
    _donationFuture = _donationService.getDonationById(widget.donation.donationId);
  }

  Future<void> _accept(DonationModel donation) async {
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

  Future<void> _reject(DonationModel donation) async {
    final ngo = SessionService.user;
    if (ngo == null || !ngo.isNgo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in as an NGO first.')),
      );
      return;
    }

    try {
      await _donationService.rejectDonation(
        donationId: donation.donationId,
        ngo: ngo,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation rejected successfully.')),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
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
          final ngoLocation = SessionService.user?.location;
          final estimate = _locationEstimateService.estimate(
            from: ngoLocation,
            to: donation.location,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pictures',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (donation.imageUrls.isEmpty)
                        Row(
                          children: List.generate(
                            3,
                            (_) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _imageBox(null),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: donation.imageUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) => _imageBox(
                              donation.imageUrls[index],
                            ),
                          ),
                        ),
                      const SizedBox(height: 26),
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LocationMapPreview(
                        location: donation.location,
                        secondaryLocation: ngoLocation,
                        height: 180,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donation.locationAddress ?? 'Location not set',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _detailRow(
                        'Distance',
                        estimate == null
                            ? 'Distance unavailable'
                            : '${estimate.distanceKm.toStringAsFixed(1)} km away',
                      ),
                      const SizedBox(height: 12),
                      _detailRow(
                        'Time',
                        estimate == null
                            ? 'Distance unavailable'
                            : 'Approx ${estimate.estimatedMinutes} mins',
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          children: [
                            _detailRow('Donor', donation.donorName),
                            const SizedBox(height: 12),
                            _detailRow('Email', donation.donorEmail),
                            const SizedBox(height: 12),
                            _detailRow('Servings', donation.quantity),
                            const SizedBox(height: 12),
                            _detailRow(
                              'Phone',
                              donation.donorPhone ?? 'Not provided',
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                              'Uploaded',
                              _formatDateTime(donation.createdAt),
                            ),
                            const SizedBox(height: 16),
                            _descriptionSection(
                              donation.description ?? 'No description provided.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: donation.isAccepted || !donation.isActive
                            ? null
                            : () => _reject(donation),
                        child: const Text(
                          'Return',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C45),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: donation.isAccepted || !donation.isActive || _isAccepting
                            ? null
                            : () => _accept(donation),
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
                                donation.isAccepted ? 'Accepted' : 'Accept',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _imageBox(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: imageUrl == null
          ? Container(
              width: 90,
              height: 90,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported),
            )
          : Image.network(
              imageUrl,
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

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14.5, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _descriptionSection(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} $hour:$minute $suffix';
}
