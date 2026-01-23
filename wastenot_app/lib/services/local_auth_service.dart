class LocalAuthService {
  static Map<String, dynamic>? _currentUser;

  static Future<void> saveUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _currentUser = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  static Future<Map<String, dynamic>?> getUser() async {
    return _currentUser;
  }

  // 🔐 AUTH GUARD HELP
  static Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  static Future<void> logout() async {
    _currentUser = null;
  }
}
