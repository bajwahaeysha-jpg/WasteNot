import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/concern_services.dart';
import 'package:wastenot/services/session_service.dart';

class RaiseConcernScreen extends StatefulWidget {
  const RaiseConcernScreen({super.key});

  @override
  State<RaiseConcernScreen> createState() => _RaiseConcernScreenState();
}

class _RaiseConcernScreenState extends State<RaiseConcernScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ConcernService _concernService = ConcernService();
  final ImagePicker _imagePicker = ImagePicker();

  static const int _limit = 120;

  File? _image;
  bool _isSubmitting = false;
  ConcernDurationOption _selectedDuration =
      ConcernService.durationOptions.first;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() {
      _image = File(picked.path);
    });
  }

  Future<void> _deleteConcern(ConcernModel concern) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete concern'),
          content: Text(
            'Remove "${concern.title}" from the active concerns list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _concernService.deleteConcern(concern.concernId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern deleted.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern could not be deleted.')),
      );
    }
  }

  Future<void> _submitConcern() async {
    final currentUser = SessionService.user;
    if (currentUser == null || !currentUser.isNgo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NGO session not available.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _concernService.createConcern(
        title: title,
        message: message,
        ngoId: currentUser.uid,
        ngoName: currentUser.displayName,
        ngoEmail: currentUser.email,
        imageFile: _image,
        duration: _selectedDuration.duration,
        durationLabel: _selectedDuration.label,
      );

      _titleController.clear();
      _messageController.clear();
      setState(() {
        _image = null;
        _selectedDuration = ConcernService.durationOptions.first;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your concern has been raised.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern could not be submitted.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatExpiry(DateTime expiryTime) {
    return DateFormat('dd MMM, hh:mm a').format(expiryTime);
  }

  Widget _durationSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ConcernService.durationOptions.map((option) {
        final selected = option.label == _selectedDuration.label;
        return ChoiceChip(
          label: Text(option.label),
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedDuration = option);
          },
        );
      }).toList(),
    );
  }

  Widget _ownConcernsSection(AppUserModel currentUser) {
    return StreamBuilder<List<ConcernModel>>(
      stream: _concernService.getNgoConcerns(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final concerns = snapshot.hasError
            ? const <ConcernModel>[]
            : (snapshot.data ?? const <ConcernModel>[]);
        if (concerns.isEmpty) {
          return const Text(
            'No concerns raised yet.',
            style: TextStyle(color: Colors.black54),
          );
        }

        return Column(
          children: concerns.map((concern) {
            final expired = concern.isExpired || !concern.isActive;
            final imageUrl = concern.imageUrl.trim();

            return GestureDetector(
              onLongPress: () => _deleteConcern(concern),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  concern.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: expired
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : const Color(0xFF0B4B3F).withValues(
                                          alpha: 0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  expired ? 'Expired' : 'Active',
                                  style: TextStyle(
                                    color: expired
                                        ? Colors.red.shade700
                                        : const Color(0xFF0B4B3F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            concern.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Expires: ${_formatExpiry(concern.expiryTime)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          'Raise a Concern',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here you can raise growing concerns that need immediate attention. Your voice is respected and every report helps us improve our impact.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please note: you can only raise one concern at a time. Submitting a new concern will automatically delete the previous one.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Concern title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? const Icon(Icons.add_a_photo, size: 20)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Concern visibility',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            _durationSelector(),
            const SizedBox(height: 20),
            const Text(
              'Write your concern',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLength: _limit,
              maxLines: 4,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Describe the issue briefly...',
                hintStyle: const TextStyle(color: Colors.black54),
                counterStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4B3F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _isSubmitting ? null : _submitConcern,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            if (currentUser != null && currentUser.isNgo) ...[
              const SizedBox(height: 24),
              const Text(
                'Your concerns',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _ownConcernsSection(currentUser),
            ],
          ],
        ),
      ),
    );
  }
}
