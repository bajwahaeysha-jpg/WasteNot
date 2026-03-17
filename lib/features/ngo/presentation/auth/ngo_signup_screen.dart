import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NgoSignUpScreen extends StatefulWidget {
  const NgoSignUpScreen({super.key});

  @override
  State<NgoSignUpScreen> createState() => _NgoSignUpScreenState();
}

class _NgoSignUpScreenState extends State<NgoSignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController ngoNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController regNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  File? _image;

  final ImagePicker picker = ImagePicker();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  static const primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("NGO Sign Up"),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// Profile Image
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: primary.withValues(alpha:0.1),
                  backgroundImage:
                      _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 35)
                      : null,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Upload NGO Logo",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 30),

              buildField("NGO Name", ngoNameController),
              buildField("Email Address", emailController),
              buildField("Phone Number", phoneController),
              buildField("Password", passwordController, obscure: true),
              buildField("Registration Number", regNumberController),
              buildField("City / Country", cityController),

              const SizedBox(height: 10),

              /// About NGO
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About NGO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: aboutController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write about your NGO mission and work",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: submitForm,
                  child: const Text(
                    "Register NGO",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void submitForm() {

    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Submitted"),
        content: const Text(
          "Your NGO account has been submitted.\n\nPlease wait for admin approval before logging in.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}