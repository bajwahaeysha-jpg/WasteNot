import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../inbox/messages_screen.dart';
import '../active/active_donations_screen.dart';
import '../home/all_donations/all_donations_screen.dart';
import '../home/accepted/accepted_donations_screen.dart';
import '../home/impact/impact_screen.dart';
import '../home/setting/settings_screen.dart';
import '../../../presentation/screens/global_search_screen.dart';
import '../home/notification/notifications_screen.dart';
import '../home/setting/account/personal_information_screen.dart';
import '..//home/concern/raise_concern_screen.dart';
import 'package:wastenot/core/state/ngo_concern.dart';
import '../home/goal/ngo_goal_screen.dart';
import '../home/all_donations/donation_details_screen.dart';
import '../home/all_donations/donation_model.dart';
import 'package:wastenot/features/ngo/presentation/screens/ngo_feedback_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
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

  Widget _getBody() {
    if (_index == 0) {
      return _homeBody();
    } else if (_index == 1) {
      return const ActiveDonationsScreen();
    } else if (_index == 2) {
      return MessagesScreen();
    } else {
      return const SettingsScreen();
    }
  }
String _getTitle() {
  switch (_index) {
    case 0:
      return "WasteNot";
    case 1:
      return "Active Donations";
    case 2:
      return "Messages";
    default:
      return "WasteNot";
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

          //  HEADER
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      //  Search Bar
    Container(
  height: 48,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: const Color(0x14000000) ,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
      );
    },
    child: AbsorbPointer(
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search donations, locations, features...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
  ),
),

      const SizedBox(height: 10),

      Text(
        "Hello, $displayName",
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,color: Colors.black),
      ),

      const SizedBox(height: 4),

      const Text(
        "Ready to make a difference today. Distribute food to those who need it most.",
        style: TextStyle(color: Colors.black),
      ),
    ],
  ),
),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //  HERO
              Container(
  height: 160,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    image: const DecorationImage(
      image: AssetImage("assets/images/home1.png"),
      fit: BoxFit.cover,
    ),
  ),
  child: Stack(
    children: [

      // Dark overlay for readability
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0x26FFFFFF),
        ),
      ),
      //  Monthly Goal Card
      //  Monthly Goal Glass Bar (Top Overlay)
//  Monthly Goal Floating Bar (centered)
Positioned(
  left: 16,
  right: 16,
  top: 32,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Monthly Donation Goal",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Text(
            "73 / 100  •  73%",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: 0.73,
          minHeight: 6,
          backgroundColor: const Color(0x26FFFFFF),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
        ),
      ),
    ],
  ),
),

    ],
  ),
),

              const SizedBox(height: 10),

              //  DASHBOARD CARDS
              //  DASHBOARD CARDS GROUP
//  DASHBOARD SECTION
//  DASHBOARD WRAPPER CARD
Container(
  margin: const EdgeInsets.only(top: 14),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: const Color(0x14000000),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Row(
    children: [
      Expanded(
        child: _DashCard(
          title: "Your\nImpact",
          icon: Icons.insights,
          bg: const Color(0xFFF3E5F5),
          border: const Color(0xFFD1C4E9),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImpactScreen()),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _DashCard(
          title: "Accepted\nDonations",
          icon: Icons.check_circle,
          bg: const Color(0xFFE8F5E9),
          border: const Color(0xFFA5D6A7),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AcceptedDonationsScreen()),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _DashCard(
          title: "Available\nDonations",
          icon: Icons.notifications_active,
          bg: const Color(0xFFE3F2FD),
          border: const Color(0xFF90CAF9),
          badge: 2,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllDonationsScreen()),
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 16),
const SizedBox(height: 24),

const Text(
  "Your Concern Analysis",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),

const SizedBox(height: 10),

//  RAISE A CONCERN CARD
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0x14000000),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "🚨 Raise a Concern",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black
            ),
          ),
          Icon(Icons.report_problem, color: Colors.red),
        ],
      ),

      const SizedBox(height: 8),
      Text(
  NgoConcern.currentConcern ??
      "No active concern yet. Raise one to inform donors and volunteers.",
  style: const TextStyle(color: Colors.black, height: 1.4),
),

      const SizedBox(height: 12),
      Row(
        children: const [
          Icon(Icons.remove_red_eye, size: 18, color: Colors.black),
          SizedBox(width: 6),
          Text("34 donors viewed this concern", style: TextStyle( color: Colors.black)),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: 0.34,
          minHeight: 6,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 24),

              const Text("Recent Donations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),

              const SizedBox(height: 12),

              _donationTile(
                title: "60 bread packets",
                location: "Wedding Hall - Sector 11",
                time: "Pickup within 45 min",
              ),

              _donationTile(
                title: "100 cooked meals",
                location: "Cafe Aroma - Block C",
                time: "Pickup in 1 hour",
              ),
            ]),
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

        return Scaffold(
          backgroundColor: const Color.fromRGBO(245, 247, 246, 1),
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
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
              unselectedItemColor: AppColors.primary.withValues(alpha: .35),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory),
                  label: "Active",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: "Messages",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: "More",
                ),
              ],
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

          _moreItem(Icons.person, "Profile", () {
            Navigator.pop(context);
            Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
              );
          }),

          _moreItem(Icons.settings, "Settings", () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),

          _moreItem(Icons.report_problem, "Raise a Concern", () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const RaiseConcernScreen()),
  ).then((_) => setState(() {}));
}),


         _moreItem(Icons.flag, "Set Monthly Goal", () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NgoGoalScreen()),
  );
}),

_moreItem(Icons.feedback, "Feedback", () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NgoFeedbackScreen(),
    ),
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
}) {
  return GestureDetector(
    onTap: () {

      final donation = DonationModel(
        hotel: location,
        items: title,
        time: time,
        servings: 60,
        precaution: "Consume within 4 hours",
        description: title,
        image: "assets/images/food.jpg",
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationDetailsScreen(donation: donation),
        ),
      );
    },

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
              "assets/images/food.jpg",
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            /// 🔹 MAIN CONTENT — TRUE CENTER
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

            /// 🔴 BADGE — DOES NOT AFFECT LAYOUT
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


