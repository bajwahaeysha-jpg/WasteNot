import 'package:flutter/material.dart';

class DonorPersonalInformationScreen extends StatefulWidget {
  const DonorPersonalInformationScreen({super.key});

  @override
  State<DonorPersonalInformationScreen> createState() =>
      _DonorPersonalInformationScreenState();
}

class _DonorPersonalInformationScreenState
    extends State<DonorPersonalInformationScreen> {

  final nameController = TextEditingController(text: "Allah Malik");
  final emailController = TextEditingController(text: "allahmalik@gmail.com");
  final phoneController = TextEditingController(text: "0300-1234567");
  final locationController = TextEditingController(text: "Sialkot, Pakistan");

  bool isEditing = false;

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Personal Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
            child: Text(
              isEditing ? "Save" : "Edit",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          _field("Name", nameController),
          _field("Email", emailController),
          _field("Phone", phoneController),
          _field("Location", locationController),

        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 18),

      ],
    );
  }
}