import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/navigation/admin_bottom_navigation.dart';
import 'package:wastenot/features/donor/presentation/donor_navigation_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/screens/role_selection_screen.dart';
import 'package:wastenot/services/auth_service.dart';

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
  final AuthService _authService = AuthService();

  bool _obscure = true;
  bool _loading = false;

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in with your email and password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  _input(
                    label: 'Name',
                    controller: _nameController,
                    validator: (_) => null,
                  ),

                  const SizedBox(height: 16),

                  _input(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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

                  const SizedBox(height: 16),

                  _input(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscure,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoleSelectionScreen(isLogin: false),
                        ),
                      );
                    },
                    child: const Text('Need an account? Sign up'),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Shared login for donor, NGO, and admin. Name is only used for admin display.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = await _authService.signIn(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      _goToDashboard(user);
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

  void _goToDashboard(AppUserModel user) {
    final route = user.isAdmin
        ? MaterialPageRoute(
            builder: (_) => AdminBottomNavigation(
              user: user.toNavigationUser(),
            ),
          )
        : user.isNgo
            ? MaterialPageRoute(
                builder: (_) =>
                    NgoHomeScreen(user: user.toNavigationUser()),
              )
            : MaterialPageRoute(
                builder: (_) =>
                    DonorNavigationScreen(user: user.toNavigationUser()),
              );

    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : mainGreen,
      ),
    );
  }
}