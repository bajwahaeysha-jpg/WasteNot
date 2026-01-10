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
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        enabled: isEditing,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isEditing ? Colors.black : Colors.grey.shade300,
              width: isEditing ? 1.6 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.8),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Personal Information",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _toggleEditSave,
            child: Text(isEditing ? "Save" : "Edit"),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // 🖼 Profile Photo with Edit Icon
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null
                      ? Text(
                          AppUser.name.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),

              if (isEditing)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          _field("NGO Name", nameController),
          _field("Email", emailController),
          _field("Phone Number", phoneController),
        ]),
      ),
    );
  }
}
