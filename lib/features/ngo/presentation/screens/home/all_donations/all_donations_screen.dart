import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/all_donations/donation_details_screen.dart';
import 'package:wastenot/services/donation_services.dart';

class AllDonationsScreen extends StatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  State<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {
  final DonationService _donationService = DonationService();

  Future<List<DonationModel>> _loadDonations() {
    return _donationService.getAvailableDonationsForNgo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          'Available Donations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<DonationModel>>(
        future: _loadDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Retry'),
              ),
            );
          }

          final donations = snapshot.data ?? const <DonationModel>[];

          if (donations.isEmpty) {
            return const Center(child: Text('No donations found.'));
          }

          return DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 0, 6),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationDetailsScreen(
                                donation: donation,
                              ),
                            ),
                          );
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _DonationImage(
                                imageUrl: donation.imageUrls.isEmpty
                                    ? null
                                    : donation.imageUrls.first,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _timeOnly(donation.createdAt),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Text(
                                      donation.foodItems.join(', '),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.store,
                                          size: 14,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            donation.donorName,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            donation.location ?? 'No location',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          'View details',
                                          style: TextStyle(
                                            color: Colors.teal,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.info_outline,
                                          size: 14,
                                          color: Colors.teal,
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DonationImage extends StatelessWidget {
  const _DonationImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 85,
      height: 85,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl == null || imageUrl!.isEmpty
          ? placeholder
          : Image.network(
              imageUrl!,
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

String _timeOnly(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute $suffix';
}