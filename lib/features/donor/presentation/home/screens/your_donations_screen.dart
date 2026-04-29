import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/home/screens/donation_detail_screen.dart';
import 'package:wastenot/models/repository_state.dart';
import 'package:wastenot/repositories/donation_repository.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class YourDonationsScreen extends StatefulWidget {
  const YourDonationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  State<YourDonationsScreen> createState() => _YourDonationsScreenState();
}

class _YourDonationsScreenState extends State<YourDonationsScreen> {
  final DonationRepository _donationRepository = DonationRepository();
  DonationStatus? _selectedFilter;

  Stream<RepositoryState<List<DonationModel>>> _watchAllDonations() {
    final donor = SessionService.user;
    debugPrint(
      '[YourDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role} all-donations',
    );

    if (donor == null) {
      return Stream<RepositoryState<List<DonationModel>>>.value(
        const RepositoryState<List<DonationModel>>(
          data: <DonationModel>[],
          isLoading: false,
        ),
      );
    }

    return _donationRepository.watchDonorDonations(
      donorId: donor.uid,
      status: null,
    );
  }

  Stream<RepositoryState<List<DonationModel>>> _watchFilteredDonations() {
    final donor = SessionService.user;
    debugPrint(
      '[YourDonationsScreen] current donor uid=${donor?.uid} role=${donor?.role} filter=${_selectedFilter?.value ?? 'all'}',
    );

    if (donor == null) {
      return Stream<RepositoryState<List<DonationModel>>>.value(
        const RepositoryState<List<DonationModel>>(
          data: <DonationModel>[],
          isLoading: false,
        ),
      );
    }

    return _donationRepository.watchDonorDonations(
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
      body: StreamBuilder<RepositoryState<List<DonationModel>>>(
        stream: _watchAllDonations(),
        initialData: const RepositoryState<List<DonationModel>>(
          data: <DonationModel>[],
          isLoading: true,
        ),
        builder: (context, allSnapshot) {
          final allState = allSnapshot.data ??
              const RepositoryState<List<DonationModel>>(
                data: <DonationModel>[],
                isLoading: true,
              );
          final allDonations = allState.data
              .where((donation) =>
                  donation.status == DonationStatus.active.value ||
                  donation.status == DonationStatus.completed.value)
              .toList();
          final totalCount = allDonations.length;
          final activeCount = allDonations.where((e) => e.isActive).length;
          final completedCount = allDonations.where((e) => e.isCompleted).length;

          return StreamBuilder<RepositoryState<List<DonationModel>>>(
            stream: _watchFilteredDonations(),
            initialData: RepositoryState<List<DonationModel>>(
              data: allDonations,
              isLoading: true,
              isFromCache: allState.isFromCache,
              errorMessage: allState.errorMessage,
            ),
            builder: (context, filteredSnapshot) {
              final state = filteredSnapshot.data ??
                  const RepositoryState<List<DonationModel>>(
                    data: <DonationModel>[],
                    isLoading: true,
                  );
              final donations = state.data.where((donation) {
                if (_selectedFilter == null) {
                  return donation.status == DonationStatus.active.value ||
                      donation.status == DonationStatus.completed.value;
                }
                return donation.status == _selectedFilter!.value;
              }).toList();

              if (state.isLoading && donations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
                  if (state.hasError && donations.isNotEmpty)
                    _InlineInfoBanner(message: state.errorMessage!),
                  Expanded(
                    child: ListView(
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
                              isSelected:
                                  _selectedFilter == DonationStatus.completed,
                              onTap: () => setState(
                                () => _selectedFilter = DonationStatus.completed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state.isFromCache && donations.isNotEmpty)
                          const _InlineInfoBanner(
                            message: 'Showing cached donations while syncing.',
                          ),
                        if (donations.isEmpty)
                          _EmptyState(
                            message: state.hasError
                                ? state.errorMessage!
                                : 'No donations found.',
                          )
                        else
                          ...donations.map(
                            (donation) => DonationCard(
                              donation: donation,
                              onUpdated: () => setState(() {}),
                            ),
                          ),
                      ],
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

class _InlineInfoBanner extends StatelessWidget {
  const _InlineInfoBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF0B4B3F),
          fontSize: 13,
        ),
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
                CircleAvatar(
  backgroundColor: Colors.grey.shade200,
  backgroundImage: donation.acceptedByNgoProfileImageUrl != null &&
          donation.acceptedByNgoProfileImageUrl!.isNotEmpty
      ? NetworkImage(donation.acceptedByNgoProfileImageUrl!)
      : null,
  child: donation.acceptedByNgoProfileImageUrl == null ||
          donation.acceptedByNgoProfileImageUrl!.isEmpty
      ? const Icon(Icons.groups)
      : null,
),
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
