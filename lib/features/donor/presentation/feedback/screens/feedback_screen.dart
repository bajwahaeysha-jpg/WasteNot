import 'package:flutter/material.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _feedbackController = TextEditingController();

  AppUserModel? _selectedNgo;
  int _rating = 0;
  bool _isSubmitting = false;

  AppUserModel? get _currentDonor => SessionService.user;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final donor = _currentDonor;
    final ngo = _selectedNgo;
    final feedbackText = _feedbackController.text.trim();

    if (donor == null || !donor.isDonor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donor profile not found. Please log in again.'),
        ),
      );
      return;
    }

    if (ngo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NGO.')),
      );
      return;
    }

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write feedback before submitting.'),
        ),
      );
      return;
    }

    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating from 1 to 5.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestoreService.submitDonorFeedback(
        donor: donor,
        ngo: ngo,
        feedbackText: feedbackText,
        rating: _rating,
      );

      if (!mounted) return;

      setState(() {
        _selectedNgo = null;
        _rating = 0;
        _feedbackController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit feedback. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<AppUserModel>>(
        stream: _firestoreService.registeredNgos(),
        builder: (context, snapshot) {
          final ngos = snapshot.data ?? const <AppUserModel>[];
          final loading = snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null;

          if (_selectedNgo != null) {
            final match = ngos.where((ngo) => ngo.uid == _selectedNgo!.uid);
            _selectedNgo = match.isNotEmpty ? match.first : null;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: ngos.any((ngo) => ngo.uid == _selectedNgo?.uid)
                      ? _selectedNgo?.uid
                      : null,
                  isExpanded: true,
                  hint: Text(loading ? 'Loading NGOs...' : 'Choose NGO'),
                  decoration: _inputDecoration(),
                  items: ngos
                      .map(
                        (ngo) => DropdownMenuItem<String>(
                          value: ngo.uid,
                          child: Text(
                            ngo.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) {
                    return ngos
                        .map(
                          (ngo) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              ngo.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList();
                  },
                  onChanged: loading || ngos.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedNgo = ngos.firstWhere(
                              (ngo) => ngo.uid == value,
                            );
                          });
                        },
                ),
                if (!loading && ngos.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'No registered NGOs found in Firebase.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hintText: 'Write your message...',
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Rate NGO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Wrap(
                    spacing: 2,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade700,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Center(
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Feedback',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}