import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/location_service.dart';
import 'package:wastenot/services/session_service.dart';

const Color mainGreen = Color(0xFF0B4B3F);

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final ImagePicker _picker = ImagePicker();
  final DonationService _donationService = DonationService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = const LocationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<XFile> pickedImages = [];
  String? selectedServing;
  String selectedPrecaution = 'None';

  bool _isSubmitting = false;
  bool _isLoadingLocation = true;
  AppLocation? _selectedDonationLocation;

  final foodController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<String> servingOptions = const [
    '1 - 10',
    '10 - 20',
    '20 - 30',
    '30 - 40',
    '40 - 50',
    'More than 50',
  ];

  final List<String> precautionOptions = const [
    'Refrigerator',
    'Containers',
    'Handle carefully',
    'Keep warm',
    'None',
  ];

  final TextStyle headingStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  final TextStyle inputStyle = const TextStyle(
    fontSize: 15,
  );

  @override
  void initState() {
    super.initState();
    _loadProfileLocation();
  }

  @override
  void dispose() {
    foodController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileLocation() async {
    final donor = SessionService.user;

    if (donor == null || donor.uid.trim().isEmpty) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      final refreshedUser =
          await _firestoreService.getUserByUid(donor.uid);
      final location = refreshedUser?.location ?? donor.location;

      setState(() {
        _selectedDonationLocation = location;
        locationController.text = location?.address ?? '';
        _isLoadingLocation = false;
      });
    } catch (_) {
      setState(() {
        _selectedDonationLocation = donor.location;
        locationController.text = donor.location?.address ?? '';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      setState(() {
        final remainingSlots = 4 - pickedImages.length;

if (remainingSlots > 0) {
  pickedImages.addAll(images.take(remainingSlots));
}
      });
    }
  }

  Future<void> _submitDonation() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (pickedImages.isEmpty) {
      _showError('Please add at least one image');
      return;
    }

    final donor = SessionService.user;
    if (donor == null || !donor.isDonor) {
      _showError('Please log in as donor');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final donationId = _donationService.createDraftDonationId();
      List<String> uploadedUrls = [];

      for (var img in pickedImages) {
        final url = await _firestoreService.uploadDonationImage(
          donorId: donor.uid,
          donationId: donationId,
          imageFile: File(img.path),
        );

        if (url != null) uploadedUrls.add(url);
      }

      await _donationService.createDonation(
        donor: donor,
        donationId: donationId,
        request: DonationCreateRequest(
          foodItems: foodController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          quantity: selectedServing!,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          precaution:
              selectedPrecaution == 'None' ? null : selectedPrecaution,
          location: _selectedDonationLocation!,
          imageUrls: uploadedUrls,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Donation submitted successfully"),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } on DonationException catch (e, stackTrace) {
      debugPrint('DonationException while submitting donation: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      _showError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error while submitting donation: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showError('Error submitting donation: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDonationLocation() async {
    final location = await _locationService.pickLocation(
      context,
      initialLocation: _selectedDonationLocation,
      title: 'Select Location',
    );

    if (location != null) {
      setState(() {
        _selectedDonationLocation = location;
        locationController.text = location.address;
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          'Add Donation',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Food", style: headingStyle),
              const SizedBox(height: 6),
              _textField("Enter food items", foodController),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: Text("Location", style: headingStyle)),
                  Expanded(child: Text("Servings", style: headingStyle)),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Expanded(
                    child: _textField(
                      "Location",
                      locationController,
                      readOnly: true,
                      onTap: _pickDonationLocation,
                      suffix: const Icon(Icons.location_on,
                          color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _servingDropdown()),
                ],
              ),

              const SizedBox(height: 16),

              Text("Images", style: headingStyle),
              const SizedBox(height: 8),

              Row(
                children: [

                  // ðŸ”¥ HIDE BUTTON WHEN IMAGES EXIST
                  Expanded(
                    child: SizedBox(
                      height: 85,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pickedImages.length < 4
                            ? pickedImages.length + 1
                            : pickedImages.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          if (pickedImages.length < 4 && i == 0) {
                            return GestureDetector(
                              onTap: pickImages,
                              child: Container(
                                height: 85,
                                width: 85,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add_a_photo),
                              ),
                            );
                          }

                          final imageIndex = pickedImages.length < 4 ? i - 1 : i;

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(pickedImages[imageIndex].path),
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pickedImages.removeAt(imageIndex);
                                    });
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text("Precaution", style: headingStyle),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: precautionOptions.map((option) {
                  final isSelected = selectedPrecaution == option;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedPrecaution = option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mainGreen.withValues(alpha: .1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? mainGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? mainGreen
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Text("Description", style: headingStyle),
              const SizedBox(height: 6),
              _textArea(descriptionController),

              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed:
                        _isSubmitting ? null : _submitDonation,
                   child: _isSubmitting
    ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Submitting...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      )
    : const Text(
        "Submit",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller,
      {bool readOnly = false,
      VoidCallback? onTap,
      Widget? suffix}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: inputStyle,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  Widget _textArea(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: inputStyle,
      decoration: InputDecoration(
        hintText: "Write here...",
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  Widget _servingDropdown() {
  return DropdownButtonFormField<String>(
    initialValue: selectedServing,
    dropdownColor: Colors.white, // ðŸ”¥ dropdown bg fix

    hint: const Text(
      "Servings",
      style: TextStyle(color: Colors.black54),
    ),

    style: const TextStyle(
      fontSize: 15,
      color: Colors.black, // ðŸ”¥ selected text visible
    ),

    items: servingOptions.map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(
          e,
          style: const TextStyle(
            color: Colors.black, // ðŸ”¥ list items visible
            fontSize: 15,
          ),
        ),
      );
    }).toList(),

    onChanged: (val) => setState(() => selectedServing = val),

    icon: const Icon(Icons.keyboard_arrow_down,
        color: Colors.black), // ðŸ”¥ arrow visible

    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    ),
  );
}
}
