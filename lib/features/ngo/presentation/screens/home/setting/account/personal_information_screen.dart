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

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  File? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: "Khair Foundation");
    emailController = TextEditingController(text: "khairfoundation@gmail.com");
    phoneController = TextEditingController(text: "03001234567");
    locationController = TextEditingController(text: "Sialkot");
  }

  void _toggleEditSave() {
    if (isEditing) {
      // future me yahan AppUser update kar sakte ho
      Navigator.pop(context);
    }

    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black)),

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
                color:
                    isEditing ? const Color(0xFF0F4C45) : Colors.grey.shade300,
                width: isEditing ? 1.6 : 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0F4C45), width: 1.8),
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
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Personal Information",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          TextButton(
            onPressed: _toggleEditSave,
            child: Text(
              isEditing ? "Save" : "Edit",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Profile Photo
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        const Color(0xFF0F4C45).withValues(alpha: .15),

                    backgroundImage:
                        selectedImage != null ? FileImage(selectedImage!) : null,

                    child: selectedImage == null
                        ? const Text(
                            "KF",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C45)),
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
                        color: Color(0xFF0F4C45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            _field("NGO Name", nameController),
            _field("Email", emailController),
            _field("Phone Number", phoneController),
            _field("Location", locationController),
          ],
        ),
      ),
    );
  }
}