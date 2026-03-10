import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DonorSignupScreen extends StatefulWidget {
  const DonorSignupScreen({super.key});

  static const Color mainGreen = Color(0xFF0E5E53);

  @override
  State<DonorSignupScreen> createState() => _DonorSignupScreenState();
}

class _DonorSignupScreenState extends State<DonorSignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final ImagePicker picker = ImagePicker();
  File? logo;

  final restaurantController = TextEditingController();
  final ownerController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final foodController = TextEditingController();
  final aboutController = TextEditingController();

  Future pickLogo() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        logo = File(picked.path);
      });
    }
  }

  Widget field(
    String title,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            validator: (value) {

              if (value == null || value.isEmpty) {
                return "This field is required";
              }

              /// EMAIL VALIDATION
              if (title == "Email Address") {

                final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                if (!emailRegex.hasMatch(value)) {
                  return "Enter valid email";
                }
              }

              /// PHONE VALIDATION
              if (title == "Phone Number") {

                final phoneRegex = RegExp(r'^\d{11}$');

                if (!phoneRegex.hasMatch(value)) {
                  return "Phone must be 11 digits";
                }
              }

              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    restaurantController.dispose();
    ownerController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    foodController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),

      appBar: AppBar(
        backgroundColor: DonorSignupScreen.mainGreen,
        title: const Text(
          "Donor Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// LOGO
              Center(
                child: GestureDetector(
                  onTap: pickLogo,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        logo != null ? FileImage(logo!) : null,
                    child: logo == null
                        ? const Icon(Icons.add_a_photo, size: 28)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              field("Restaurant Name", restaurantController),

              field("Owner / Manager Name", ownerController),

              field(
                "Email Address",
                emailController,
                keyboard: TextInputType.emailAddress,
              ),

              field(
                "Phone Number",
                phoneController,
                keyboard: TextInputType.phone,
              ),

              field(
                "Restaurant Address / City",
                addressController,
              ),

              field(
                "Food Type Donated",
                foodController,
              ),

              /// ABOUT
              const Text(
                "About",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              TextFormField(
                controller: aboutController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Tell us about your restaurant...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DonorSignupScreen.mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  onPressed: () {

                    if (_formKey.currentState!.validate()) {

                      print("Restaurant: ${restaurantController.text}");
                      print("Owner: ${ownerController.text}");
                      print("Email: ${emailController.text}");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Donor account created successfully"),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}