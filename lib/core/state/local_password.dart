import 'package:shared_preferences/shared_preferences.dart';

class LocalPassword {
  static const _key = "user_password";

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) {
      await prefs.setString(_key, "123456"); // default password
    }
  }

  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? "123456";
  }

  static Future<void> setPassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newPassword);
  }
}
