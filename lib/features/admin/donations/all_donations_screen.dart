import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/donations/donation_profile_screen.dart';
import 'package:wastenot/services/donation_services.dart';

class AllDonationsScreen extends StatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  State<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {
  final DonationService _donationService = DonationService();
  DonationStatus? _selectedFilter;

  Future<List<DonationModel>> _loadDonations() {
    return _donationService.getAllDonations(status: _selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        title: const Text(
          'All Donations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _statusFilterBar(),
          Expanded(
            child: FutureBuilder<List<DonationModel>>(
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

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  itemCount: donations.length,
                  itemBuilder: (_, i) => _donationCard(context, donations[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', null),
            const SizedBox(width: 10),
            _filterChip('Active', DonationStatus.active),
            const SizedBox(width: 10),
            _filterChip('Expired', DonationStatus.expired),
            const SizedBox(width: 10),
            _filterChip('Completed', DonationStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, DonationStatus? status) {
    final selected = _selectedFilter == status;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F4C45) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF0F4C45)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF0F4C45),
          ),
        ),
      ),
    );
  }

  Widget _donationCard(BuildContext context, DonationModel donation) {
    final status = donation.status;
    final statusColor = _statusColor(status);
    final statusBg = statusColor.withValues(alpha: .12);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationProfileScreen(donation: donation),
            ),
          );
          if (mounted) {
            setState(() {});
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${donation.donorName} -> ${donation.acceptedByNgoName ?? 'Unassigned'}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '${donation.foodItems.join(', ')} • ${donation.quantity}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(donation.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade700;
      case 'active':
        return Colors.orange.shade700;
      default:
        return Colors.red.shade700;
    }
  }
}

String _formatDate(DateTime value) {
  return '${value.day}/${value.month}/${value.year}';
}
