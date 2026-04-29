import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/location_service.dart';
import 'package:wastenot/services/session_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = const LocationService();

  late final TextEditingController _organizationNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _registrationNumberController;
  late final TextEditingController _aboutController;

  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;
  AppUserModel? _lastLoadedUser;
  AppLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _organizationNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _registrationNumberController = TextEditingController();
    _aboutController = TextEditingController();
    _loadUser(SessionService.user);
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _registrationNumberController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _loadUser(AppUserModel? user) {
    if (user == null) return;

    final shouldReplaceControllers =
        _lastLoadedUser == null ||
        _lastLoadedUser!.uid != user.uid ||
        (!_isEditing && _didUserChange(user));

    _lastLoadedUser = user;

    if (!shouldReplaceControllers) return;

    _organizationNameController.text =
        user.organizationName ?? user.displayName;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _selectedLocation = user.location;
    _addressController.text = user.location?.address ?? user.address ?? '';
    _registrationNumberController.text = user.registrationNumber ?? '';
    _aboutController.text =
        user.about ?? user.organizationDescription ?? '';

    _selectedImage = null;
  }

  bool _didUserChange(AppUserModel user) {
    return _organizationNameController.text !=
            (user.organizationName ?? user.displayName) ||
        _emailController.text != user.email ||
        _phoneController.text != (user.phone ?? '') ||
        _addressController.text != (user.address ?? '') ||
        _registrationNumberController.text !=
            (user.registrationNumber ?? '') ||
        _aboutController.text !=
            (user.about ?? user.organizationDescription ?? '');
  }

  Future<void> _toggleEditSave() async {
    if (_isSaving) return;

    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authService.updateCurrentUserProfile(
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        location: _selectedLocation,
        organizationName: _organizationNameController.text,
        registrationNumber: _registrationNumberController.text,
        organizationDescription: _aboutController.text,
        profileImage: _selectedImage,
      );

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });

      _showMessage("Profile updated successfully");
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _pickLocation() async {
    if (!_isEditing) return;

    final location = await _locationService.pickLocation(
      context,
      initialLocation: _selectedLocation,
      title: 'Update Location',
    );

    if (location == null || !mounted) return;

    setState(() {
      _selectedLocation = location;
      _addressController.text = location.address;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF0B4B3F),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _profileField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isEditing ? Colors.white : Colors.grey.shade100,

        // ✅ SHADOW
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],

        borderRadius: BorderRadius.circular(16),

        // ✅ BORDER
        border: Border.all(
          color: _isEditing
              ? const Color(0xFF0B4B3F)
              : Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: _isEditing && !_isSaving,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        _loadUser(user);

        final profileImage = _selectedImage != null
            ? FileImage(_selectedImage!)
            : (user?.profileImageUrl != null &&
                    user!.profileImageUrl!.isNotEmpty)
                ? NetworkImage(user.profileImageUrl!)
                : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),

          appBar: AppBar(
            backgroundColor: const Color(0xFF0B4B3F),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Personal Information',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: _toggleEditSave,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),

          body: user == null
              ? const Center(child: Text('Profile not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// IMAGE
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                profileImage as ImageProvider?,
                            child: profileImage == null
                                ? Text(
                                    SessionService.initials(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      _sectionTitle("Personal Info"),
                      _profileField(
                          "Organization Name", _organizationNameController),
                      _profileField("Registration Number",
                          _registrationNumberController),

                      _sectionTitle("Contact Info"),
                      _profileField("Phone Number", _phoneController),
                      _profileField("Email", _emailController),
                      _profileField(
                        "Location",
                        _addressController,
                        readOnly: true,
                        onTap: _pickLocation,
                        suffixIcon: const Icon(Icons.map_outlined),
                      ),

                      _sectionTitle("About"),
                      _profileField("About", _aboutController, maxLines: 4),
                    ],
                  ),
                ),
        );
      },
    );
  }
}