import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/services/session_service.dart';

class ChatPrivacyService {
  ChatPrivacyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<bool> canSendMessage(String receiverId) async {
    final currentUser = SessionService.user;
    if (currentUser?.isAdmin == true) {
      return true;
    }

    final trimmedId = receiverId.trim();
    if (trimmedId.isEmpty) {
      return true;
    }

    try {
      final doc = await _firestore.collection('users').doc(trimmedId).get();
      if (!doc.exists) {
        return true;
      }
      final data = doc.data();
      final allowMessages = data?['allowMessages'];
      if (allowMessages is bool) {
        return allowMessages;
      }
    } catch (_) {}

    return true;
  }
}
