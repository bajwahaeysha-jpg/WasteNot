import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/home/screens/accepted_donation_detail_screen.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

const Color mainGreen = Color(0xFF0B4B3F);

class AcceptedDonationsScreen extends StatefulWidget {
  const AcceptedDonationsScreen({super.key});

  @override
  State<AcceptedDonationsScreen> createState() => _AcceptedDonationsScreenState();
}

class _AcceptedDonationsScreenState extends State<AcceptedDonationsScreen> {
  final DonationService _service = DonationService();
  Future<List<DonationModel>>? _donationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDonations();
  }

  void _refreshDonations() {
    final donor = SessionService.user;
    if (donor == null) {
      _donationsFuture = Future<List<DonationModel>>.value(const <DonationModel>[]);
      return;
    }

    _donationsFuture = _service.getDonorDonations(donorId: donor.uid);
  }

  Future<void> _markNotCompleted(DonationModel donation) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _service.markDonationNotCompleted(donationId: donation.donationId);
      if (!mounted) {
        return;
      }

      setState(_refreshDonations);
      messenger.showSnackBar(
        const SnackBar(content: Text('Donation marked as not completed.')),
      );
    } on DonationException catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final donor = SessionService.user;
    debugPrint(
      '[DonorAcceptedDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          'Accepted Donations',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: donor == null
          ? const Center(child: Text('Please log in to view donations.'))
          : FutureBuilder<List<DonationModel>>(
              future: _donationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint(
                    '[DonorAcceptedDonationsScreen] load error for uid=${donor.uid}: ${snapshot.error}',
                  );
                  return Center(
                    child: Text(
                      'Unable to load accepted donations.\n${snapshot.error}',
                    ),
                  );
                }

                final donations = (snapshot.data ?? const <DonationModel>[])
                    .where((d) => d.isAwaitingClosure)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (donations.isEmpty) {
                  return const Center(
                    child: Text('No accepted donations found.'),
                  );
                }

                String lastDate = '';

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    final date = _groupLabel(donation.createdAt);
                    final showHeader = date != lastDate;
                    lastDate = date;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AcceptedDonationDetailScreen(donation: donation),
                              ),
                            );
                            if (changed == true && mounted) {
                              setState(_refreshDonations);
                            }
                          },
                          child: _donationCard(
                            donation,
                            onNotCompleted: () => _markNotCompleted(donation),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _donationCard(
    DonationModel donation, {
    required VoidCallback onNotCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
  height: 60,
  width: 60,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12), // square rounded (NOT circle)
    color: Colors.grey.shade200,
    image: donation.imageUrls.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(donation.imageUrls.first),
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: donation.imageUrls.isEmpty
      ? const Icon(Icons.fastfood)
      : null,
),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.foodItems.join(', '),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      donation.acceptedByNgoName ?? 'Accepted NGO',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                _timeOnly(donation.acceptedAt ?? donation.createdAt),
                style: const TextStyle(
                  color: mainGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
        ],
      ),
    );
  }
}

String _groupLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(d.year, d.month, d.day);
  if (date == today) {
    return 'Today';
  }
  if (date == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }
  return '${d.day}/${d.month}/${d.year}';
}

String _timeOnly(DateTime value) {
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute $suffix';
}
