import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/services/admin_registration_notification_service.dart';
import 'package:wastenot/services/fcm_service.dart';
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
  static const verifyEmailMessage = 'Please verify your email before logging in.';
  static const ngoApprovalPendingMessage =
      'Waiting for admin approval. Your NGO account will be activated after review.';
  static const ngoRejectedMessage =
      'Your registration request was rejected by admin.';
  static const suspendedMessage =
      'Your account is suspended for some reason.';

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
      emailVerified: true,
      approvedByAdmin: true,
    );
  }

  Future<AppUserModel?> currentUserProfile() async {
    final sessionUser = SessionService.user;
    if (sessionUser?.isAdmin == true) {
      return sessionUser;
    }

    if (sessionUser != null) {
      unawaited(_refreshSessionUser(sessionUser));
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

    await user.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null) {
      SessionService.clear();
      return null;
    }

    if (!refreshedUser.emailVerified) {
      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure(verifyEmailMessage);
    }

    final profile = await _firestoreService.getUserByUid(refreshedUser.uid);
    if (profile == null) {
      final ngoRequest = await _firestoreService.getNgoRequestByEmail(
        refreshedUser.email ?? '',
      );

      if (ngoRequest != null) {
        final resolvedRequest = await _resolveNgoVerificationGate(
          firebaseUser: refreshedUser,
          request: ngoRequest,
        );
        await _auth.signOut();
        SessionService.clear();
        throw AuthFailure(_messageForNgoRequestStatus(resolvedRequest.status));
      }

      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure(
        'Your account record no longer exists. Please contact support.',
      );
    }

    await _syncUserEmailVerification(firebaseUser: refreshedUser, profile: profile);

    if (profile.isNgo && !profile.approvedByAdmin) {
      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure(ngoApprovalPendingMessage);
    }

    if (profile.isSuspended) {
      await _auth.signOut();
      SessionService.clear();
      throw AuthFailure(suspendedMessage);
    }

    final refreshedProfile = profile.copyWith(emailVerified: refreshedUser.emailVerified);
    SessionService.setUser(
      refreshedProfile,
      firestoreService: _firestoreService,
    );
    await FcmService.instance.syncTokenForSignedInUser(forceRefresh: false);
    return refreshedProfile;
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

      await signedInUser.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw AuthFailure('Authentication failed. Please try again.');
      }

      if (!refreshedUser.emailVerified) {
        await _auth.signOut();
        SessionService.clear();
        throw AuthFailure(verifyEmailMessage);
      }

      final profile = await _firestoreService.getUserByUid(refreshedUser.uid);
      if (profile == null) {
        final ngoRequest =
            await _firestoreService.getNgoRequestByEmail(normalizedEmail);

        if (ngoRequest != null) {
          final resolvedRequest = await _resolveNgoVerificationGate(
            firebaseUser: refreshedUser,
            request: ngoRequest,
          );
          await _auth.signOut();
          SessionService.clear();
          throw AuthFailure(_messageForNgoRequestStatus(resolvedRequest.status));
        }

        await _auth.signOut();
        SessionService.clear();
        throw AuthFailure('Your account was deleted or is incomplete.');
      }

      await _syncUserEmailVerification(firebaseUser: refreshedUser, profile: profile);

      if (profile.isNgo && !profile.approvedByAdmin) {
        await _auth.signOut();
        SessionService.clear();
        throw AuthFailure(ngoApprovalPendingMessage);
      }

      if (profile.isSuspended) {
        await _auth.signOut();
        SessionService.clear();
        throw AuthFailure(suspendedMessage);
      }

      final refreshedProfile = profile.copyWith(emailVerified: refreshedUser.emailVerified);
      SessionService.setUser(
        refreshedProfile,
        firestoreService: _firestoreService,
      );
      await FcmService.instance.syncTokenForSignedInUser(forceRefresh: false);
      return refreshedProfile;
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

  Future<AppUserModel> registerDonor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required AppLocation location,
    required String about,
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
        folder: 'donor',
        identifier: firebaseUser.uid,
        imageFile: profileImage,
      );

      await _firestoreService.saveDonor(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: normalizedEmail,
        role: 'donor',
        phone: phone.trim(),
        address: address.trim(),
        location: location,
        about: about.trim(),
        emailVerified: firebaseUser.emailVerified,
        profileImageUrl: profileImageUrl,
      );

      await firebaseUser.sendEmailVerification();

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
        location: location,
        profileImageUrl: profileImageUrl,
        role: 'donor',
        emailVerified: firebaseUser.emailVerified,
        approvedByAdmin: true,
        createdAt: DateTime.now(),
      );

      await _auth.signOut();
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
    required AppLocation location,
    required String registrationNumber,
    required String description,
    File? profileImage,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    User? firebaseUser;

    try {
      final existingRequest =
          await _firestoreService.getNgoRequestByEmail(normalizedEmail);
      if (existingRequest != null &&
          (existingRequest.status == 'pending' ||
              existingRequest.status == 'email_verification_pending')) {
        throw AuthFailure(
          existingRequest.status == 'pending'
              ? ngoApprovalPendingMessage
              : verifyEmailMessage,
        );
      }

      final existingUser = await _firestoreService.getUserByEmail(normalizedEmail);
      if (existingUser != null || normalizedEmail == adminEmail) {
        throw AuthFailure('This email is already in use.');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('NGO registration failed. Please try again.');
      }

      final profileImageUrl = await _firestoreService.uploadProfileImage(
        folder: 'ngo_requests',
        identifier: firebaseUser.uid,
        imageFile: profileImage,
      );

      await _firestoreService.submitNgoRequest(
        uid: firebaseUser.uid,
        organizationName: organizationName.trim(),
        email: normalizedEmail,
        password: password,
        phone: phone.trim(),
        address: address.trim(),
        location: location,
        registrationNumber: registrationNumber.trim(),
        description: description.trim(),
        profileImageUrl: profileImageUrl,
      );

      await firebaseUser.sendEmailVerification();
      await _auth.signOut();
      SessionService.clear();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseAuthError(error));
    } on FirebaseException catch (error) {
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
        } catch (_) {}
      }
      throw AuthFailure(_mapFirebaseError(error));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<AppUserModel> updateCurrentUserProfile({
    required String email,
    String? name,
    String? phone,
    String? address,
    AppLocation? location,
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

    if (location != null) {
      data['location'] = locationToFirestore(location);
      data.addAll(flatLocationFields(location));
      data['address'] = location.address.trim();
    }

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
    return updatedUser;
  }

  Future<void> signOut() async {
    await FcmService.instance.unregisterCurrentDevice();
    await _auth.signOut();
    SessionService.clear();
  }

  Future<void> logout() => signOut();

  Future<AppUserModel?> checkUserSession() => currentUserProfile();

  Future<void> _refreshSessionUser(AppUserModel sessionUser) async {
    if (sessionUser.isAdmin) {
      return;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != sessionUser.uid) {
      return;
    }

    try {
      await firebaseUser.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        return;
      }

      final profile = await _firestoreService.getUserByUid(sessionUser.uid);
      if (profile == null || profile.isSuspended) {
        await signOut();
        return;
      }

      SessionService.setUser(
        profile.copyWith(emailVerified: refreshedUser.emailVerified),
        firestoreService: _firestoreService,
      );
    } catch (_) {}
  }

  Future<void> resendPendingVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure('No authenticated user is available for verification.');
    }

    await user.reload();
    if (_auth.currentUser?.emailVerified == true) {
      throw AuthFailure('This email is already verified.');
    }

    await user.sendEmailVerification();
  }

  Future<void> resendVerificationEmailForCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthFailure('Authentication failed. Please try again.');
      }

      await user.reload();
      if (_auth.currentUser?.emailVerified == true) {
        throw AuthFailure('This email is already verified.');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_mapFirebaseAuthError(error));
    } finally {
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      SessionService.clear();
    }
  }

  Future<void> deleteCurrentAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final uid = currentUser.uid;

    try {
      await FcmService.instance.unregisterCurrentDevice();
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
      case 'email_verification_pending':
        return verifyEmailMessage;
      case 'pending':
        return ngoApprovalPendingMessage;
      case 'rejected':
        return ngoRejectedMessage;
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

  Future<void> _syncUserEmailVerification({
    required User firebaseUser,
    AppUserModel? profile,
  }) async {
    if (profile != null && profile.emailVerified == firebaseUser.emailVerified) {
      return;
    }

    await _firestoreService.syncUserEmailVerification(
      uid: firebaseUser.uid,
      emailVerified: firebaseUser.emailVerified,
    );
  }

  Future<NgoRequestModel> _resolveNgoVerificationGate({
    required User firebaseUser,
    required NgoRequestModel request,
  }) async {
    if (!firebaseUser.emailVerified) {
      return request;
    }

    if (request.status == 'email_verification_pending') {
      final updatedRequest =
          await _firestoreService.markNgoRequestEmailVerified(request);
      await AdminRegistrationNotificationService().createNgoRegistered(
        email: updatedRequest.email,
        organizationName: updatedRequest.organizationName,
      );
      return updatedRequest;
    }

    return request;
  }
}

class AuthFailure implements Exception {
  AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
