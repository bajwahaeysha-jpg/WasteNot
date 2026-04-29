import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/ngos/services/admin_ngo_management_service.dart';

import 'ngo_profile_screen.dart';

class AllNGOsScreen extends StatefulWidget {
  const AllNGOsScreen({super.key});

  @override
  State<AllNGOsScreen> createState() => _AllNGOsScreenState();
}

class _AllNGOsScreenState extends State<AllNGOsScreen> {
  String selectedStatus = "All";
  final _service = AdminNgoManagementService();

  NgoStatusFilter get _selectedFilter {
    switch (selectedStatus) {
      case 'Active':
        return NgoStatusFilter.active;
      case 'Suspended':
        return NgoStatusFilter.suspended;
      case 'Deleted':
        return NgoStatusFilter.deleted;
      default:
        return NgoStatusFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        elevation: 0,
        title: const Text(
          "All NGOs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: StreamBuilder<List<AdminManagedNgo>>(
              stream: _service.streamNgos(filter: _selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Unable to load NGOs"),
                  );
                }

                final ngos = snapshot.data ?? const <AdminManagedNgo>[];
                if (ngos.isEmpty) {
                  return const Center(
                    child: Text("No NGOs found"),
                  );
                }

                return ListView.builder(
                  itemCount: ngos.length,
                  itemBuilder: (_, i) => _ngoCard(ngos[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 10,
          children: [
            _statusChip("All"),
            _statusChip("Active"),
            _statusChip("Suspended"),
            _statusChip("Deleted"),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final bool selected = selectedStatus == status;

    return GestureDetector(
      onTap: () => setState(() => selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B4B3F) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF0B4B3F)),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF0B4B3F),
          ),
        ),
      ),
    );
  }

  Widget _ngoCard(AdminManagedNgo ngo) {
    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NGOProfileScreen(ngoId: ngo.id)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B4B3F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ngo.imageUrl.isNotEmpty
                    ? Image.network(
                        ngo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.apartment,
                          color: Color(0xFF0B4B3F),
                        ),
                      )
                    : const Icon(
                        Icons.apartment,
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
                    ngo.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ngo.locationLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Meals: ${ngo.totalMealsReceived} | Success: ${ngo.successRate}%",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            NgoStatusBadge(ngo: ngo),
          ],
        ),
      ),
    );
  }
}

class NgoStatusBadge extends StatelessWidget {
  const NgoStatusBadge({
    super.key,
    required this.ngo,
  });

  final AdminManagedNgo ngo;

  @override
  Widget build(BuildContext context) {
    final bool isDeleted = ngo.user.normalizedStatus == 'deleted' || ngo.isDeleted;
    final bool isSuspended = !isDeleted && ngo.isSuspended;
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
