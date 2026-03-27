import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/features/goal/models/goal_model.dart';
import 'package:wastenot/features/goal/services/goal_service.dart';
import 'package:wastenot/features/goal/widgets/goal_widget.dart';
import 'package:wastenot/services/concern_services.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

import '../../donate/screens/add_donation_screen.dart';
import '../../messages/screens/chat_screen.dart';
import 'accepted_donations_screen.dart';
import 'donation_detail_screen.dart';
import 'emergency_detail_screen.dart';
import 'expired_donations_screen.dart';
import 'your_donations_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DonorHomeScreen({
    super.key,
    required this.user,
  });

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen>
    with WidgetsBindingObserver {
  GoalProgress? _goalData;
  bool _isLoadingGoal = true;
  static const int _recentDonationsLimit = 3;

  final GoalService _goalService = GoalService();
  final ConcernService _concernService = ConcernService();
  Timer? _goalMonthTimer;

  Future<void> _loadGoal() async {
    final user = SessionService.currentUser.value;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _goalData = GoalProgress.empty(_goalService.currentMonthKey());
        _isLoadingGoal = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoadingGoal = true);
    }

    try {
      final data = await _goalService.fetchCurrentMonthProgress(
        user: user,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _goalData = data;
        _isLoadingGoal = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _goalData ??= GoalProgress.empty(_goalService.currentMonthKey());
        _isLoadingGoal = false;
      });
    }
  }

  void _handleGoalRefresh() {
    _loadGoal();
  }

  Stream<List<DonationModel>>? _recentDonorStream;
  String? _recentDonorUid;
  List<DonationModel> _recentDonorCache = const <DonationModel>[];

  String get donorName {
    final sessionName = SessionService.user?.displayName.trim();
    if (sessionName != null && sessionName.isNotEmpty) {
      return sessionName;
    }

    final value = widget.user['name']?.toString().trim();
    if (value == null || value.isEmpty) {
      return 'Donor';
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GoalService.refreshNotifier.addListener(_handleGoalRefresh);
    _loadGoal();
    _goalMonthTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshGoalForNewMonth(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GoalService.refreshNotifier.removeListener(_handleGoalRefresh);
    _goalMonthTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshGoalForNewMonth();
    }
  }

  Future<void> _refreshGoalForNewMonth() async {
    final currentMonth = _goalService.currentMonthKey();
    if ((_goalData?.month ?? currentMonth) == currentMonth) {
      return;
    }

    if (mounted) {
      setState(() {
        _goalData = GoalProgress.empty(currentMonth);
        _isLoadingGoal = true;
      });
    }

    await _loadGoal();
  }

  Stream<List<DonationModel>> _recentCompletedDonationsStream({
    required String donorId,
  }) {
    return FirebaseFirestore.instance
        .collection('donations')
        .where('donorId', isEqualTo: donorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(_recentDonationsLimit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(DonationModel.fromFirestore).toList();
    });
  }

  void _ensureRecentDonorStream(String? uid) {
    if (uid == null || uid.trim().isEmpty) {
      _recentDonorStream = null;
      _recentDonorUid = null;
      return;
    }

    if (_recentDonorUid == uid && _recentDonorStream != null) {
      return;
    }

    _recentDonorUid = uid;
    _recentDonorStream = _recentCompletedDonationsStream(donorId: uid);
  }

  void _refreshRecentDonations() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _ensureRecentDonorStream(SessionService.currentUser.value?.uid);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search donations, locations, features...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('$donorName, ready to make a difference?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const YourDonationsScreen(),
                        ),
                      ),
                      child: const _SummaryCard(
                        'Your Donations',
                        Icons.card_giftcard,
                        Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AcceptedDonationsScreen(),
                        ),
                      ),
                      child: const _SummaryCard(
                        'Accepted Donations',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpiredDonationsScreen(),
                        ),
                      ),
                      child: const _SummaryCard(
                        'Expired Donations',
                        Icons.error_outline,
                        Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Emergency Help',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Live concerns',
                        style: TextStyle(color: DonorHomeScreen.mainGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ConcernModel>>(
                    stream: _concernService.getActiveConcerns(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final concerns = snapshot.hasError
                          ? const <ConcernModel>[]
                          : (snapshot.data ?? const <ConcernModel>[]);
                      if (concerns.isEmpty) {
                        return const Text(
                          'No active concerns right now.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return Column(
                        children: concerns.take(3).map((concern) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EmergencyConcernCard(concern: concern),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _MakeDifferenceCard(),
            const SizedBox(height: 24),
            const _SectionHeader('Local Donation Opportunities'),
            const SizedBox(height: 8),
            const Text(
              'Assist local charities and help those in the Sialkot community.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DonationCard(
                    'SOS Village',
                    'Help provide meals to orphaned children.',
                    'assets/images/sos.png',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            donorName: donorName,
                            ngoName: 'SOS Village',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DonationCard(
                    'Sialkot Shelter',
                    'Support a local shelter with essential supplies.',
                    'assets/images/sialkot.png',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            donorName: donorName,
                            ngoName: 'Sialkot Shelter',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader('Recent Donations'),
            const SizedBox(height: 12),
            StreamBuilder<List<DonationModel>>(
              stream: _recentDonorStream,
              initialData: _recentDonorCache,
              builder: (context, snapshot) {
                if (_recentDonorStream == null &&
                    _recentDonorCache.isEmpty &&
                    snapshot.connectionState == ConnectionState.none) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_recentDonorCache.isNotEmpty) {
                    final donations = _recentDonorCache;
                    return Column(
                      children: donations
                          .map(
                            (donation) => _RecentDonationTile(
                              donation: donation,
                              donorName: donorName,
                              onUpdated: _refreshRecentDonations,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  if (_recentDonorCache.isNotEmpty) {
                    final donations = _recentDonorCache;
                    return Column(
                      children: donations
                          .map(
                            (donation) => _RecentDonationTile(
                              donation: donation,
                              donorName: donorName,
                              onUpdated: _refreshRecentDonations,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to load recent donations.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _refreshRecentDonations,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final donations = snapshot.data ?? const <DonationModel>[];
                if (snapshot.hasData) {
                  _recentDonorCache = donations;
                }
                if (donations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No recent donations.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: donations
                      .map(
                        (donation) => _RecentDonationTile(
                          donation: donation,
                          donorName: donorName,
                          onUpdated: _refreshRecentDonations,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            GoalWidget(
              achievedCount: _goalData?.achievedCount ?? 0,
              target: _goalData?.target ?? 0,
              isLoading: _isLoadingGoal,
              title: 'Your Goal This Month',
              unitLabel: 'donations',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyConcernCard extends StatelessWidget {
  const _EmergencyConcernCard({required this.concern});

  final ConcernModel concern;

  @override
  Widget build(BuildContext context) {
    final imageUrl = concern.imageUrl.trim();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmergencyDetailScreen(concern: concern),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? Image.asset(
                      'assets/images/emergency.jpg',
                      height: 74,
                      width: 74,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      height: 74,
                      width: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/emergency.jpg',
                        height: 74,
                        width: 74,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concern.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    concern.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${concern.ngoName}',
                    style: const TextStyle(
                      color: DonorHomeScreen.mainGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text('View all >', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SummaryCard(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onDonate;

  const _DonationCard(this.title, this.subtitle, this.image, this.onDonate);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DonorHomeScreen.mainGreen,
              ),
              onPressed: onDonate,
              child: const Text(
                'Donate Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDonationTile extends StatelessWidget {
  final DonationModel donation;
  final String donorName;
  final VoidCallback onUpdated;

  const _RecentDonationTile({
    required this.donation,
    required this.donorName,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final rawName = (donation.acceptedByNgoName ?? donation.donorName).trim();
    final displayName = rawName.isNotEmpty ? rawName : donorName;
    final donatedAt = donation.completedAt ?? donation.createdAt;
    final time = _formatRelativeDonationTime(donatedAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: _resolveAvatar(donation),
      ),
      title: Text(displayName),
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
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
    );
  }
}

class _MakeDifferenceCard extends StatelessWidget {
  const _MakeDifferenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: DonorHomeScreen.mainGreen),
              SizedBox(width: 6),
              Text(
                'Make a Difference',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Fight food waste and hunger by donating your surplus food to those in need.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DonorHomeScreen.mainGreen,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddDonationScreen(),
                  ),
                );
              },
              child: const Text(
                'Donate Surplus Food',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ImageProvider _resolveAvatar(DonationModel donation) {
  final url =
      donation.acceptedByNgoProfileImageUrl ?? donation.donorProfileImageUrl;
  if (url != null && url.trim().isNotEmpty) {
    return NetworkImage(url.trim());
  }
  return const AssetImage('assets/images/logo.png');
}

String _formatRelativeDonationTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.isNegative || difference.inMinutes < 1) {
    return 'Donated just now';
  }
  if (difference.inMinutes < 60) {
    return 'Donated ${difference.inMinutes} mins ago';
  }
  if (difference.inHours < 24) {
    return 'Donated ${difference.inHours} hours ago';
  }
  if (difference.inDays == 1) {
    return 'Donated yesterday';
  }
  return 'Donated ${difference.inDays} days ago';
}
