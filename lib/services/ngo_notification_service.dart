import 'package:cloud_firestore/cloud_firestore.dart';

class NgoNotificationService {
  NgoNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> notificationsForNgo({
    required String? uid,
    required String? email,
  }) {
    final ngoId = uid?.trim() ?? '';
    if (ngoId.isEmpty) {
      return Stream<List<Map<String, dynamic>>>.value(const <Map<String, dynamic>>[]);
    }

    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: ngoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return <String, dynamic>{
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }
}
