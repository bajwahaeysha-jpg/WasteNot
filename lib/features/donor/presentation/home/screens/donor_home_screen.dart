import 'package:flutter/material.dart';
import 'your_donations_screen.dart';
import 'accepted_donations_screen.dart';
import 'expired_donations_screen.dart';
import 'donation_detail_screen.dart';
import 'emergency_detail_screen.dart';
import '../../donate/screens/add_donation_screen.dart';
import '../../messages/screens/chat_screen.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/goal_services.dart';
import 'package:wastenot/models/app_user_model.dart';

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
 
class _DonorHomeScreenState extends State<DonorHomeScreen> {
  static const int _recentDonationsLimit = 3;
  final DonationService _donationService = DonationService();
  final GoalService _goalService = GoalService();
  late Future<List<DonationModel>> _recentDonationsFuture;

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
    _recentDonationsFuture = _loadRecentDonations();
  }

  Future<List<DonationModel>> _loadRecentDonations() {
    return _donationService.getRecentCompletedDonations(
      limit: _recentDonationsLimit,
    );
  }

  void _refreshRecentDonations() {
    setState(() => _recentDonationsFuture = _loadRecentDonations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // 🔍 Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search donations, locations, features...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Welcome Back!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("$donorName, ready to make a difference?"),

          const SizedBox(height: 16),

          // 🎁 Summary Cards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourDonationsScreen())),
                  child: const _SummaryCard("Your Donations", Icons.card_giftcard, Colors.purple),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcceptedDonationsScreen())),
                  child: const _SummaryCard("Accepted Donations", Icons.check_circle, Colors.green),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiredDonationsScreen())),
                  child: const _SummaryCard("Expired Donations", Icons.error_outline, Colors.redAccent),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // 🧑‍🤝‍🧑 Emergency Help
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyDetailScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text("Emergency Help", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("See all", style: TextStyle(color: DonorHomeScreen.mainGreen)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset("assets/images/emergency.jpg", height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                const Text("Donations For Flood Affectes", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Target: 5000", style: TextStyle(color: DonorHomeScreen.mainGreen)),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          const _MakeDifferenceCard(),

          const SizedBox(height: 24),

          const _SectionHeader("Local Donation Opportunities"),
          const SizedBox(height: 8),
          const Text("Assist local charities and help those in the Sialkot community."),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(
              child: _DonationCard(
                "SOS Village",
                "Help provide meals to orphaned children.",
                "assets/images/sos.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        donorName: donorName,
                        ngoName: "SOS Village",
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DonationCard(
                "Sialkot Shelter",
                "Support a local shelter with essential supplies.",
                "assets/images/sialkot.png",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        donorName: donorName,
                        ngoName: "Sialkot Shelter",
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),

          const SizedBox(height: 24),

          const _SectionHeader("Recent Donations"),
          const SizedBox(height: 12),

          FutureBuilder<List<DonationModel>>(
            future: _recentDonationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Unable to load recent donations.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _refreshRecentDonations,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final donations = snapshot.data ?? const <DonationModel>[];
              if (donations.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No recent donations yet.",
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

          ValueListenableBuilder<AppUserModel?>(
            valueListenable: SessionService.currentUser,
            builder: (context, user, _) {
              if (user == null) {
                return const _ImpactSection(
                  donationsCount: 0,
                  achievedCount: 0,
                  monthlyTarget: 0,
                  isLoading: false,
                );
              }

              return StreamBuilder<GoalProgress>(
                stream: _goalService.streamCurrentUserMonthlyGoalProgress(
                  user: user,
                ),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return _ImpactSection(
                    donationsCount: data?.donationsCount ?? 0,
                    achievedCount: data?.achievedCount ?? 0,
                    monthlyTarget: data?.monthlyTarget ?? 0,
                    isLoading:
                        snapshot.connectionState == ConnectionState.waiting,
                  );
                },
              );
            },
          ),
        ]),
      ),
    );
  }
}

/* ================= COMPONENTS ================= */

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text("View all >", style: TextStyle(color: Colors.grey)),
    ]);
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
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final String title, subtitle, image;
  final VoidCallback onDonate;

  const _DonationCard(this.title, this.subtitle, this.image, this.onDonate);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, height: 90, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DonorHomeScreen.mainGreen),
            onPressed: onDonate,
            child: const Text("Donate Now", style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.favorite, color: DonorHomeScreen.mainGreen),
          SizedBox(width: 6),
          Text("Make a Difference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        const Text("Fight food waste and hunger by donating your surplus food to those in need."),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DonorHomeScreen.mainGreen),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDonationScreen()));
            },
            child: const Text("Donate Surplus Food", style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection({
    required this.donationsCount,
    required this.achievedCount,
    required this.monthlyTarget,
    required this.isLoading,
  });

  final int donationsCount;
  final int achievedCount;
  final int monthlyTarget;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final safeTarget = monthlyTarget <= 0 ? 0 : monthlyTarget;
    final progress =
        safeTarget == 0 ? 0.0 : achievedCount / safeTarget.toDouble();
    final percent = safeTarget == 0 ? 0 : (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.insights, color: DonorHomeScreen.mainGreen),
          SizedBox(width: 6),
          Text("Your Impact This Month", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _ImpactItem(
            title: "Donations Made",
            value: donationsCount.toString(),
          ),
          _ImpactItem(
            title: "People Fed",
            value: achievedCount.toString(),
          ),
        ]),
        const SizedBox(height: 14),
        const Text("Monthly Goal Progress", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey,
            color: DonorHomeScreen.mainGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoading
              ? "Updating goal progress..."
              : "$percent% completed — Keep it up! 🌟",
        ),
      ]),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final String title, value;
  const _ImpactItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DonorHomeScreen.mainGreen)),
      Text(title, style: const TextStyle(color: Colors.grey)),
    ]);
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
  if (difference.isNegative) {
    return 'Donated just now';
  }
  if (difference.inMinutes < 1) {
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
