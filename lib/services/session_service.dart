import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wastenot/core/state/app_user.dart';
import 'package:wastenot/models/app_user_model.dart';

class SessionService {
  static final ValueNotifier<AppUserModel?> currentUser =
      ValueNotifier<AppUserModel?>(null);

  static AppUserModel? get user => currentUser.value;

  static void setUser(AppUserModel? user) {
    currentUser.value = user;

    if (user == null) {
      return;
    }

    AppUser.update(
      newName: user.displayName,
      newEmail: user.email,
      newPhone: user.phone,
      newImage: null,
    );
  }

  static void clear() {
    currentUser.value = null;
    AppUser.clear();
  }

  static String initials([String fallback = 'WN']) {
    final source = user?.displayName.trim();
    if (source == null || source.isEmpty) {
      return fallback;
    }

    final parts = source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part[0]).join().toUpperCase();
    return letters.isEmpty ? fallback : letters;
  }

  static File? get localImageFile => null;
}
