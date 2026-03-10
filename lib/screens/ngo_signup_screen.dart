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
        backgroundColor: primary,
        title: const Text(
          "NGO Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  backgroundColor: primary.withOpacity(0.1),
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

              buildField(
                "NGO Name",
                ngoNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "NGO name is required";
                  }
                  return null;
                },
              ),

              buildField(
                "Email Address",
                emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }

                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                  if (!emailRegex.hasMatch(value)) {
                    return "Enter valid email";
                  }

                  return null;
                },
              ),

              buildField(
                "Phone Number",
                phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number required";
                  }

                  final phoneRegex = RegExp(r'^\d{11}$');

                  if (!phoneRegex.hasMatch(value)) {
                    return "Phone must be 11 digits";
                  }

                  return null;
                },
              ),

              buildField(
                "Password",
                passwordController,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password required";
                  }

                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }

                  final specialRegex =
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]');

                  if (!specialRegex.hasMatch(value)) {
                    return "Password must contain special character";
                  }

                  return null;
                },
              ),

              buildField(
                "Registration Number",
                regNumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Registration number required";
                  }
                  return null;
                },
              ),

              buildField(
                "City / Country",
                cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "City required";
                  }
                  return null;
                },
              ),

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please describe your NGO";
                  }
                  return null;
                },
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
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