import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/state/local_password.dart';
import 'features/role/select_role_screen.dart';

import 'features/splash/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/role/select_role_screen.dart';
import 'features/ngo/presentation/screens/home/ngo_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalPassword.init();
  runApp(const WasteNotApp());
}

class WasteNotApp extends StatelessWidget {
  const WasteNotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WasteNot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // 🚦 App now starts correctly
home: const SelectRoleScreen(),
    );
  }
}
