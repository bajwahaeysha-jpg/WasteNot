import 'package:flutter/material.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/features/auth/presentation/controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final ForgotPasswordController _controller;

  bool get _isLoading => _controller.isLoading;
  bool get _isSuccess => _controller.isSuccess;
  String? get _statusMessage => _controller.statusMessage;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController()
      ..addListener(_handleControllerUpdate);

    _emailController.text = widget.initialEmail?.trim() ?? '';
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerUpdate)
      ..dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),

      /// 🔥 CLEAN APP BAR (MATCHES APP THEME)
     appBar: AppBar(
  backgroundColor: AppColors.primaryGreen,
  elevation: 0,

  /// 🔙 SAME BACK ARROW STYLE
  iconTheme: const IconThemeData(color: Colors.white),



  title: const Text(
    'Forgot Password',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),

              child: Card(
                elevation: 6,
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        /// 🔒 ICON
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 52,
                          color: AppColors.primaryGreen,
                        ),

                        const SizedBox(height: 16),

                        /// TITLE
                        const Text(
                          'Reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SUBTITLE
                        const Text(
                          'Enter your email and we will send you a secure reset link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// 📧 EMAIL FIELD
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (_) => _controller.clearStatus(),
                          onFieldSubmitted: (_) =>
                              _isLoading ? null : _submit(),
                          validator: _controller.validateEmail,

                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: const Color(0xFFF4F7F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        /// 🔔 STATUS MESSAGE
                        if (_statusMessage != null) ...[
                          const SizedBox(height: 16),
                          _StatusBanner(
                            message: _statusMessage!,
                            isSuccess: _isSuccess,
                          ),
                        ],

                        const SizedBox(height: 24),

                        /// 🔥 BUTTON
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔙 BACK BUTTON
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            _isSuccess ? 'Back to Login' : 'Cancel',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();

    final didSend =
        await _controller.sendResetLink(_emailController.text);

    if (!mounted || !didSend) return;

    if (_isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}

/// 🔔 STATUS BANNER
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isSuccess,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSuccess
        ? AppColors.primaryGreen.withValues(alpha: 0.12)
        : Colors.red.withValues(alpha: 0.10);

    final textColor =
        isSuccess ? AppColors.primaryGreen : Colors.red.shade700;

    final icon =
        isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}