import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {

  /// KEY jahan user data save hoga
  static const String userKey = "user_data";

  /// SIGNUP - USER SAVE
  static Future<void> saveUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? image,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> user = {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "image": image,
    };

    await prefs.setString(userKey, jsonEncode(user));
  }

  /// USER DATA GET KARNA
  static Future<Map<String, dynamic>?> getUser() async {

    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString(userKey);

    if (data == null) return null;

    return jsonDecode(data);
  }

  /// LOGIN CHECK
  static Future<bool> isLoggedIn() async {

    final user = await getUser();

    return user != null;
  }

  /// LOGOUT
  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
  }

  /// DELETE ACCOUNT
  static Future<void> deleteAccount() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}