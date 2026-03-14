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
        const SnackBar(content: Text('NGO profile not found. Please log in again.')),
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
        const SnackBar(content: Text('Please write feedback before submitting.')),
      );
      return;
    }

    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating from 1 to 5.')),
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

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedDonor = null;
        _rating = 0;
        _feedbackController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit feedback. Please try again.')),
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
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white),
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
            if (match.isNotEmpty) {
  _selectedDonor = match.first;
} else {
  _selectedDonor = null;
}
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Donor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: donors.any((d) => d.uid == _selectedDonor?.uid)
                            ? _selectedDonor?.uid
                            : null,
                        isExpanded: true,
                        hint: Text(
                          loading ? 'Loading donors...' : 'Choose donor',
                        ),
                        decoration: _inputDecoration(),
                        items: donors
                            .map(
                              (donor) => DropdownMenuItem<String>(
                                value: donor.uid,
                                child: Row(
                                  children: [
                                    _ProfileAvatar(
                                      name: donor.displayName,
                                      imageUrl: donor.profileImageUrl,
                                      radius: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            donor.displayName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            donor.email,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                        const SizedBox(height: 10),
                        const Text(
                          'No registered donors found in Firebase.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                      if (_selectedDonor != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F7F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _ProfileAvatar(
                                name: _selectedDonor!.displayName,
                                imageUrl: _selectedDonor!.profileImageUrl,
                                radius: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDonor!.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Donor ID: ${_selectedDonor!.uid}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Write Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 5,
                        decoration: _inputDecoration(
                          hintText: 'Write feedback about donor...',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Rate Donor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: List.generate(
                          5,
                          (index) => IconButton(
                            onPressed: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber.shade700,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                            style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.radius,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              initials.isEmpty ? 'WN' : initials,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.65,
              ),
            )
          : null,
    );
  }
}
