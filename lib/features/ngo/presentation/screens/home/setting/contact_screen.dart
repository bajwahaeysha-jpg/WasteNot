import 'package:flutter/material.dart';
import 'package:wastenot/features/shared/presentation/screens/contact_form_screen.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContactFormScreen(role: 'ngo');
  }
}
