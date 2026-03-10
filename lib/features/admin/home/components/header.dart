import 'dart:io';
import 'package:flutter/material.dart';
import '../../notifications/notification_screen.dart';
import '../../more/profile/admin_profile_screen.dart';

class Header extends StatefulWidget {
  final Map<String, dynamic> user;

  const Header({
    super.key,
    required this.user,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  int _notificationCount = 3;
  File? profileImage;

  @override
  void initState() {
    super.initState();

    if (widget.user['image'] != null) {
      profileImage = File(widget.user['image']);
    }
  }

  @override
  Widget build(BuildContext context) {

    final statusBar = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: statusBar + 6,
        left: 16,
        right: 16,
        bottom: 10,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFF0F5F54),
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

          /// LOGO + NAME
          Row(
            children: [

              Image.asset(
                "assets/images/logo.png",
                height: 46,
                width: 46,
                fit: BoxFit.contain,
              ),

              const SizedBox(width: 10),

              const Text(
                "WasteNot",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          /// NOTIFICATION
          Stack(
            children: [

              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                onPressed: () {

                  setState(() {
                    _notificationCount = 0;
                  });

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

          /// PROFILE IMAGE
          GestureDetector(
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminProfileScreen(
                    user: widget.user,
                  ),
                ),
              );
            },

            child: CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,

              child: CircleAvatar(
                radius: 17,
                backgroundImage:
                    profileImage != null
                        ? FileImage(profileImage!)
                        : null,

                child: profileImage == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}