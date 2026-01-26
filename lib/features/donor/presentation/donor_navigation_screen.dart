import 'package:flutter/material.dart';
import 'home/screens/donor_home_screen.dart';
import 'donate/screens/donate_screen.dart';
import 'messages/screens/messages_screen.dart';
import 'profile/screens/donor_profile_screen.dart';
import 'settings/screens/donor_settings_screen.dart';
import 'goal/screens/donor_goal_screen.dart';
import 'auth/screens/donor_logout_screen.dart';

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

  late final List<Widget> pages;

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
    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0E5E53),
        unselectedItemColor: const Color(0xFF0E5E53),
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 3) {
            _openMoreSheet(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Donate"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
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
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonorProfileScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonorSettingsScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text("Monthly Goal"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonorGoalScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonorLogoutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
