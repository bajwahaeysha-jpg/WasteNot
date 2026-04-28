import 'package:flutter/foundation.dart';
import 'package:wastenot/repositories/auth_repository.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _statusMessage;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get statusMessage => _statusMessage;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  void clearStatus() {
    if (_statusMessage == null && !_isSuccess) {
      return;
    }

    _statusMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  Future<bool> sendResetLink(String email) async {
    _isLoading = true;
    _statusMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(
        email: email.trim(),
      );

      _isSuccess = true;
      _statusMessage = 'Password reset email sent. Check your inbox.';
      return true;
    } catch (error) {
      _isSuccess = false;
      _statusMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
