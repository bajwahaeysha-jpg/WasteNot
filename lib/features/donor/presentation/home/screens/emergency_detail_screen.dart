import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/features/messaging/models/chat_models.dart';

import 'package:wastenot/services/chat_privacy_service.dart';
import 'package:wastenot/services/concern_services.dart';
import 'package:wastenot/services/firestore_service.dart';
import 'package:wastenot/services/session_service.dart';

import '../../messages/screens/chat_screen.dart';

class EmergencyDetailScreen extends StatefulWidget {
  const EmergencyDetailScreen({
    super.key,
    required this.concern,
  });

  final ConcernModel concern;

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatPrivacyService _privacyService = ChatPrivacyService();
  bool _isOpeningChat = false;

  Future<void> _openConcernChat() async {
    if (_isOpeningChat) {
      return;
    }

    final currentUser = SessionService.user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor session not available.')),
      );
      return;
    }

    setState(() => _isOpeningChat = true);

    try {
      final ngoUser =
          await _firestoreService.getUserByUid(widget.concern.ngoId);
      if (!mounted) {
        return;
      }

      if (ngoUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO could not be found.')),
        );
        return;
      }

      final allowed = await _privacyService.canSendMessage(ngoUser.uid);
      if (!allowed) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This user has disabled direct messages')),
        );
        return;
      }

      final reference = ConcernChatReference(
        concernId: widget.concern.concernId,
        concernTitle: widget.concern.title,
        concernImageUrl: widget.concern.imageUrl,
        ngoId: widget.concern.ngoId,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            donorName: currentUser.displayName,
            ngoName: ngoUser.displayName,
            ngoUser: ngoUser,
            concernReference: reference,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat could not be opened.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(value);
  }

  String _timeLeft() {
    final difference = widget.concern.expiryTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Expired';
    }
    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    }
    final minutes = difference.inMinutes < 1 ? 1 : difference.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} left';
  }

  @override
  Widget build(BuildContext context) {
    final concern = widget.concern;
    final imageUrl = concern.imageUrl.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: EmergencyDetailScreen.mainGreen,
        elevation: 0,
        title: const Text(
          'Emergency Help',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: imageUrl.isEmpty
                  ? Image.asset(
                      'assets/images/emergency.jpg',
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/emergency.jpg',
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concern.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Raised by ${concern.ngoName}',
                    style: const TextStyle(
                      color: EmergencyDetailScreen.mainGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _progressValue(concern),
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    color: EmergencyDetailScreen.mainGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Raised ${_formatDate(concern.createdAt)}'),
                      Text(_timeLeft()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EmergencyDetailScreen.mainGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isOpeningChat ? null : _openConcernChat,
                      child: _isOpeningChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Donate Now',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        EmergencyDetailScreen.mainGreen.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.verified_user,
                      color: EmergencyDetailScreen.mainGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concern.ngoName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified NGO',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(concern.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    concern.message,
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Expires: ${_formatDate(concern.expiryTime)}',
                    style: const TextStyle(
                      color: EmergencyDetailScreen.mainGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _progressValue(ConcernModel concern) {
  final total = concern.expiryTime.difference(concern.createdAt).inSeconds;
  if (total <= 0) {
    return 0;
  }

  final remaining = concern.expiryTime.difference(DateTime.now()).inSeconds;
  return (remaining / total).clamp(0.0, 1.0);
}
