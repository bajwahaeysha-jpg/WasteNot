import 'package:flutter/material.dart';
import 'package:wastenot/features/shared/presentation/screens/contact_form_screen.dart';

class DonorContactScreen extends StatelessWidget {
  const DonorContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContactFormScreen(role: 'donor');
  }
}
