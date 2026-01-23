import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/local_auth_service.dart';
import '../admin/navigation/admin_bottom_navigation.dart';

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
  static const Color sponsorBlue = Color(0xFF1E88E5); // 🔵 SOS text color

  void _login(String role) async {
    if (!_formKey.currentState!.validate()) return;

    final user = await LocalAuthService.getUser();

    if (user == null ||
        user['email'] != _emailController.text.trim() ||
        user['password'] != _passwordController.text.trim()) {
      setState(() => _error = "Invalid email or password");
      return;
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBottomNavigation(
          user: {
            'name': _nameController.text.trim(),
            'role': role,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final role = args?['role'] ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      resizeToAvoidBottomInset: false,

      /// 🔽 SPONSORED FIXED BOTTOM
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

                /// 👋 HEADER
                Center(
                  child: Column(
                    children: const [
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

                _input(
                  "Full Name",
                  _nameController,
                  validator: (v) => v!.isEmpty ? "Name required" : null,
                ),

                const SizedBox(height: 16),

                _input(
                  "Email",
                  _emailController,
                  validator: (v) =>
                      v!.contains("@") ? null : "Enter valid email",
                ),

                const SizedBox(height: 16),

                _input(
                  "Password",
                  _passwordController,
                  obscure: _obscure,
                  validator: (v) =>
                      v!.length < 8 ? "Minimum 8 characters" : null,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
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

                /// 🔐 LOGIN BUTTON (BOLD TEXT)
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => _login(role),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600, // ✅ BOLD
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.signup),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(fontSize: 14),
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

  /// 🔹 INPUT FIELD
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

  /// 🟦 SPONSORED (SOS LOGO STYLE TEXT)
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
                    fontSize: 11,
                    color: Colors.grey,
                  ),
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
                  color: sponsorBlue, // 🔵 logo-style blue
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
