class AuthSessionCache {
  const AuthSessionCache({
    required this.isLoggedIn,
    this.uid,
    this.role,
  });

  final bool isLoggedIn;
  final String? uid;
  final String? role;

  bool get hasUser => (uid?.trim().isNotEmpty ?? false);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isLoggedIn': isLoggedIn,
      'uid': uid,
      'role': role,
    };
  }

  factory AuthSessionCache.fromJson(Map<String, dynamic> json) {
    return AuthSessionCache(
      isLoggedIn: json['isLoggedIn'] == true,
      uid: json['uid']?.toString(),
      role: json['role']?.toString(),
    );
  }
}
