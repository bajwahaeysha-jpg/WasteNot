import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProfileScreen extends StatefulWidget {

  final Map<String, dynamic> user;

  const AdminProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {

  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? selectedImage;

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.user['name'] ?? "");

    emailController =
        TextEditingController(text: widget.user['email'] ?? "");

    phoneController =
        TextEditingController(text: widget.user['phone'] ?? "");

    if (widget.user['image'] != null) {
      selectedImage = File(widget.user['image']);
    }
  }

  Future<void> _pickImage() async {

    if (!isEditing) return;

    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _toggleEditSave() {

    if (isEditing) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      isEditing = true;
    });
  }

  Widget _field(String label, TextEditingController controller) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          enabled: isEditing,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),

        iconTheme:
            const IconThemeData(color: Colors.white),

        actions: [

          TextButton(
            onPressed: _toggleEditSave,
            child: Text(
              isEditing ? "Save" : "Edit",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// PROFILE IMAGE
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 54,
                backgroundColor:
                    mainGreen.withValues(alpha:.15),

                backgroundImage:
                    selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,

                child: selectedImage == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: mainGreen,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            _field("Name", nameController),

            _field("Email", emailController),

            _field("Phone", phoneController),

            const SizedBox(height: 24),

            /// DELETE PROFILE
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(28),
                  ),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Delete Profile",
                  style: TextStyle(
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}