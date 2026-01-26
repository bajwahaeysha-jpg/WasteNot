import 'package:flutter/material.dart';
import 'package:wastenot/screens/welcome_screen.dart';

void main() {
  runApp(const WasteNotApp());
}

class WasteNotApp extends StatelessWidget {
  const WasteNotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'WasteNot',
  home: const WelcomeScreen(),
);

  }
}     
