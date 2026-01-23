import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  bool isEditing = false;

  final nameController = TextEditingController(text: "Admin User");
  final emailController = TextEditingController(text: "admin@email.com");
  final phoneController = TextEditingController(text: "+92 300 0000000");

  File? selectedImage;

  void _toggleEditSave() {
    setState(() => isEditing = !isEditing);

    if (!isEditing) {
    }
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
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
       
        title: const Text("Personal Information",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _toggleEditSave,
            child: Text(isEditing ? "Save" : "Edit"),
          ),
        ],
         iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // 🖼 Profile
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
                      ? const Text("AU",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold))
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

          _field("Name", nameController),
          _field("Email", emailController),
          _field("Phone", phoneController),
        ]),
      ),
    );
  }
}
