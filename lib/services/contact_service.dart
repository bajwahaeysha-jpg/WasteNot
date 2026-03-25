import 'package:cloud_firestore/cloud_firestore.dart';

class ContactService {
  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contact_messages');

  Future<void> sendMessage({
    required String userId,
    required String role,
    required String name,
    required String email,
    required String message,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const ContactException('Message cannot be empty.');
    }

    await _collection.add({
      'userId': userId.trim(),
      'role': role.trim(),
      'name': name.trim(),
      'email': email.trim(),
      'message': trimmedMessage,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> markResolved(String docId) {
    return _collection.doc(docId).update({'status': 'resolved'});
  }

  Future<void> deleteMessage(String docId) {
    return _collection.doc(docId).delete();
  }
}

class ContactException implements Exception {
  const ContactException(this.message);

  final String message;

  @override
  String toString() => message;
}
