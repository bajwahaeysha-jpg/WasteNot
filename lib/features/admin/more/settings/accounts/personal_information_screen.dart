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

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {

  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadFromUser();
  }

  void _loadFromUser() {
    nameController = TextEditingController(text: AppUser.name);
    emailController = TextEditingController(text: AppUser.email);
    phoneController = TextEditingController(text: AppUser.phone ?? "");
    selectedImage = AppUser.image;
  }

  void _toggleEditSave() {
    if (isEditing) {
      AppUser.update(
        newName: nameController.text.trim(),
        newEmail: emailController.text.trim(),
        newPhone: phoneController.text.trim(),
        newImage: selectedImage,
      );

      Navigator.pop(context);
    }

    setState(() => isEditing = !isEditing);
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  /// 🟩 MODERN INPUT FIELD
  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEditing ? const Color(0xFF0F4C45) : Colors.grey.shade300,
              width: isEditing ? 1.5 : 1,
            ),
          ),

          child: TextField(
            controller: controller,
            enabled: isEditing,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🟢 MODERN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),

        title: Row(
          children: const [
            Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: Colors.white),
          ],
        ),

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

      /// 📱 SCREEN BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// 🖼 PROFILE IMAGE
            Stack(
              alignment: Alignment.center,
              children: [

                GestureDetector(
                  onTap: _pickImage,

                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFFE8F3F1),

                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,

                    child: selectedImage == null
                        ? Text(
                            AppUser.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C45),
                            ),
                          )
                        : null,
                  ),
                ),

                /// ✏ EDIT ICON
                if (isEditing)
                  Positioned(
                    bottom: 6,
                    right: 6,

                    child: Container(
                      height: 32,
                      width: 32,

                      decoration: const BoxDecoration(
                        color: Color(0xFF0F4C45),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            /// 🧾 FORM FIELDS
            _field("NGO Name", nameController),
            _field("Email", emailController),
            _field("Phone Number", phoneController),
          ],
        ),
      ),
    );
  }
}