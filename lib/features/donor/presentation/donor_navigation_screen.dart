import 'package:flutter/material.dart';
import 'home/screens/donor_home_screen.dart';
import 'donate/screens/donate_screen.dart';
import 'messages/screens/messages_screen.dart';
import 'profile/screens/donor_profile_screen.dart';
import 'settings/screens/donor_settings_screen.dart';
import 'auth/screens/donor_logout_screen.dart';
import 'package:wastenot/features/donor/presentation/notifications/screens/notification_screen.dart';
import 'package:wastenot/features/donor/presentation/feedback/screens/feedback_screen.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/services/notification_badge_service.dart';
import 'package:wastenot/services/session_service.dart';

class DonorNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DonorNavigationScreen({
    super.key,
    required this.user,
  });

  @override
  State<DonorNavigationScreen> createState() => _DonorNavigationScreenState();
}

class _DonorNavigationScreenState extends State<DonorNavigationScreen> {

  int _currentIndex = 0;

  static const Color mainGreen = Color(0xFF0E5E53);

  late final List<Widget> pages;

  final List<String> titles = [
    "WasteNot",
    "Donate",
    "Messages",
    "More"
  ];

  @override
  void initState() {
    super.initState();

    pages = [
      DonorHomeScreen(user: widget.user),
      const DonateScreen(),
      MessagesScreen(donorName: widget.user['name']),
      const SizedBox(),
    ];
  }

  @override
  Widget build(BuildContext context) {
 
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
 
        appBar: AppBar(
          backgroundColor: mainGreen,
          elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: Text(
          titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
 
          StreamBuilder<int>(
            stream: NotificationBadgeService().donorBellCount(
              uid: (SessionService.user?.uid) ?? widget.user['uid']?.toString(),
              email:
                  (SessionService.user?.email) ?? widget.user['email']?.toString(),
            ),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              final label = count > 9 ? '9+' : '$count';

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 14,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
 
          const SizedBox(width: 10),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DonorProfileScreen(),
                  ),
                );
              },

              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  SessionService.initials(),
                  style: TextStyle(
                    color: mainGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )

        ],
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: mainGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 3) {
            _openMoreSheet(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "WasteNot",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Donate",
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
  }

  void _openMoreSheet(BuildContext context) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DonorProfileScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DonorSettingsScreen(),
                  ),
                );
              },
            ),

            // ✅ NEW FEEDBACK OPTION

            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeedbackScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DonorLogoutScreen(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
