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

  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Personal Information",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
            child: Text(isEditing ? "Save" : "Edit"),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          _field("Name", nameController),
          _field("Email", emailController),
          _field("Phone", phoneController),

        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }
}
