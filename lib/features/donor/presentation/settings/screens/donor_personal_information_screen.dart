import 'package:flutter/material.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/location_service.dart';
import 'package:wastenot/services/session_service.dart';

class DonorPersonalInformationScreen extends StatefulWidget {
  const DonorPersonalInformationScreen({super.key});

  @override
  State<DonorPersonalInformationScreen> createState() =>
      _DonorPersonalInformationScreenState();
}

class _DonorPersonalInformationScreenState
    extends State<DonorPersonalInformationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutController = TextEditingController();
  final _authService = AuthService();
  final _locationService = const LocationService();

  bool _isEditing = false;
  bool _saving = false;
  AppLocation? _selectedLocation;

  static const Color mainGreen = Color(0xFF0E5E53);

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
    _aboutController.dispose();
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
    _aboutController.text = user?.about ?? '';
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
        about: _aboutController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() => _isEditing = false);
      _showMessage('Information updated successfully.');
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
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    final editable = _isEditing && label != 'Email';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: editable,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _toggleEditSave,
            child: Text(
              _isEditing ? (_saving ? 'Saving...' : 'Save') : 'Edit',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
            _field('About', _aboutController, maxLines: 4),
          ],
        ),
      ),
    );
  }
}
