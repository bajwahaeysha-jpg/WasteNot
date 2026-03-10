import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/core/state/app_user.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {

  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? selectedImage;

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: AppUser.name);

    emailController =
        TextEditingController(text: AppUser.email);

    phoneController =
        TextEditingController(text: AppUser.phone ?? "");

    selectedImage = AppUser.image;
  }

  /// IMAGE PICK
  Future<void> _pickImage() async {

    if (!isEditing) return;

    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  /// EDIT / SAVE
  void _toggleEditSave() {

    if (isEditing) {

      AppUser.update(
        newName: nameController.text.trim(),
        newEmail: emailController.text.trim(),
        newPhone: phoneController.text.trim(),
        newImage: selectedImage,
      );

      Navigator.pop(context);
      return;
    }

    setState(() {
      isEditing = true;
    });
  }

  /// INPUT FIELD
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
          "Personal Information",
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
                    mainGreen.withOpacity(0.15),

                backgroundImage:
                    selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,

                child: selectedImage == null
                    ? Text(
                        AppUser.name
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: mainGreen,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            _field("Name", nameController),

            _field("Email", emailController),

            _field("Phone", phoneController),
          ],
        ),
      ),
    );
  }
}