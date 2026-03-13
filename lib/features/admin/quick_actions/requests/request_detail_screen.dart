import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/services/firestore_service.dart';

import 'request_success_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.request,
  });

  final NgoRequestModel request;

  static const Color mainGreen = Color(0xFF0F4C45);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: RequestDetailScreen.mainGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Request Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.withValues(alpha: .12),
                  backgroundImage: widget.request.profileImageUrl != null
                      ? NetworkImage(widget.request.profileImageUrl!)
                      : null,
                  child: widget.request.profileImageUrl == null
                      ? const Icon(Icons.apartment, size: 42, color: Colors.blue)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.request.organizationName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.request.address,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending Approval',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow('Email', widget.request.email),
                        _infoRow('Phone', widget.request.phone),
                        _infoRow('Address', widget.request.address),
                        _infoRow(
                          'Registration No.',
                          widget.request.registrationNumber,
                        ),
                        _infoRow(
                          'Submitted',
                          DateFormat('dd MMM yyyy, hh:mm a').format(
                            widget.request.createdAt,
                          ),
                        ),
                        _infoRow('Description', widget.request.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _busy ? null : _approveRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RequestDetailScreen.mainGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _busy ? null : _rejectRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest() async {
    setState(() => _busy = true);
    try {
      await _firestoreService.approveNgoRequest(widget.request);
      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RequestSuccessScreen()),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _rejectRequest() async {
    setState(() => _busy = true);
    try {
      await _firestoreService.createNgoRejectionNotification(widget.request);
      await _firestoreService.rejectNgoRequest(widget.request.id);
      _showMessage('NGO request rejected.');
      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor:
            isError ? Colors.red : RequestDetailScreen.mainGreen,
      ),
    );
  }
}
