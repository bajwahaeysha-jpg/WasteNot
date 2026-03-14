import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wastenot/core/state/app_user.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/firestore_service.dart';

class SessionService {
  static final ValueNotifier<AppUserModel?> currentUser =
      ValueNotifier<AppUserModel?>(null);
  static StreamSubscription<AppUserModel?>? _userSubscription;
  static String? _syncedUid;

  static AppUserModel? get user => currentUser.value;

  static void setUser(
    AppUserModel? user, {
    FirestoreService? firestoreService,
    bool syncFromFirestore = true,
  }) {
    _applyUser(user);

    if (user == null || user.isAdmin || !syncFromFirestore) {
      _stopSync();
      return;
    }

    if (_syncedUid == user.uid) {
      return;
    }

    _stopSync();
    _syncedUid = user.uid;
    final service = firestoreService ?? FirestoreService();
    _userSubscription = service.userStream(user.uid).listen(_applyUser);
  }

  static void _applyUser(AppUserModel? user) {
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

  static void _stopSync() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _syncedUid = null;
  }

  static void clear() {
    _stopSync();
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
