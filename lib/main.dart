import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastenot/screens/splash_screen.dart';
import 'package:wastenot/services/fcm_service.dart';
import 'package:wastenot/services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await SessionService.restorePersistedUser();
  runApp(const WasteNotApp());
  unawaited(FcmService.instance.initialize());
}

class WasteNotApp extends StatelessWidget {
  const WasteNotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WasteNot',
      navigatorKey: FcmService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B4B3F)),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
