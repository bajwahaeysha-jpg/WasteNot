import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/local_auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  File? profileImage;
  final ImagePicker picker = ImagePicker();

  static const mainGreen = Color(0xFF0B4B3F);
  static const sponsorBlue = Color(0xFF1E88E5);

  Future pickImage() async {

    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  void signup() async {

  if (!_formKey.currentState!.validate()) return;

  if (profileImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select profile image")),
    );
    return;
  }

  await LocalAuthService.saveUser(
    name: nameController.text.trim(),
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
    role: "Admin",
    image: profileImage?.path,
  );

  if (!mounted) return;

  /// SIGNUP KE BAAD LOGIN SCREEN
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      bottomNavigationBar: _sponsored(),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const SizedBox(height: 40),

                /// PROFILE IMAGE
                Stack(
                  children: [

                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            profileImage != null
                                ? FileImage(profileImage!)
                                : null,
                        child: profileImage == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: mainGreen,
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Register to start using WasteNot",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 30),

                _input(
                  "Full Name",
                  nameController,
                  validator: (v) =>
                      v!.isEmpty ? "Name required" : null,
                ),

                const SizedBox(height: 16),

                _input(
                  "Email",
                  emailController,
                  validator: (v) =>
                      v!.contains("@") ? null : "Enter valid email",
                ),

                const SizedBox(height: 16),

                _input(
                  "Password",
                  passwordController,
                  obscure: obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Password required";
                    }

                    if (v.length < 8) {
                      return "Minimum 8 characters";
                    }

                    if (!RegExp(r'[A-Z]').hasMatch(v)) {
                      return "Must contain uppercase letter";
                    }

                    if (!RegExp(r'[!@#$%^&*(),.?\":{}|<>]')
                        .hasMatch(v)) {
                      return "Must contain special character";
                    }

                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                        obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: signup,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );

                  },
                  child: const Text(
                    "Already have an account? Login",
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _sponsored() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Sponsored by",
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ngo3.png',
                height: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                "SOS Children’s Villages",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sponsorBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}