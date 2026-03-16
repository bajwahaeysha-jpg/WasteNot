import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/home/screens/donation_detail_screen.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class YourDonationsScreen extends StatefulWidget {
  const YourDonationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<YourDonationsScreen> createState() => _YourDonationsScreenState();
}

class _YourDonationsScreenState extends State<YourDonationsScreen> {
  final DonationService _donationService = DonationService();
  DonationStatus? _selectedFilter;

  Future<List<DonationModel>> _loadAllDonations() {
    final donor = SessionService.user;
    debugPrint(
      '[YourDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role} all-donations',
    );

    if (donor == null) {
      return Future<List<DonationModel>>.value(const <DonationModel>[]);
    }

    return _donationService.getDonorDonations(
      donorId: donor.uid,
      status: null,
    );
  }

  Future<List<DonationModel>> _loadFilteredDonations() {
    final donor = SessionService.user;
    debugPrint(
      '[YourDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role} filter=${_selectedFilter?.value ?? 'all'}',
    );

    if (donor == null) {
      return Future<List<DonationModel>>.value(const <DonationModel>[]);
    }

    return _donationService.getDonorDonations(
      donorId: donor.uid,
      status: _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: YourDonationsScreen.mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Your Donations',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<DonationModel>>(
        future: _loadAllDonations(),
        builder: (context, allSnapshot) {
          if (allSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (allSnapshot.hasError) {
            debugPrint(
              '[YourDonationsScreen] load error for uid=${SessionService.user?.uid}: ${allSnapshot.error}',
            );
            return _ErrorState(
              message: 'Unable to load donations.\n${allSnapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final allDonations = allSnapshot.data ?? const <DonationModel>[];
          final totalCount = allDonations.length;
          final activeCount = allDonations.where((e) => e.isActive).length;
          final completedCount = allDonations.where((e) => e.isCompleted).length;

          return FutureBuilder<List<DonationModel>>(
            future: _loadFilteredDonations(),
            builder: (context, filteredSnapshot) {
              if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredSnapshot.hasError) {
                debugPrint(
                  '[YourDonationsScreen] filtered load error for uid=${SessionService.user?.uid}: ${filteredSnapshot.error}',
                );
                return _ErrorState(
                  message: 'Unable to load donations.\n${filteredSnapshot.error}',
                  onRetry: () => setState(() {}),
                );
              }

              final donations = filteredSnapshot.data ?? const <DonationModel>[];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _StatCard(
                        title: 'Total',
                        value: totalCount,
                        icon: Icons.volunteer_activism,
                        color: Colors.blueGrey,
                        isSelected: _selectedFilter == null,
                        onTap: () => setState(() => _selectedFilter = null),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        title: 'Active',
                        value: activeCount,
                        icon: Icons.autorenew,
                        color: YourDonationsScreen.mainGreen,
                        isSelected: _selectedFilter == DonationStatus.active,
                        onTap: () => setState(
                          () => _selectedFilter = DonationStatus.active,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        title: 'Completed',
                        value: completedCount,
                        icon: Icons.check_circle,
                        color: Colors.teal,
                        isSelected: _selectedFilter == DonationStatus.completed,
                        onTap: () => setState(
                          () => _selectedFilter = DonationStatus.completed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (donations.isEmpty)
                    const _EmptyState(
                      message: 'No donations found.',
                    )
                  else
                    ...donations.map(
                      (donation) => DonationCard(
                        donation: donation,
                        onUpdated: () => setState(() {}),
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? color.withValues(alpha: 0.12) : Colors.white;
    final borderColor = isSelected ? color : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  const DonationCard({
    super.key,
    required this.donation,
    required this.onUpdated,
  });

  final DonationModel donation;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final isActive = donation.isActive;
    final title = donation.foodItems.isEmpty
        ? 'Donation'
        : donation.foodItems.join(', ');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationDetailScreen(
              donation: donation,
              onStatusChanged: onUpdated,
            ),
          ),
        );
        onUpdated();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.groups)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    donation.acceptedByNgoName ?? donation.donorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(donation.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donation.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Food: $title'),
            Text('Quantity: ${donation.quantity}'),
            const SizedBox(height: 6),
            Text(
              'Donated On: ${_formatDate(donation.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (isActive && donation.acceptedByNgoName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Accepted by: ${donation.acceptedByNgoName}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
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
        return YourDonationsScreen.mainGreen;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);

  if (target == today) {
    return 'Today';
  }
  if (target == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }
  return '${date.day}/${date.month}/${date.year}';
}