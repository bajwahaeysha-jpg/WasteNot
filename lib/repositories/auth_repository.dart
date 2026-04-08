import 'dart:async';

import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/auth_session_cache.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/firebase/firebase_service_wrapper.dart';
import 'package:wastenot/services/local_cache_service.dart';
import 'package:wastenot/services/session_service.dart';

class AuthRepository {
  AuthRepository({
    AuthService? authService,
    LocalCacheService? cache,
    FirebaseServiceWrapper? firebaseWrapper,
  })  : _authService = authService ?? AuthService(),
        _cache = cache ?? LocalCacheService(),
        _firebaseWrapper = firebaseWrapper ?? const FirebaseServiceWrapper();

  final AuthService _authService;
  final LocalCacheService _cache;
  final FirebaseServiceWrapper _firebaseWrapper;

  Future<AppUserModel?> getCachedSessionUser() async {
    final user = await _cache.getSessionUser();
    if (user != null) {
      SessionService.setUser(user, syncFromFirestore: false);
    }
    return user;
  }

  Future<AuthSessionCache?> getCachedSessionMeta() {
    return _cache.getAuthSession();
  }

  Future<AppUserModel?> resolveStartupSession({
    Duration timeout = const Duration(seconds: 23),
  }) async {
    final cachedUser = await getCachedSessionUser();
    if (cachedUser != null) {
      unawaited(refreshSessionInBackground());
      return cachedUser;
    }

    final remoteResult = await _firebaseWrapper.execute<AppUserModel?>(
      () => _authService.checkUserSession(),
      timeout: timeout,
      operationName: 'resolveStartupSession',
    );

    final remoteUser = remoteResult.data;
    if (remoteUser != null) {
      await _persistSession(remoteUser);
      return remoteUser;
    }

    final fallbackUser = await _cache.getSessionUser();
    if (fallbackUser != null) {
      SessionService.setUser(fallbackUser, syncFromFirestore: false);
      return fallbackUser;
    }

    await clearSession();
    return null;
  }

  Future<AppUserModel?> validateSession({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final result = await _firebaseWrapper.execute<AppUserModel?>(
      () => _authService.checkUserSession(),
      timeout: timeout,
      operationName: 'validateSession',
    );

    final user = result.data;
    if (user != null) {
      await _persistSession(user);
      return user;
    }

    final cachedUser = await _cache.getSessionUser();
    if (cachedUser != null) {
      SessionService.setUser(cachedUser, syncFromFirestore: false);
      return cachedUser;
    }

    return null;
  }

  Future<void> refreshSessionInBackground({
    void Function(AppUserModel? user)? onResolved,
  }) async {
    final result = await _firebaseWrapper.execute<AppUserModel?>(
      () => _authService.checkUserSession(),
      timeout: const Duration(seconds: 3),
      operationName: 'refreshSessionInBackground',
    );

    final user = result.data;
    if (user != null) {
      await _persistSession(user);
      onResolved?.call(user);
      return;
    }

    final cachedUser = await _cache.getSessionUser();
    if (cachedUser != null) {
      SessionService.setUser(cachedUser, syncFromFirestore: false);
      onResolved?.call(cachedUser);
      return;
    }

    onResolved?.call(null);
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
    String? name,
  }) async {
    final user = await _authService.signIn(
      email: email,
      password: password,
      name: name,
    );
    await _persistSession(user);
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await clearSession();
  }

  Future<void> clearSession() async {
    SessionService.clear();
    await _cache.clearAuthSession();
  }

  Future<void> _persistSession(AppUserModel user) async {
    SessionService.setUser(user);
    await _cache.saveSessionUser(user);
    await _cache.saveAuthSession(
      AuthSessionCache(
        isLoggedIn: true,
        uid: user.uid,
        role: user.role,
      ),
    );
  }
}
