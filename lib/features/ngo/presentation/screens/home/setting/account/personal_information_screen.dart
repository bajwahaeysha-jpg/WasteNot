import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/auth_service.dart';
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

  late final TextEditingController _organizationNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _registrationNumberController;
  late final TextEditingController _organizationDescriptionController;

  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;
  AppUserModel? _lastLoadedUser;

  @override
  void initState() {
    super.initState();
    _organizationNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _registrationNumberController = TextEditingController();
    _organizationDescriptionController = TextEditingController();
    _loadUser(SessionService.user);
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _registrationNumberController.dispose();
    _organizationDescriptionController.dispose();
    super.dispose();
  }

  void _loadUser(AppUserModel? user) {
    if (user == null) {
      return;
    }

    final shouldReplaceControllers =
        _lastLoadedUser == null ||
        _lastLoadedUser!.uid != user.uid ||
        (!_isEditing && _didUserChange(user));

    _lastLoadedUser = user;
    if (!shouldReplaceControllers) {
      return;
    }

    _organizationNameController.text = user.organizationName ?? user.displayName;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';
    _registrationNumberController.text = user.registrationNumber ?? '';
    _organizationDescriptionController.text =
        user.organizationDescription ?? '';
    _selectedImage = null;
  }

  bool _didUserChange(AppUserModel user) {
    return _organizationNameController.text !=
            (user.organizationName ?? user.displayName) ||
        _emailController.text != user.email ||
        _phoneController.text != (user.phone ?? '') ||
        _addressController.text != (user.address ?? '') ||
        _registrationNumberController.text != (user.registrationNumber ?? '') ||
        _organizationDescriptionController.text !=
            (user.organizationDescription ?? '');
  }

  Future<void> _toggleEditSave() async {
    if (_isSaving) {
      return;
    }

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
        organizationName: _organizationNameController.text,
        registrationNumber: _registrationNumberController.text,
        organizationDescription: _organizationDescriptionController.text,
        profileImage: _selectedImage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
    } on AuthFailure catch (error) {
      _showMessage(error.message, isError: true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) {
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF0F4C45),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: _isEditing && !_isSaving,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isEditing
                    ? const Color(0xFF0F4C45)
                    : Colors.grey.shade300,
                width: _isEditing ? 1.6 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0F4C45),
                width: 1.8,
              ),
            ),
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
        _loadUser(user);

        final profileImage = _selectedImage != null
            ? FileImage(_selectedImage!)
            : (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty)
                ? NetworkImage(user.profileImageUrl!)
                : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F4C45),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
          body: user == null
              ? const Center(child: Text('NGO profile not found.'))
              : SingleChildScrollView(
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
                              backgroundColor:
                                  const Color(0xFF0F4C45).withValues(alpha: .15),
                              backgroundImage: profileImage as ImageProvider?,
                              child: profileImage == null
                                  ? Text(
                                      SessionService.initials(),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C45),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                height: 28,
                                width: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F4C45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _field('Organization Name', _organizationNameController),
                      _field('Email', _emailController),
                      _field('Phone Number', _phoneController),
                      _field('Address', _addressController),
                      _field(
                        'Registration Number',
                        _registrationNumberController,
                      ),
                      _field(
                        'Organization Description',
                        _organizationDescriptionController,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
