import 'package:flutter/material.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String selectedRole = "Donor";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [

              const SizedBox(height: 30),

              // Illustration
              Image.asset(
                "assets/images/role_illustration.png",   // you can replace with your own
                height: 220,
              ),

              const SizedBox(height: 30),

              const Text(
                "Choose your role",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              const Text(
                "Select how you want to use WasteNot",
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _roleCard(
                      title: "Donor",
                      image: "assets/images/donor.png",
                      isSelected: selectedRole == "Donor",
                      onTap: () => setState(() => selectedRole = "Donor"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _roleCard(
                      title: "NGO",
                      image: "assets/images/ngo.png",
                      isSelected: selectedRole == "NGO",
                      onTap: () => setState(() => selectedRole = "NGO"),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate based on role
                    if (selectedRole == "Donor") {
                      // Navigator.push(context, ... Donor flow);
                    } else {
                      // Navigator.push(context, ... NGO flow);
                    }
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _roleCard({
    required String title,
    required String image,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2EF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F4C45) : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Image.asset(image, height: 80),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF0F4C45) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
