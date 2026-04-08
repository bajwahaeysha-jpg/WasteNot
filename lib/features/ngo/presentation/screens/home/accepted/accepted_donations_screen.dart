import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/accepted/accepted_donation_detail_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class AcceptedDonationsScreen extends StatefulWidget {
  const AcceptedDonationsScreen({super.key});

  @override
  State<AcceptedDonationsScreen> createState() =>
      _AcceptedDonationsScreenState();
}

class _AcceptedDonationsScreenState extends State<AcceptedDonationsScreen> {
  final DonationService _donationService = DonationService();
  final TextEditingController controller = TextEditingController();
  bool isSearching = false;
  String _query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _clear() {
    controller.clear();
    setState(() {
      _query = '';
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        titleSpacing: 0,
        title: isSearching
            ? TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search donor / food',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clear,
                  ),
                ),
              )
            : const Text(
                'Accepted Donations',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => isSearching = true),
            ),
        ],
      ),
      body: ValueListenableBuilder<AppUserModel?>(
        valueListenable: SessionService.currentUser,
        builder: (context, user, _) {
          final uid = user?.uid;
          final stream = uid == null
              ? Stream<List<DonationModel>>.value(const <DonationModel>[])
              : _donationService.streamDonationsByStatus(
                  status: DonationStatus.completed,
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
                  '[NgoAcceptedDonationsScreen] load error for uid=${user?.uid}: ${snapshot.error}',
                );
                return Center(
                  child: Text('Unable to load donations.\n${snapshot.error}'),
                );
              }

              final filtered = (snapshot.data ?? const <DonationModel>[])
                  .where((d) {
                    if (_query.isEmpty) {
                      return true;
                    }
                    final query = _query.toLowerCase();
                    return d.donorName.toLowerCase().contains(query) ||
                        d.foodItems.join(', ').toLowerCase().contains(query);
                  })
                  .toList()
                ..sort((a, b) {
                  final aTime = a.completedAt ?? a.createdAt;
                  final bTime = b.completedAt ?? b.createdAt;
                  return bTime.compareTo(aTime);
                });

              final Map<String, List<DonationModel>> grouped = {};
              for (final donation in filtered) {
                grouped
                    .putIfAbsent(
                      _groupLabel(donation.completedAt ?? donation.createdAt),
                      () => [],
                    )
                    .add(donation);
              }

              if (filtered.isEmpty) {
                return const Center(child: Text('No accepted donations found.'));
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: grouped.entries.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          group.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ...group.value.map(
                        (d) => InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AcceptedDonationDetailScreen(donation: d),
                              ),
                            );
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.fastfood),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.foodItems.join(', '),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        d.donorName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _timeOnly(d.completedAt ?? d.createdAt),
                                  style: const TextStyle(
                                    color: Color(0xFF0F4C45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          );
        },
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
