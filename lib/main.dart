import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WasteNotApp());
}

class WasteNotApp extends StatelessWidget {
  const WasteNotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WasteNot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B4B3F)),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
