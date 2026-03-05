import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../notifications/notification_screen.dart';
import '../../more/profile/admin_profile_screen.dart';

class Header extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<String>? onSearch;

  const Header({
    super.key,
    required this.user,
    this.onSearch,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  int _notificationCount = 3;
  File? profileImage;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onGlobalSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearch?.call(value.trim());
    });

    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.24,

      child: Stack(
        children: [

          /// 🟢 HEADER BAR
          Container(
            height: screenHeight * 0.09,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F5F54), Color(0xFF0F5F54)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0,2),
                )
              ],
            ),

            child: Row(
              children: [

                /// APP TITLE
                const Text(
                  "WasteNot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                /// 🔔 NOTIFICATIONS
                Stack(
                  children: [

                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                      onPressed: () {

                        setState(() => _notificationCount = 0);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),

                    if (_notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: Colors.red,
                          child: Text(
                            "$_notificationCount",
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                /// 👤 PROFILE ICON
                GestureDetector(
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProfileScreen(),
                      ),
                    );

                  },

                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,

                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.grey.shade200,

                      backgroundImage:
                          profileImage != null
                              ? FileImage(profileImage!)
                              : null,

                      child: profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH + USER INFO
          Positioned(
            top: screenHeight * 0.11,
            left: 16,
            right: 16,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// SEARCH BAR
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),

                  child: TextField(
                    controller: _searchController,
                    onChanged: _onGlobalSearch,

                    decoration: InputDecoration(
                      hintText:
                          "Search donors, NGOs, donations, locations...",

                      prefixIcon: const Icon(Icons.search),

                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),

                              onPressed: () {
                                _searchController.clear();
                                widget.onSearch?.call("");
                                setState(() {});
                              },
                            )
                          : null,

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// USER NAME
                Text(
                  widget.user['name'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "Admin",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}