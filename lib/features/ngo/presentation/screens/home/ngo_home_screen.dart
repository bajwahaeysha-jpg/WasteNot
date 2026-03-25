import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/features/ngo/presentation/screens/active/active_donations_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/global_search_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/accepted/accepted_donations_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/all_donations/all_donations_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/all_donations/donation_details_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/concern/raise_concern_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/goal/ngo_goal_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/impact/impact_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/notification/notifications_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/account/personal_information_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/setting/settings_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/inbox/messages_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/ngo_feedback_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/services/concern_services.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/goal_services.dart';
import 'package:wastenot/services/notification_badge_service.dart';
import 'package:wastenot/services/session_service.dart';

class NgoHomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const NgoHomeScreen({
    super.key,
    this.user,
  });

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  int _index = 0;
  final GoalService _goalService = GoalService();
  final ConcernService _concernService = ConcernService();
  Stream<List<DonationModel>>? _recentNgoStream;
  String? _recentNgoUid;
  List<DonationModel> _recentNgoCache = const <DonationModel>[];

  Stream<List<DonationModel>> _recentCompletedNgoDonationsStream({
    required String ngoId,
  }) {
    return FirebaseFirestore.instance
        .collection('donations')
        .where('acceptedByNgoId', isEqualTo: ngoId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(DonationModel.fromFirestore).toList();
    });
  }

  void _ensureRecentNgoStream(String? uid) {
    if (uid == null || uid.trim().isEmpty) {
      _recentNgoStream = null;
      _recentNgoUid = null;
      return;
    }

    if (_recentNgoUid == uid && _recentNgoStream != null) {
      return;
    }

    _recentNgoUid = uid;
    _recentNgoStream = _recentCompletedNgoDonationsStream(ngoId: uid);
  }

  Widget _getBody() {
    if (_index == 0) {
      return _homeBody();
    }
    if (_index == 1) {
      return const ActiveDonationsScreen();
    }
    if (_index == 2) {
      return MessagesScreen();
    }
    return const SettingsScreen();
  }

  String _getTitle() {
    switch (_index) {
      case 1:
        return 'Active Donations';
      case 2:
        return 'Messages';
      default:
        return 'WasteNot';
    }
  }

  Widget _homeBody() {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        final displayName =
            user?.displayName ?? widget.user?['name']?.toString() ?? 'NGO';

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GlobalSearchScreen(),
                            ),
                          );
                        },
                        child: const AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText:
                                  'Search donations, locations, features...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hello, $displayName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to make a difference today. Distribute food to those who need it most.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NgoGoalScreen()),
    );
  },
  child: Container(
    height: 160,
    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/home1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0x26FFFFFF),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            top: 32,
                            child: StreamBuilder<GoalProgress>(
                              stream: user == null
                                  ? null
                                  : _goalService
                                      .streamCurrentUserMonthlyGoalProgress(
                                        user: user,
                                      ),
                              builder: (context, snapshot) {
                                final progress = snapshot.data;
                                final achieved = progress?.achievedCount ?? 0;
                                final target = progress?.monthlyTarget ?? 0;
                                final hasGoal = progress?.hasGoal ?? false;
                                final ratio =
                                    target <= 0 ? 0.0 : achieved / target;
                                final percent =
                                    target <= 0 ? 0 : (ratio * 100).round();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
  children: [
    const Expanded(
      child: Text(
        'Monthly Donation Goal',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        hasGoal
            ? '$achieved / $target  •  $percent%'
            : 'Set your goal to start tracking progress',
        textAlign: TextAlign.end,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: ratio.clamp(0.0, 1.0),
                                        minHeight: 6,
                                        backgroundColor:
                                            const Color(0x26FFFFFF),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFFD54F),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DashCard(
                              title: 'Your\nImpact',
                              icon: Icons.insights,
                              bg: const Color(0xFFF3E5F5),
                              border: const Color(0xFFD1C4E9),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ImpactScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashCard(
                              title: 'Accepted\nDonations',
                              icon: Icons.check_circle,
                              bg: const Color(0xFFE8F5E9),
                              border: const Color(0xFFA5D6A7),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AcceptedDonationsScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashCard(
                              title: 'Available\nDonations',
                              icon: Icons.notifications_active,
                              bg: const Color(0xFFE3F2FD),
                              border: const Color(0xFF90CAF9),
                              badge: 2,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllDonationsScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Concern Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ConcernSummaryCard(
                      concernService: _concernService,
                      ngoId: user?.uid,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Donations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<DonationModel>>(
                      stream: _recentNgoStream,
                      initialData: _recentNgoCache,
                      builder: (context, snapshot) {
                        if (_recentNgoStream == null &&
                            _recentNgoCache.isEmpty &&
                            snapshot.connectionState == ConnectionState.none) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          if (_recentNgoCache.isNotEmpty) {
                            final recent = _recentNgoCache;
                            return Column(
                              children: recent.map((donation) {
                                final location =
                                    donation.location?.trim().isNotEmpty == true
                                        ? donation.location!.trim()
                                        : 'Location not provided';
                                final time =
                                    _recentDonationTime(donation.completedAt ??
                                        donation.createdAt);
                                return _donationTile(
                                  title: donation.foodItems.join(', '),
                                  location: location,
                                  time: time,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DonationDetailsScreen(
                                          donation: donation,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          if (_recentNgoCache.isNotEmpty) {
                            final recent = _recentNgoCache;
                            return Column(
                              children: recent.map((donation) {
                                final location =
                                    donation.location?.trim().isNotEmpty == true
                                        ? donation.location!.trim()
                                        : 'Location not provided';
                                final time =
                                    _recentDonationTime(donation.completedAt ??
                                        donation.createdAt);
                                return _donationTile(
                                  title: donation.foodItems.join(', '),
                                  location: location,
                                  time: time,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DonationDetailsScreen(
                                          donation: donation,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Unable to load recent donations.'),
                          );
                        }

                        final recent =
                            snapshot.data ?? const <DonationModel>[];
                        if (snapshot.hasData) {
                          _recentNgoCache = recent;
                        }
                        if (recent.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No recent donations.'),
                          );
                        }

                        return Column(
                          children: recent.map((donation) {
                            final location =
                                donation.location?.trim().isNotEmpty == true
                                    ? donation.location!.trim()
                                    : 'Location not provided';
                            final time =
                                _recentDonationTime(donation.completedAt ??
                                    donation.createdAt);
                            return _donationTile(
                              title: donation.foodItems.join(', '),
                              location: location,
                              time: time,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DonationDetailsScreen(
                                      donation: donation,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        final profileImageUrl = user?.profileImageUrl;
        _ensureRecentNgoStream(user?.uid);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }

            if (_index != 0) {
              setState(() => _index = 0);
              return;
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7F6),
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: false,
              title: Text(
                _getTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 26),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: NotificationBadgeService().ngoBellCount(
                        uid: user?.uid,
                        email: user?.email,
                      ),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        if (count <= 0) {
                          return const SizedBox.shrink();
                        }

                        final label = count > 9 ? '9+' : '$count';
                        return Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: profileImageUrl != null &&
                            profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    backgroundColor: Colors.white24,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? Text(
                            SessionService.initials(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            body: _getBody(),
            bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) {
                  if (i == 3) {
                    _openMoreSheet();
                  } else {
                    setState(() => _index = i);
                  }
                },
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.primary.withOpacity(0.35),
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory),
                    label: 'Active',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            _moreItem(Icons.person, 'Profile', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationScreen(),
                ),
              );
            }),
            _moreItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),
            _moreItem(Icons.report_problem, 'Raise a Concern', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RaiseConcernScreen(),
                ),
              ).then((_) => setState(() {}));
            }),
            _moreItem(Icons.flag, 'Set Monthly Goal', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NgoGoalScreen()),
              );
            }),
            _moreItem(Icons.feedback, 'Feedback', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NgoFeedbackScreen()),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _moreItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _donationTile({
    required String title,
    required String location,
    required String time,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllDonationsScreen()),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/food.jpg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(location),
                  Text(time),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _recentDonationTime(DateTime value) {
  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.isNegative || difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }
  if (difference.inDays == 1) {
    return 'Yesterday';
  }
  return '${difference.inDays} days ago';
}

class _ConcernSummaryCard extends StatelessWidget {
  const _ConcernSummaryCard({
    required this.concernService,
    required this.ngoId,
  });

  final ConcernService concernService;
  final String? ngoId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConcernModel>>(
      stream: ngoId == null ? null : concernService.getNgoConcerns(ngoId!),
      builder: (context, snapshot) {
        final concerns = snapshot.data ?? const <ConcernModel>[];
        ConcernModel? activeConcern;
        for (final concern in concerns) {
          if (concern.isActive && !concern.isExpired) {
            activeConcern = concern;
            break;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raise a Concern',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.report_problem, color: Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activeConcern?.message ??
                    'No active concern yet. Raise one to inform donors and volunteers.',
                style: const TextStyle(color: Colors.black, height: 1.4),
              ),
              const SizedBox(height: 12),
              if (activeConcern == null)
                const Text(
                  'Active concerns will appear here with expiry tracking.',
                  style: TextStyle(color: Colors.black54),
                )
              else ...[
                if (activeConcern.imageUrl.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      activeConcern.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  activeConcern.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Expires on ${_formatConcernDate(activeConcern.expiryTime)}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _concernProgress(activeConcern),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bg;
  final Color border;
  final int? badge;
  final VoidCallback onTap;

  const _DashCard({
    required this.title,
    required this.icon,
    required this.bg,
    required this.border,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 34, color: Colors.black87),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatConcernDate(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]}, $hour:$minute $suffix';
}

double _concernProgress(ConcernModel concern) {
  final total = concern.expiryTime.difference(concern.createdAt).inSeconds;
  if (total <= 0) {
    return 0;
  }

  final remaining = concern.expiryTime.difference(DateTime.now()).inSeconds;
  return (remaining / total).clamp(0.0, 1.0);
}

