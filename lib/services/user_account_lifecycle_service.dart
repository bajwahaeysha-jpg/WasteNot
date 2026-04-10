import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastenot/services/fcm_service.dart';

class UserAccountLifecycleService {
  UserAccountLifecycleService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  Future<void> deleteOwnAccount() async {
    try {
      await FcmService.instance.unregisterCurrentDevice();
      await _functions.httpsCallable('selfDeleteUserAccount').call();
      await _auth.signOut();
    } on FirebaseFunctionsException catch (error) {
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
}

class UserAccountLifecycleFailure implements Exception {
  const UserAccountLifecycleFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
