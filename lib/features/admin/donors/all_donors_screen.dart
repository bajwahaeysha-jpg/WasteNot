import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/donors/services/admin_donor_management_service.dart';

import 'donor_profile_screen.dart';

class AllDonorsScreen extends StatefulWidget {
  const AllDonorsScreen({super.key});

  @override
  State<AllDonorsScreen> createState() => _AllDonorsScreenState();
}

class _AllDonorsScreenState extends State<AllDonorsScreen> {
  String selectedStatus = "All";
  final _service = AdminDonorManagementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        elevation: 0,
        title: const Text(
          "All Donors",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          statusFilterBar(
            selectedStatus: selectedStatus,
            filters: const ["All", "Active", "Suspended", "Deleted"],
            onChanged: (value) {
              setState(() => selectedStatus = value);
            },
          ),
          Expanded(
            child: StreamBuilder<List<AdminManagedDonor>>(
              stream: _service.streamDonors(filter: _selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Unable to load donors"),
                  );
                }

                final donors = snapshot.data ?? const <AdminManagedDonor>[];
                if (donors.isEmpty) {
                  return const Center(
                    child: Text("No donors found"),
                  );
                }

                return ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (_, i) => donorCard(donors[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DonorStatusFilter get _selectedFilter {
    switch (selectedStatus) {
      case 'Active':
        return DonorStatusFilter.active;
      case 'Suspended':
        return DonorStatusFilter.suspended;
      case 'Deleted':
        return DonorStatusFilter.deleted;
      default:
        return DonorStatusFilter.all;
    }
  }

  Widget donorCard(AdminManagedDonor donor) {
    final donorType = donor.donorType;
    final infoLine = <String>[
      if (donorType != null && donorType.isNotEmpty) donorType,
      donor.locationLabel,
    ].join(" â€¢ ");

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonorProfileScreen(donorId: donor.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0B4B3F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: donor.imageUrl.isNotEmpty
                    ? Image.network(
                        donor.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Color(0xFF0B4B3F),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF0B4B3F),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    infoLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Meals: ${donor.totalMealsDonated} â€¢ Rating: ${donor.averageRating.toStringAsFixed(1)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            DonorStatusBadge(donor: donor),
          ],
        ),
      ),
    );
  }
}

class DonorStatusBadge extends StatelessWidget {
  const DonorStatusBadge({
    super.key,
    required this.donor,
  });

  final AdminManagedDonor donor;

  @override
  Widget build(BuildContext context) {
    final bool isDeleted =
        donor.user.normalizedStatus == 'deleted' || donor.isDeleted;
    final bool isSuspended = !isDeleted && donor.isSuspended;
    final Color backgroundColor = isDeleted
        ? const Color(0xFFFDE8E8)
        : (isSuspended ? Colors.red.shade100 : const Color(0x1A0B4B3F));
    final Color foregroundColor = isDeleted
        ? Colors.red
        : (isSuspended ? Colors.red.shade700 : const Color(0xFF0B4B3F));
    final IconData icon = isDeleted
        ? Icons.flag
        : (isSuspended ? Icons.block : Icons.check_circle);
    final String label = isDeleted
        ? 'Deleted'
        : (isSuspended ? 'Suspended' : 'Active');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

Widget statusFilterBar({
  required String selectedStatus,
  required List<String> filters,
  required ValueChanged<String> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        children: filters.map((status) {
          final selected = selectedStatus == status;

          return GestureDetector(
            onTap: () => onChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0B4B3F) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF0B4B3F),
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? Colors.white : const Color(0xFF0B4B3F),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
