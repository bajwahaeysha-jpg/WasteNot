import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastenot/models/app_user_model.dart';
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

  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

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
    final sessionUser = SessionService.user;
    if (sessionUser?.isAdmin == true) {
      return sessionUser;
    }

    final user = _auth.currentUser;
    if (user == null) {
      SessionService.clear();
      return null;
    }

    if (user.email?.toLowerCase() == adminEmail) {
      final admin = _adminUser();
      SessionService.setUser(admin, syncFromFirestore: false);
      return admin;
    }

    final profile = await _firestoreService.getUserByUid(user.uid);
    if (profile == null) {
      await _auth.signOut();
      final ngoRequest =
          await _firestoreService.getNgoRequestByEmail(user.email ?? '');

      if (ngoRequest != null) {
        throw AuthFailure(_messageForNgoRequestStatus(ngoRequest.status));
      }

      throw AuthFailure(
        'Your account record no longer exists. Please contact support.',
      );
    }

    if (profile.isNgo && !profile.approvedByAdmin) {
      await _auth.signOut();
      throw AuthFailure('Your NGO request is still pending admin approval.');
    }

    SessionService.setUser(profile, firestoreService: _firestoreService);
    return profile;
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
    String? name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      if (normalizedEmail == adminEmail && password == adminPassword) {
        final admin = _adminUser(name);
        SessionService.setUser(admin, syncFromFirestore: false);
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

      final profile = await _firestoreService.getUserByUid(signedInUser.uid);
      if (profile == null) {
        await _auth.signOut();
        final ngoRequest =
            await _firestoreService.getNgoRequestByEmail(normalizedEmail);

        if (ngoRequest != null) {
          throw AuthFailure(_messageForNgoRequestStatus(ngoRequest.status));
        }

        throw AuthFailure('Your account was deleted or is incomplete.');
      }

      if (profile.isNgo && !profile.approvedByAdmin) {
        await _auth.signOut();
        throw AuthFailure('Your NGO request is still pending admin approval.');
      }

      SessionService.setUser(profile, firestoreService: _firestoreService);
      return profile;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'invalid-credential') {
        final ngoRequest =
            await _firestoreService.getNgoRequestByEmail(normalizedEmail);

        if (ngoRequest != null) {
          throw AuthFailure(_messageForNgoRequestStatus(ngoRequest.status));
        }
      }

      throw AuthFailure(_mapFirebaseAuthError(error));
    }
  }

  Future<AppUserModel> registerDonor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    File? profileImage,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('Donor registration failed. Please try again.');
      }
      final profileImageUrl = await _firestoreService.uploadProfileImage(
        folder: 'users',
        identifier: firebaseUser.uid,
        imageFile: profileImage,
      );

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
        profileImageUrl: profileImageUrl,
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
      SessionService.clear();
      return profile;
    } on FirebaseAuthException catch (error) {
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
      throw AuthFailure(
        'An NGO request with this email is already pending approval.',
      );
    }

    final existingUser = await _firestoreService.getUserByEmail(normalizedEmail);
    if (existingUser != null || normalizedEmail == adminEmail) {
      throw AuthFailure('This email is already in use.');
    }

    final profileImageUrl = await _firestoreService.uploadProfileImage(
      folder: 'ngo_requests',
      identifier: normalizedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
      imageFile: profileImage,
    );

    await _firestoreService.submitNgoRequest(
      organizationName: organizationName.trim(),
      email: normalizedEmail,
      password: password,
      phone: phone.trim(),
      address: address.trim(),
      registrationNumber: registrationNumber.trim(),
      description: description.trim(),
      profileImageUrl: profileImageUrl,
    );
  }

  Future<AppUserModel> updateCurrentUserProfile({
    required String email,
    String? name,
    String? phone,
    String? address,
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
    return updatedUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    SessionService.clear();
  }

  Future<AppUserModel> updateCurrentUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    File? profileImage,
  }) async {
    final currentUser = _auth.currentUser;
    final sessionUser = SessionService.user;

    if (currentUser == null || sessionUser == null) {
      throw AuthFailure('Please login again to update your profile.');
    }

    try {
      String? profileImageUrl = sessionUser.profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await _firestoreService.uploadProfileImage(
          folder: 'users',
          identifier: currentUser.uid,
          imageFile: profileImage,
        );
      }

      await _firestoreService.updateUserProfile(
        uid: currentUser.uid,
        name: name?.trim(),
        email: email?.trim().toLowerCase(),
        phone: phone?.trim(),
        address: address?.trim(),
        profileImageUrl: profileImageUrl,
      );

      final refreshed = await _firestoreService.getUserByUid(currentUser.uid);
      if (refreshed == null) {
        throw AuthFailure('Could not refresh profile. Please login again.');
      }

      SessionService.setUser(refreshed);
      return refreshed;
    } on FirebaseException catch (error) {
      throw AuthFailure(_mapFirebaseError(error));
    }
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
        return 'No account found for this email.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _messageForNgoRequestStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Your NGO request is still pending admin approval.';
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
}

class AuthFailure implements Exception {
  AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
