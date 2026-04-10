import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/home/screens/expired_donation_detail_screen.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class ExpiredDonationsScreen extends StatelessWidget {
  const ExpiredDonationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    final donor = SessionService.user;
    final service = DonationService();
    debugPrint(
      '[ExpiredDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Expired Donations',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: donor == null
          ? const Center(child: Text('Please log in to view donations.'))
          : FutureBuilder<List<DonationModel>>(
              future: service.getDonorDonations(
                donorId: donor.uid,
                status: DonationStatus.expired,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint(
                    '[ExpiredDonationsScreen] load error for uid=${donor.uid}: ${snapshot.error}',
                  );
                  return Center(
                    child: Text(
                      'Unable to load expired donations.\n${snapshot.error}',
                    ),
                  );
                }

                final donations = snapshot.data ?? const <DonationModel>[];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'These donations expired before collection. Please try to donate earlier next time.',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (donations.isEmpty)
                      const Center(child: Text('No expired donations found.'))
                    else
                      ...donations.map(
                        (d) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExpiredDonationDetailScreen(donation: d),
                              ),
                            );
                          },
                          child: _ExpiredCard(d),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: mainGreen),
                              SizedBox(width: 6),
                              Text(
                                'Waste of Food',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Every expired donation means lost meals for people in need. Help us reduce waste by scheduling donations earlier and coordinating with NGOs.',
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
}

class _ExpiredCard extends StatelessWidget {
  const _ExpiredCard(this.donation);

  final DonationModel donation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.warning_amber_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  donation.acceptedByNgoName ?? 'Not accepted',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Food: ${donation.foodItems.join(', ')}'),
          Text('Quantity: ${donation.quantity}'),
          const SizedBox(height: 6),
          Text(
            'Donated On: ${_formatDate(donation.createdAt)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
