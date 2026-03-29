import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/admin_registration_notification_service.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirestoreService? firestoreService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  static const adminEmail = 'wastenotapplication@gmail.com';
  static const adminPassword = 'WasteNot@123';
  static const _isLoggedInKey = 'auth_is_logged_in';
  static const _uidKey = 'auth_uid';
  static const _roleKey = 'auth_role';
  static const _emailKey = 'auth_email';
  static const _displayNameKey = 'auth_display_name';

  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;
  String? _pendingVerificationEmail;
  String? _pendingVerificationPassword;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  AppUserModel _adminUser([String? displayName]) {
    return AppUserModel(
      uid: 'admin',
      email: adminEmail,
      role: 'admin',
      createdAt: DateTime(2026, 3, 12),
      name: (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : 'System Admin',
      approvedByAdmin: true,
    );
  }

  Future<AppUserModel?> currentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      SessionService.clear();
      return null;
    }

    return _resolveFirebaseSession(user);
  }

  Future<AppUserModel> login({
    required String email,
    required String password,
    String? name,
  }) {
    return signIn(
      email: email,
      password: password,
      name: name,
    );
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
    String? name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      if (normalizedEmail == adminEmail && password == adminPassword) {
        _clearPendingVerificationState();
        final admin = _adminUser(name);
        SessionService.setUser(admin, syncFromFirestore: false);
        await _persistSession(admin);
        return admin;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final signedInUser = credential.user;
      if (signedInUser == null) {
        throw AuthFailure('Authentication failed. Please try again.');
      }
      await signedInUser.reload();
      final refreshedUser = _auth.currentUser ?? signedInUser;

      if (!refreshedUser.emailVerified) {
        _pendingVerificationEmail = normalizedEmail;
        _pendingVerificationPassword = password;
        await _auth.signOut();
        throw AuthFailure('Please verify your email from your mailbox.');
      }

      _clearPendingVerificationState();
      return _resolveFirebaseSession(refreshedUser);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        throw AuthFailure(
          'Account not found. Please create an account first.',
        );
      }

      throw AuthFailure(_mapFirebaseAuthError(error));
    }
  }

  Future<AppUserModel?> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final storedRole = prefs.getString(_roleKey);
    final storedDisplayName = prefs.getString(_displayNameKey);
    final firebaseUser = _auth.currentUser;

    if (!isLoggedIn) {
      if (firebaseUser != null) {
        await _auth.signOut();
      }
      SessionService.clear();
      return null;
    }

    if (firebaseUser != null) {
      try {
        return await _resolveFirebaseSession(firebaseUser);
      } on AuthFailure {
        await signOut();
        return null;
      }
    }

    if (storedRole == 'admin') {
      final admin = _adminUser(storedDisplayName);
      SessionService.setUser(admin, syncFromFirestore: false);
      await _persistSession(admin);
      return admin;
    }

    await _clearPersistedSession();
    SessionService.clear();
    return null;
  }

  Future<AppUserModel> registerDonor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String about,
    File? profileImage,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('Donor registration failed. Please try again.');
      }
      await _sendVerificationEmailWithRetry(firebaseUser);

      final profileImageUrl = await _firestoreService.uploadProfileImage(
        folder: 'donor',
        identifier: firebaseUser.uid,
        imageFile: profileImage,
      );

      await _firestoreService.saveDonor(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: normalizedEmail,
        phone: phone.trim(),
        address: address.trim(),
        about: about.trim(),
        profileImageUrl: profileImageUrl,
      );

      await AdminRegistrationNotificationService().createDonorRegistered(
        uid: firebaseUser.uid,
        name: name.trim(),
      );

      final profile = AppUserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: normalizedEmail,
        phone: phone.trim(),
        address: address.trim(),
        profileImageUrl: profileImageUrl,
        role: 'donor',
        approvedByAdmin: true,
        createdAt: DateTime.now(),
      );

      unawaited(_auth.signOut());
      _clearPendingVerificationState();
      SessionService.clear();
      await _clearPersistedSession();
      return profile;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        await _handleExistingUnverifiedAccount(
          email: normalizedEmail,
          password: password,
        );
      }
      throw AuthFailure(_mapFirebaseAuthError(error));
    } on FirebaseException catch (error) {
      throw AuthFailure(_mapFirebaseError(error));
    }
  }

  Future<void> submitNgoRequest({
    required String organizationName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String registrationNumber,
    required String description,
    File? profileImage,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingRequest =
        await _firestoreService.getNgoRequestByEmail(normalizedEmail);

    if (existingRequest != null && existingRequest.status == 'pending') {
      await _resendVerificationForExistingAccountIfPossible(
        email: normalizedEmail,
        password: password,
      );
      throw AuthFailure(
        'An NGO request with this email is already pending approval.',
      );
    }

    final existingUser = await _firestoreService.getUserByEmail(normalizedEmail);
    if (existingUser != null || normalizedEmail == adminEmail) {
      if (normalizedEmail != adminEmail) {
        await _resendVerificationForExistingAccountIfPossible(
          email: normalizedEmail,
          password: password,
        );
      }
      throw AuthFailure('This email is already in use.');
    }

    final profileImageUrl = await _firestoreService.uploadProfileImage(
      folder: 'ngo_requests',
      identifier: normalizedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
      imageFile: profileImage,
    );

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('NGO registration failed. Please try again.');
      }

      final createdRequest = await _ensureNgoRequestExists(
        email: normalizedEmail,
        organizationName: organizationName.trim(),
        password: password,
        phone: phone.trim(),
        address: address.trim(),
        registrationNumber: registrationNumber.trim(),
        description: description.trim(),
        profileImageUrl: profileImageUrl,
      );

      if (createdRequest) {
        await AdminRegistrationNotificationService().createNgoRegistered(
          email: normalizedEmail,
          organizationName: organizationName.trim(),
        );
      }

      await _sendVerificationEmailWithRetry(firebaseUser);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        await _handleExistingNgoAuthAccount(
          email: normalizedEmail,
          password: password,
          organizationName: organizationName.trim(),
          phone: phone.trim(),
          address: address.trim(),
          registrationNumber: registrationNumber.trim(),
          description: description.trim(),
          profileImageUrl: profileImageUrl,
        );
      }
      throw AuthFailure(_mapFirebaseAuthError(error));
    } on FirebaseException catch (error) {
      throw AuthFailure(_mapFirebaseError(error));
    } catch (_) {
      rethrow;
    } finally {
      await _auth.signOut();
      _clearPendingVerificationState();
      SessionService.clear();
      await _clearPersistedSession();
    }
  }

  Future<void> resendPendingVerificationEmail() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _sendVerificationEmailWithRetry(currentUser);
      return;
    }

    final email = _pendingVerificationEmail;
    final password = _pendingVerificationPassword;
    if (email == null || password == null) {
      throw AuthFailure('Unable to resend verification email. Please try again.');
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final signedInUser = _auth.currentUser;
      if (signedInUser == null) {
        throw AuthFailure('Failed to send verification email. Try again.');
      }

      await _sendVerificationEmailWithRetry(signedInUser);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseAuthError(error));
    } finally {
      await _auth.signOut();
    }
  }

  Future<AppUserModel> updateCurrentUserProfile({
    required String email,
    String? name,
    String? phone,
    String? address,
    String? about,
    String? organizationName,
    String? registrationNumber,
    String? organizationDescription,
    File? profileImage,
  }) async {
    final sessionUser = SessionService.user;
    final firebaseUser = _auth.currentUser;
    if (sessionUser == null || firebaseUser == null) {
      throw AuthFailure('Please log in again to update your profile.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != firebaseUser.email?.toLowerCase()) {
      await firebaseUser.updateEmail(normalizedEmail);
    }

    final profileImageUrl = profileImage == null
        ? sessionUser.profileImageUrl
        : await _firestoreService.uploadProfileImage(
            folder: sessionUser.role,
            identifier: sessionUser.uid,
            imageFile: profileImage,
          );

    final data = <String, dynamic>{
      'email': normalizedEmail,
      'phone': phone?.trim(),
      'address': address?.trim(),
      'profileImageUrl': profileImageUrl,
    };

    if (sessionUser.isDonor) {
      data['name'] = name?.trim();
      data['about'] = about?.trim();
    }

    if (sessionUser.isNgo) {
      data['organizationName'] = organizationName?.trim();
      data['registrationNumber'] = registrationNumber?.trim();
      data['organizationDescription'] = organizationDescription?.trim();
    }

    final updatedUser = await _firestoreService.updateUserDocument(
      uid: sessionUser.uid,
      data: data,
    );

    SessionService.setUser(updatedUser, firestoreService: _firestoreService);
    await _persistSession(updatedUser);
    return updatedUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _clearPendingVerificationState();
    await _clearPersistedSession();
    SessionService.clear();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> deleteCurrentAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final uid = currentUser.uid;

    try {
      await currentUser.delete();
      await _firestoreService.deleteUserDocument(uid);
      await _clearPersistedSession();
      SessionService.clear();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw AuthFailure(
          'Please log in again before deleting your account.',
        );
      }

      throw AuthFailure(_mapFirebaseAuthError(error));
    }
  }

  Future<AppUserModel> _resolveFirebaseSession(User user) async {
    await user.reload();
    final refreshedUser = _auth.currentUser ?? user;
    if (!refreshedUser.emailVerified) {
      await _auth.signOut();
      throw AuthFailure('Please verify your email from your mailbox.');
    }

    final rawData = await _firestoreService.getUserDataByUid(refreshedUser.uid);
    if (rawData == null) {
      final requestCreated = await _ensureNgoRequestExists(
        email: refreshedUser.email ?? '',
        organizationName: _organizationNameForAuthUser(refreshedUser),
      );

      if (requestCreated) {
        await AdminRegistrationNotificationService().createNgoRegistered(
          email: refreshedUser.email ?? '',
          organizationName: _organizationNameForAuthUser(refreshedUser),
        );
      }

      await _auth.signOut();
      final ngoRequest =
          await _firestoreService.getNgoRequestByEmail(refreshedUser.email ?? '');

      if (ngoRequest != null) {
        throw AuthFailure(_messageForNgoRequestStatus(ngoRequest.status));
      }

      throw AuthFailure(
        'Your account record no longer exists. Please contact support.',
      );
    }

    final role = (rawData['role'] as String?)?.trim().toLowerCase();
    if (role == null || role.isEmpty) {
      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure('Your account role is missing. Please log in again.');
    }

    final profile = await _firestoreService.getUserByUid(refreshedUser.uid);
    if (profile == null) {
      await _auth.signOut();
      throw AuthFailure('Your account was deleted or is incomplete.');
    }

    if (profile.isNgo && !profile.approvedByAdmin) {
      await _auth.signOut();
      throw AuthFailure('Please wait for approval from admin.');
    }

    if (profile.isSuspended) {
      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure('Your account is suspended. Please contact support.');
    }

    SessionService.setUser(profile, firestoreService: _firestoreService);
    await _persistSession(profile);
    return profile;
  }

  Future<void> _persistSession(AppUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_uidKey, user.uid);
    await prefs.setString(_roleKey, user.role);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_displayNameKey, user.displayName);
  }

  Future<void> _clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_displayNameKey);
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'Account not found. Please create an account first.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _messageForNgoRequestStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Please wait for approval from admin.';
      case 'rejected':
        return 'Your registration request was rejected by admin.';
      default:
        return 'Your NGO account is not active yet.';
    }
  }

  String _mapFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase permission denied. Check Firestore rules.';
      case 'unavailable':
        return 'Firebase service is unavailable right now. Try again.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  Future<void> _sendVerificationEmailWithRetry(User user) async {
    FirebaseAuthException? lastAuthError;
    Object? lastError;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await user.reload();
        final refreshedUser = _auth.currentUser ?? user;
        if (refreshedUser.emailVerified) {
          return;
        }

        await refreshedUser.sendEmailVerification();
        return;
      } on FirebaseAuthException catch (error) {
        lastAuthError = error;
        lastError = error;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastAuthError != null) {
      throw AuthFailure('Failed to send verification email. Try again.');
    }

    throw AuthFailure('Failed to send verification email. Try again.');
  }

  Future<void> _handleExistingUnverifiedAccount({
    required String email,
    required String password,
  }) async {
    final user = await _signInAndReloadForVerification(
      email: email,
      password: password,
    );

    if (user == null) {
      return;
    }

    if (user.emailVerified) {
      await _auth.signOut();
      return;
    }

    _pendingVerificationEmail = email;
    _pendingVerificationPassword = password;

    try {
      await _sendVerificationEmailWithRetry(user);
    } finally {
      await _auth.signOut();
    }

    throw AuthFailure('Please verify your email from your mailbox.');
  }

  Future<void> _handleExistingNgoAuthAccount({
    required String email,
    required String password,
    required String organizationName,
    required String phone,
    required String address,
    required String registrationNumber,
    required String description,
    String? profileImageUrl,
  }) async {
    final user = await _signInAndReloadForVerification(
      email: email,
      password: password,
    );

    if (user == null) {
      return;
    }

    if (!user.emailVerified) {
      _pendingVerificationEmail = email;
      _pendingVerificationPassword = password;

      try {
        await _sendVerificationEmailWithRetry(user);
      } finally {
        await _auth.signOut();
      }

      throw AuthFailure('Please verify your email from your mailbox.');
    }

    final requestCreated = await _ensureNgoRequestExists(
      email: email,
      organizationName: organizationName,
      password: password,
      phone: phone,
      address: address,
      registrationNumber: registrationNumber,
      description: description,
      profileImageUrl: profileImageUrl,
    );

    if (requestCreated) {
      await AdminRegistrationNotificationService().createNgoRegistered(
        email: email,
        organizationName: organizationName,
      );
    }

    await _auth.signOut();
    throw AuthFailure('Please wait for approval from admin.');
  }

  Future<void> _resendVerificationForExistingAccountIfPossible({
    required String email,
    required String password,
  }) async {
    final user = await _signInAndReloadForVerification(
      email: email,
      password: password,
    );

    if (user == null) {
      return;
    }

    if (!user.emailVerified) {
      _pendingVerificationEmail = email;
      _pendingVerificationPassword = password;

      try {
        await _sendVerificationEmailWithRetry(user);
      } finally {
        await _auth.signOut();
      }
    } else {
      await _auth.signOut();
    }
  }

  Future<User?> _signInAndReloadForVerification({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final signedInUser = credential.user;
      if (signedInUser == null) {
        await _auth.signOut();
        return null;
      }

      await signedInUser.reload();
      return _auth.currentUser ?? signedInUser;
    } on FirebaseAuthException {
      await _auth.signOut();
      return null;
    }
  }

  void _clearPendingVerificationState() {
    _pendingVerificationEmail = null;
    _pendingVerificationPassword = null;
  }

  Future<bool> _ensureNgoRequestExists({
    required String email,
    required String organizationName,
    String? password,
    String? phone,
    String? address,
    String? registrationNumber,
    String? description,
    String? profileImageUrl,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || normalizedEmail == adminEmail) {
      return false;
    }

    final existingUser = await _firestoreService.getUserByEmail(normalizedEmail);
    if (existingUser != null) {
      return false;
    }

    return _firestoreService.ensureNgoRequestExists(
      email: normalizedEmail,
      organizationName: organizationName,
      password: password,
      phone: phone,
      address: address,
      registrationNumber: registrationNumber,
      description: description,
      profileImageUrl: profileImageUrl,
    );
  }

  String _organizationNameForAuthUser(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim().toLowerCase() ?? '';
    final localPart = email.split('@').first.trim();
    if (localPart.isNotEmpty) {
      return localPart;
    }

    return 'NGO';
  }
}

class AuthFailure implements Exception {
  AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
