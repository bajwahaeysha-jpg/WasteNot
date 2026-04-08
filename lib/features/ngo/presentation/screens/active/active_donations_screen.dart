import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/active/donation_details_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class ActiveDonationsScreen extends StatefulWidget {
  const ActiveDonationsScreen({super.key});

  @override
  State<ActiveDonationsScreen> createState() => _ActiveDonationsScreenState();
}

class _ActiveDonationsScreenState extends State<ActiveDonationsScreen> {
  final DonationService _donationService = DonationService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        final uid = user?.uid;
        final stream = uid == null
            ? Stream<List<DonationModel>>.value(const <DonationModel>[])
            : _donationService.streamDonationsByStatus(
                status: DonationStatus.accepted,
                ngoId: uid,
                orderByCreatedAt: false,
              );

        return StreamBuilder<List<DonationModel>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint(
                '[NgoActiveDonationsScreen] load error: ${snapshot.error}',
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Unable to load donations.\n${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final donations = List<DonationModel>.from(
              snapshot.data ?? const <DonationModel>[],
            )..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            if (donations.isEmpty) {
              return const Center(child: Text('No active donations available.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DonationDetailsScreen(donation: donation),
                      ),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _DonationThumbnail(
                          imageUrl: donation.imageUrls.isEmpty
                              ? null
                              : donation.imageUrls.first,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donation.donorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                donation.foodItems.join(', '),
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                donation.status.toUpperCase(),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DonationThumbnail extends StatelessWidget {
  const _DonationThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl == null || imageUrl!.isEmpty
        ? Container(
            width: 70,
            height: 70,
            color: Colors.grey.shade200,
            child: const Icon(Icons.fastfood),
          )
        : Image.network(
            imageUrl!,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }
}
