import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastenot/services/session_service.dart';

class AccountService {
  AccountService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AccountFailure(
          'Please log in again to change your password.',
        );
      }

      final email = user.email?.trim();
      if (email == null || email.isEmpty) {
        throw const AccountFailure('Email is missing for this account.');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_mapFirebaseAuthError(error));
    } catch (_) {
      throw const AccountFailure(
        'Failed to change password. Please try again.',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final sessionUser = SessionService.user;
      if (sessionUser?.isAdmin == true) {
        throw const AccountFailure('Admin accounts cannot be deleted.');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw const AccountFailure(
          'Please log in again to delete your account.',
        );
      }

      final uid = user.uid;
      await _deleteRelatedData(uid);
      await _firestore.collection('users').doc(uid).delete();
      await user.delete();
      SessionService.clear();
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(_mapFirebaseAuthError(error));
    } on FirebaseException catch (error) {
      throw AccountFailure(_mapFirebaseError(error));
    } catch (_) {
      throw const AccountFailure(
        'Failed to delete account. Please try again.',
      );
    }
  }

  Future<void> _deleteRelatedData(String uid) async {
    await Future.wait([
      _safeDeleteWhere(collection: 'donations', field: 'donorId', uid: uid),
      _safeDeleteWhere(
        collection: 'donations',
        field: 'acceptedByNgoId',
        uid: uid,
      ),
      _safeDeleteWhere(collection: 'feedback', field: 'donorId', uid: uid),
      _safeDeleteWhere(collection: 'feedback', field: 'ngoId', uid: uid),
      _safeDeleteWhere(collection: 'notifications', field: 'uid', uid: uid),
      _safeDeleteWhere(collection: 'concerns', field: 'ngoId', uid: uid),
    ]);
  }

  Future<void> _safeDeleteWhere({
    required String collection,
    required String field,
    required String uid,
  }) async {
    try {
      await _deleteWhere(collection: collection, field: field, uid: uid);
    } catch (_) {}
  }

  Future<void> _deleteWhere({
    required String collection,
    required String field,
    required String uid,
  }) async {
    final query = _firestore
        .collection(collection)
        .where(field, isEqualTo: uid)
        .limit(200);

    while (true) {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'requires-recent-login':
        return 'Please log in again before trying this action.';
      case 'user-not-found':
        return 'No account found for this user.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _mapFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is unavailable right now. Please try again.';
      case 'not-found':
        return 'Account record was not found.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}

class AccountFailure implements Exception {
  const AccountFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
