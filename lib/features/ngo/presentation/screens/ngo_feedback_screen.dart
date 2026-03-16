import 'package:flutter/material.dart';
import 'package:wastenot/core/constants/app_colors.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class NgoFeedbackScreen extends StatefulWidget {
  const NgoFeedbackScreen({super.key});

  @override
  State<NgoFeedbackScreen> createState() => _NgoFeedbackScreenState();
}

class _NgoFeedbackScreenState extends State<NgoFeedbackScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _feedbackController = TextEditingController();

  AppUserModel? _selectedDonor;
  int _rating = 0;
  bool _isSubmitting = false;

  AppUserModel? get _currentNgo => SessionService.user;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final ngo = _currentNgo;
    final donor = _selectedDonor;
    final feedbackText = _feedbackController.text.trim();

    if (ngo == null || !ngo.isNgo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NGO profile not found. Please log in again.'),
        ),
      );
      return;
    }

    if (donor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a donor.')),
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
      await _firestoreService.submitFeedback(
        ngo: ngo,
        donor: donor,
        feedbackText: feedbackText,
        rating: _rating,
      );

      if (!mounted) return;

      setState(() {
        _selectedDonor = null;
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
        stream: _firestoreService.usersByRole('donor'),
        builder: (context, snapshot) {
          final donors = snapshot.data ?? const <AppUserModel>[];
          final loading = snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null;

          if (_selectedDonor != null) {
            final match = donors.where((donor) => donor.uid == _selectedDonor!.uid);
            _selectedDonor = match.isNotEmpty ? match.first : null;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: donors.any((d) => d.uid == _selectedDonor?.uid)
                      ? _selectedDonor?.uid
                      : null,
                  isExpanded: true,
                  hint: Text(loading ? 'Loading donors...' : 'Choose donor'),
                  decoration: _inputDecoration(),
                  items: donors
                      .map(
                        (donor) => DropdownMenuItem<String>(
                          value: donor.uid,
                          child: Text(
                            donor.displayName,
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
                    return donors
                        .map(
                          (donor) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              donor.displayName,
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
                  onChanged: loading || donors.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDonor = donors.firstWhere(
                              (donor) => donor.uid == value,
                            );
                          });
                        },
                ),
                if (!loading && donors.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'No registered donors found in Firebase.',
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
                    'Rate Donor',
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