import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/screens/login_screen.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/location_service.dart';

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
  final AuthService _authService = AuthService();
  final LocationService _locationService = const LocationService();

  File? _image;
  AppLocation? _selectedLocation;
  final ImagePicker picker = ImagePicker();
  bool _obscurePassword = true;
  bool _loading = false;

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  static const primary = Color(0xFF0B4B3F);

  @override
  void dispose() {
    ngoNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    regNumberController.dispose();
    cityController.dispose();
    aboutController.dispose();
    super.dispose();
  }

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
              buildField(
                "Email Address",
                emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              buildField(
                "Phone Number",
                phoneController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^\d{10,15}$').hasMatch(value.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              buildField(
                "Password",
                passwordController,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              buildField("Registration Number", regNumberController),
              buildField(
                "City / Country",
                cityController,
                readOnly: true,
                onTap: _pickLocation,
                suffix: const Icon(Icons.map_outlined),
                validator: (_) {
                  if (_selectedLocation == null) {
                    return 'Please select your location from the map';
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
                  onPressed: _loading ? null : submitForm,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final location = await _locationService.pickLocation(
      context,
      initialLocation: _selectedLocation,
      title: 'Select NGO Location',
    );

    if (location == null || !mounted) {
      return;
    }

    setState(() {
      _selectedLocation = location;
      cityController.text = location.address;
    });
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _authService.submitNgoRequest(
        organizationName: ngoNameController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
        address: cityController.text,
        location: _selectedLocation!,
        registrationNumber: regNumberController.text,
        description: aboutController.text,
        profileImage: _image,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registration Submitted"),
          content: const Text(
            "Your NGO account has been submitted.\n\nPlease wait for admin approval before logging in.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on AuthFailure catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primary,
      ),
    );
  }
}
