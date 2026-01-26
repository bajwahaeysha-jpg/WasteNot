import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  bool isEditing = false;

  final TextEditingController nameController =
      TextEditingController(text: "Allah Malik");
  final TextEditingController emailController =
      TextEditingController(text: "donor@email.com");
  final TextEditingController phoneController =
      TextEditingController(text: "0300-0000000");

  File? selectedImage;

  void _toggleEditSave() {
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
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isEditing ? Colors.black : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personal Information"),
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

          // Profile Image
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
                      ? const Text("AM",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              if (isEditing)
                const Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.edit, color: Colors.white, size: 16),
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
