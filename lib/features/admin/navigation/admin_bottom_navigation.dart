import 'package:flutter/material.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';

import '../analytics/analytics_screen.dart';
import '../home/admin_home_screen.dart';
import '../activity_log/activity_log_screen.dart';
import '../more/more_bottom_sheet.dart';

class AdminBottomNavigation extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminBottomNavigation({
    super.key,
    required this.user,
  });

  @override
  State<AdminBottomNavigation> createState() =>
      _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminHomeScreen(user: widget.user),
      const AnalyticsScreen(),
      const ActivityLogScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // âœ… Only allow system back when already on Home
      canPop: false,

      // âœ… NEW API (Flutter 3.22+)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // ðŸ” If user is NOT on Home â†’ go to Home
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        AppNavigationHandler.exitApp();
      },

      child: Scaffold(
        body: _pages[_currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0B4B3F),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: "Analysis",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Activity Log",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: "More",
            ),
          ],
          onTap: (index) {
            // ðŸ”¹ MORE â†’ bottom sheet
            if (index == 3) {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => AdminMoreSheet(user: widget.user),
              );
              return;
            }

            if (index == _currentIndex) return;
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
