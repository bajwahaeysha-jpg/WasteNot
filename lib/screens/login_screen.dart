import 'package:flutter/material.dart';
import 'admin_signup_screen.dart';
import 'package:wastenot/features/admin/navigation/admin_bottom_navigation.dart';
import 'package:wastenot/features/donor/presentation/donor_navigation_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import '../../services/local_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  String? _error;

  static const Color mainGreen = Color(0xFF0B4B3F);
  static const Color sponsorBlue = Color(0xFF1E88E5);

 void _login(String role) async {

  if (!_formKey.currentState!.validate()) return;

  final user = await LocalAuthService.getUser();

  /// USER NAHI HAI
  if (user == null) {
    setState(() {
      _error = "Please sign up first";
    });
    return;
  }

  /// MATCH CHECK
  if (user['name'] != _nameController.text.trim() ||
      user['email'] != _emailController.text.trim() ||
      user['password'] != _passwordController.text.trim()) {

    setState(() {
      _error = "Name, Email or Password does not match";
    });
    return;
  }

  /// LOGIN SUCCESS
  if (role == 'Admin') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBottomNavigation(user: user),
      ),
    );
  }

  if (role == 'Donor') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DonorNavigationScreen(user: user),
      ),
    );
  }

  if (role == 'NGO') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NgoHomeScreen(user: user),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    /// SAFE ROLE FIX
    final String role =
        ModalRoute.of(context)?.settings.arguments as String? ?? "Admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _sponsored(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 40),

                /// HEADER
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Sign in to continue",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// NAME
                _input(
                  "Full Name",
                  _nameController,
                  validator: (v) =>
                      v!.isEmpty ? "Name required" : null,
                ),

                const SizedBox(height: 16),

                /// EMAIL
                _input(
                  "Email",
                  _emailController,
                  validator: (v) =>
                      v!.contains("@") ? null : "Enter valid email",
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                _input(
                  "Password",
                  _passwordController,
                  obscure: _obscure,
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

                    if (!RegExp(r'[!@#$%^&*(),.?\":{}|<>]').hasMatch(v)) {
                      return "Must contain special character";
                    }

                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Password must contain 8+ characters, one uppercase letter and one special character.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                /// LOGIN BUTTON
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => _login(role),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// SIGN UP BUTTON
                Center(
                  child: TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );

                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                    ),
                  ),
                ),

                const SizedBox(height: 100),
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
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/ngo3.png', height: 22),
              const SizedBox(width: 8),
              const Text(
                "SOS Children’s Villages",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sponsorBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}