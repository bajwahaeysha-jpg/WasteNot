import 'package:flutter/material.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/ngo_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 40),
              const Text("Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

              const SizedBox(height: 30),

              const Text("Email"),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: "abc@gmail.com",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              const Text("Password"),
              const SizedBox(height: 6),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "********",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text("Remember me"),
                  const Spacer(),
                  const Text("Forgot password?",
                      style: TextStyle(color: Colors.teal)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const NgoHomeScreen()),
                    );
                  },
                  child: const Text("Login",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
