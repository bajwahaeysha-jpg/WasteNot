import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseServiceWrapper {
  const FirebaseServiceWrapper();

  Future<FirebaseCallResult<T>> execute<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 3),
    String operationName = 'firebase_call',
  }) async {
    try {
      final result = await operation().timeout(timeout);
      return FirebaseCallResult<T>(data: result);
    } on TimeoutException {
      return FirebaseCallResult<T>(
        errorMessage: 'Request timed out. Showing cached data.',
        isTimeout: true,
      );
    } on FirebaseAuthException catch (error) {
      return FirebaseCallResult<T>(
        errorMessage: error.message ?? 'Authentication failed.',
        code: error.code,
      );
    } on FirebaseException catch (error) {
      return FirebaseCallResult<T>(
        errorMessage: _mapFirebaseException(error),
        code: error.code,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[FirebaseServiceWrapper] $operationName failed: $error\n$stackTrace',
      );
      return FirebaseCallResult<T>(
        errorMessage: 'Unable to complete the request right now.',
      );
    }
  }

  String _mapFirebaseException(FirebaseException error) {
    switch (error.code) {
      case 'unavailable':
        return 'Service unavailable. Showing cached data.';
      case 'deadline-exceeded':
        return 'Request took too long. Showing cached data.';
      case 'permission-denied':
        return 'Permission denied.';
      default:
        return error.message ?? 'Unexpected Firebase error.';
    }
  }
}

class FirebaseCallResult<T> {
  const FirebaseCallResult({
    this.data,
    this.errorMessage,
    this.code,
    this.isTimeout = false,
  });

  final T? data;
  final String? errorMessage;
  final String? code;
  final bool isTimeout;

  bool get isSuccess => data != null;
}
