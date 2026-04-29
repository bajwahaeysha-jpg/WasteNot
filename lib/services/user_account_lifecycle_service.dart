import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastenot/services/fcm_service.dart';
import 'package:wastenot/services/firestore_service.dart';

class UserAccountLifecycleService {
  UserAccountLifecycleService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    FirestoreService? firestoreService,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1'),
        _auth = auth ?? FirebaseAuth.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  Future<void> deleteOwnAccount({
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const UserAccountLifecycleFailure(
        'Please log in again to delete your account.',
      );
    }

    final email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw const UserAccountLifecycleFailure(
        'Email is missing for this account.',
      );
    }

    final trimmedPassword = currentPassword.trim();
    if (trimmedPassword.isEmpty) {
      throw const UserAccountLifecycleFailure(
        'Current password is required to delete your account.',
      );
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final previousUserSnapshot = await userDocRef.get();
    final previousUserData = previousUserSnapshot.data() ?? const <String, dynamic>{};
    var firestoreMarkedDeleted = false;

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: trimmedPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.reload();

      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        throw const UserAccountLifecycleFailure(
          'Please log in again to delete your account.',
        );
      }

      await FcmService.instance.unregisterCurrentDevice();
      await _firestoreService.markUserAccountDeleted(uid: refreshedUser.uid);
      firestoreMarkedDeleted = true;
      await refreshedUser.delete();
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      if (firestoreMarkedDeleted) {
        await _firestoreService.restoreUserAccountState(
          uid: user.uid,
          previousData: previousUserData,
        );
      }
      throw UserAccountLifecycleFailure(_mapFirebaseAuthError(error));
    } on FirebaseException catch (error) {
      if (firestoreMarkedDeleted) {
        await _firestoreService.restoreUserAccountState(
          uid: user.uid,
          previousData: previousUserData,
        );
      }
      throw UserAccountLifecycleFailure(
        error.message ?? 'Failed to delete account. Please try again.',
      );
    }
  }

  Future<void> adminDeleteUserAccount({
    required String uid,
    required String role,
  }) async {
    try {
      await _functions.httpsCallable('adminDeleteUserAccount').call({
        'uid': uid.trim(),
        'role': role.trim().toLowerCase(),
      });
    } on FirebaseFunctionsException catch (error) {
      throw UserAccountLifecycleFailure(
        error.message ?? 'Failed to delete account. Please try again.',
      );
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'requires-recent-login':
      case 'credential-too-old-login-again':
        return 'Please log in again and retry deleting your account.';
      case 'user-not-found':
        return 'This account no longer exists.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return error.message ?? 'Failed to delete account. Please try again.';
    }
  }
}

class UserAccountLifecycleFailure implements Exception {
  const UserAccountLifecycleFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
