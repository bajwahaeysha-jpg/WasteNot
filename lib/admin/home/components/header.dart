import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../notifications/notification_screen.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [

          /// 🟢 HEADER BAR
          Container(
            height: 72,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F5F54), Color(0xFF128C7E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  "WasteNot",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                /// 🔔 Notifications
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white),
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

                /// 👤 PROFILE AVATAR (NO NETWORK IMAGE)
                GestureDetector(
                  onTap: () => _showProfileOptions(context),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          profileImage != null ? FileImage(profileImage!) : null,
                      child: profileImage == null
                          ? const Icon(Icons.person,
                              size: 18, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH + USER INFO
          Positioned(
            top: 90,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔍 SEARCH BAR
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

                /// 👋 USER INFO
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

  /// 📷 PICK IMAGE
  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  /// 👤 PROFILE OPTIONS
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _previewImage(context),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.person,
                        size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Change Photo"),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove Photo"),
              onTap: () {
                setState(() => profileImage = null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 IMAGE PREVIEW
  void _previewImage(BuildContext context) {
    if (profileImage == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(profileImage!),
        ),
      ),
    );
  }
}
