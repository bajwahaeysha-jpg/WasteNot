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

  Future<List<DonationModel>> _loadDonations() async {
    final data =
        await _donationService.getAllDonations(status: _selectedFilter);

    /// 🔥 IMPORTANT FILTER FIX
    return data.where((item) {
      // ✅ ACTIVE = accepted but NOT completed
      if (_selectedFilter == DonationStatus.accepted) {
        return item.isCompleted != true;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
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

                final donations = snapshot.data ?? [];

                if (donations.isEmpty) {
                  return const Center(child: Text('No donations found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donations.length,
                  itemBuilder: (_, i) =>
                      _donationCard(context, donations[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 FILTER BAR
  Widget _statusFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', null),
            const SizedBox(width: 10),

            /// ✅ ACTIVE FIXED
            _filterChip('Active', DonationStatus.accepted),

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B4B3F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0B4B3F)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0B4B3F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _donationCard(BuildContext context, DonationModel donation) {
    final status = donation.status;
    final statusColor = _statusColor(status);

    final imageUrl =
        (donation.imageUrls != null && donation.imageUrls!.isNotEmpty)
            ? donation.imageUrls!.first
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
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
          if (mounted) setState(() {});
        },
        child: Row(
          children: [
            /// 🍲 IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),

            const SizedBox(width: 12),

            /// 📝 TEXT + STATUS ROW
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.foodItems.join(', '),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation.donorName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// 🔥 SERVINGS LEFT + STATUS RIGHT
                  Row(
                    children: [
                      Text(
                        "Servings: ${donation.quantity}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'accepted':
        return Colors.orange; // active look
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}