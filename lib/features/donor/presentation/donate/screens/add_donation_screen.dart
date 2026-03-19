import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final ImagePicker _picker = ImagePicker();
  final DonationService _donationService = DonationService();
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? pickedImage;
  String? selectedServing;
  bool _isSubmitting = false;

  final foodController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final precautionController = TextEditingController();

  final List<String> servingOptions = const [
    '1 - 10',
    '10 - 20',
    '20 - 30',
    '30 - 40',
    '40 - 50',
    'More than 50',
  ];

  @override
  void dispose() {
    foodController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    precautionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img != null && mounted) {
      setState(() => pickedImage = img);
    }
  }

  Future<void> _submitDonation() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    final donor = SessionService.user;
    if (donor == null || !donor.isDonor) {
      _showError('Please log in as a donor to create a donation.');
      return;
    }

    final description = descriptionController.text.trim();
    final precaution = precautionController.text.trim();

    final mergedDescription = [
      if (description.isNotEmpty) description,
      if (precaution.isNotEmpty) 'Precaution: $precaution',
    ].join('\n\n');

    setState(() => _isSubmitting = true);

    try {
      final donationId =
          _donationService.createDraftDonationId();
      final uploadedImageUrl = await _firestoreService.uploadDonationImage(
        donorId: donor.uid,
        donationId: donationId,
        imageFile: pickedImage == null ? null : File(pickedImage!.path),
      );

      await _donationService.createDonation(
        donor: donor,
        donationId: donationId,
        request: DonationCreateRequest(
          foodItems: foodController.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
          quantity: selectedServing!,
          description: mergedDescription.isEmpty ? null : mergedDescription,
          location: locationController.text.trim(),
          imageUrls: uploadedImageUrl == null
              ? const <String>[]
              : <String>[uploadedImageUrl],
        ),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFF5F7F6),
          title: const Text('Donation Submitted'),
          content: const Text(
            'Your donation is now visible to all registered NGOs and is ready to be accepted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on DonationException catch (error) {
      _showError(error.message);
    } on Exception {
      _showError('Image upload failed. Please try again.');
    } catch (_) {
      _showError('Unable to submit donation right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ IMPORTANT
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E53),
        title: const Text(
          'Add Donation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // ✅ FIX
          padding: EdgeInsets.fromLTRB(
            14,
            14,
            14,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your surplus, someone's meal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Together, we can turn your generosity into a meal that truly matters.',
              ),
              const SizedBox(height: 12),

              const Text('Food', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _textField(
                'What food are you donating?',
                foodController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter at least one food item.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: _textField(
                              'Enter pickup location',
                              locationController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Location is required.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Images',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: pickedImage == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 30,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(pickedImage!.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _servingDropdown(),

              const SizedBox(height: 10),

              const Text('Description'),
              const SizedBox(height: 4),
              _textArea(descriptionController, minLines: 2),

              const SizedBox(height: 8),

              const Text('Precaution'),
              const SizedBox(height: 4),
              _textArea(precautionController, minLines: 1),

              const SizedBox(height: 20), // ✅ Spacer removed
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E5E53),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitDonation,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _textArea(
    TextEditingController controller, {
    required int minLines,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Write here...',
        ),
      ),
    );
  }

  Widget _servingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedServing,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: const Text('Select servings'),
        isExpanded: true,
        items: servingOptions
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Select quantity or servings.';
          }
          return null;
        },
        onChanged: (val) => setState(() => selectedServing = val),
      ),
    );
  }
}