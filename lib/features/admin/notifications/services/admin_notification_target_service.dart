import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/services/firestore_service.dart';

/// Backend helper for Admin Notifications screen navigation targets.
/// Keeps Firestore lookup logic out of UI widgets.
class AdminNotificationTargetService {
  AdminNotificationTargetService({
    FirebaseFirestore? firestore,
    FirestoreService? firestoreService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseFirestore _firestore;
  final FirestoreService _firestoreService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Returns the user's UID (document id) if a `users` document exists for
  /// the given email, otherwise null.
  Future<String?> findUserIdByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final snap = await _users.where('email', isEqualTo: normalized).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  /// Returns the pending NGO request (if any) for a given email.
  Future<NgoRequestModel?> findNgoRequestByEmail(String email) {
    return _firestoreService.getNgoRequestByEmail(email.trim().toLowerCase());
  }
}

