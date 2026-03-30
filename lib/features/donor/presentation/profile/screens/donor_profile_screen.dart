import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/location_service.dart';
import 'package:wastenot/services/session_service.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  static const Color mainGreen = Color(0xFF0F5D4E);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocationService _locationService = const LocationService();

  bool _isEditing = false;
  bool _saving = false;
  File? _selectedImage;
  AppLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _syncFromSession(SessionService.user);
    SessionService.currentUser.addListener(_handleSessionUserChange);
  }

  @override
  void dispose() {
    SessionService.currentUser.removeListener(_handleSessionUserChange);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSessionUserChange() {
    if (!_isEditing) {
      _syncFromSession(SessionService.user);
    }
  }

  void _syncFromSession(AppUserModel? user) {
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _selectedLocation = user?.location;
    _addressController.text = user?.location?.address ?? user?.address ?? '';
  }

  Future<void> _pickImage() async {
    if (!_isEditing) {
      return;
    }

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) {
      return;
    }

    setState(() => _selectedImage = File(image.path));
  }

  Future<void> _pickLocation() async {
    if (!_isEditing) {
      return;
    }

    final location = await _locationService.pickLocation(
      context,
      initialLocation: _selectedLocation,
      title: 'Update Profile Location',
    );

    if (location == null || !mounted) {
      return;
    }

    setState(() {
      _selectedLocation = location;
      _addressController.text = location.address;
    });
  }

  Future<void> _toggleEditSave() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _authService.updateCurrentUserProfile(
  email: _emailController.text,
  name: _nameController.text,
  phone: _phoneController.text,
  address: _addressController.text,
  location: _selectedLocation,
  profileImage: _selectedImage,
);

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
      _showMessage('Profile updated successfully.');
    } on AuthFailure catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : mainGreen,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    final editable = _isEditing && label != 'Email';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: editable,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: editable ? Colors.black : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUserModel?>(
      valueListenable: SessionService.currentUser,
      builder: (context, user, _) {
        final initials = SessionService.initials();
        final networkImage = user?.profileImageUrl;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: mainGreen,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Personal Information',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _saving ? null : _toggleEditSave,
                child: Text(
                  _isEditing ? (_saving ? 'Saving...' : 'Save') : 'Edit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade100,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (networkImage != null && networkImage.isNotEmpty)
                                ? NetworkImage(networkImage)
                                : null,
                        child: _selectedImage == null &&
                                (networkImage == null || networkImage.isEmpty)
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      const Positioned(
                        bottom: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _field('Name', _nameController),
                _field('Email', _emailController),
                _field('Phone', _phoneController),
                _field(
                  'Address',
                  _addressController,
                  readOnly: true,
                  onTap: _pickLocation,
                  suffixIcon: const Icon(Icons.map_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
