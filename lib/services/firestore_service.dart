import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wastenot/features/admin/more/feedback/feedback_model.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/ngo_request_model.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _ngoRequests =>
      _firestore.collection('ngo_requests');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('feedback');

  Future<String?> uploadProfileImage({
    required String folder,
    required String identifier,
    File? imageFile,
  }) async {
    if (imageFile == null) {
      return null;
    }

    final segments = imageFile.path.split('.');
    final extension = segments.length > 1 ? segments.last : 'jpg';
    final ref = _storage.ref().child(
          'profile_images/$folder/${identifier}_${DateTime.now().millisecondsSinceEpoch}.$extension',
        );

    try {
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> saveDonor({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? profileImageUrl,
  }) {
    return _users.doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'role': 'donor',
      'approvedByAdmin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) {
    final payload = <String, dynamic>{};

    if (name != null) {
      payload['name'] = name;
    }
    if (email != null) {
      payload['email'] = email;
    }
    if (phone != null) {
      payload['phone'] = phone;
    }
    if (address != null) {
      payload['address'] = address;
    }
    if (profileImageUrl != null) {
      payload['profileImageUrl'] = profileImageUrl;
    }

    if (payload.isEmpty) {
      return Future.value();
    }

    return _users.doc(uid).update(payload);
  }

  Future<void> submitNgoRequest({
    required String organizationName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String registrationNumber,
    required String description,
    String? profileImageUrl,
  }) {
    final encodedPassword = base64Encode(utf8.encode(password));

    return _ngoRequests.add({
      'organizationName': organizationName,
      'email': email,
      'password': encodedPassword,
      'phone': phone,
      'address': address,
      'registrationNumber': registrationNumber,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUserModel?> getUserByUid(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      return null;
    }

    return AppUserModel.fromFirestore(doc);
  }

  Stream<AppUserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      return AppUserModel.fromFirestore(doc);
    });
  }

  Future<AppUserModel?> getUserByEmail(String email) async {
    final query = await _users.where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isEmpty) {
      return null;
    }

    return AppUserModel.fromFirestore(query.docs.first);
  }

  Future<NgoRequestModel?> getNgoRequestByEmail(String email) async {
    final query =
        await _ngoRequests.where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isEmpty) {
      return null;
    }

    return NgoRequestModel.fromFirestore(query.docs.first);
  }

  Stream<List<AppUserModel>> usersByRole(String role) {
    return _users.where('role', isEqualTo: role).snapshots().map((snapshot) {
      final users = snapshot.docs.map(AppUserModel.fromFirestore).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  Stream<List<NgoRequestModel>> pendingNgoRequests() {
    return _ngoRequests
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map(NgoRequestModel.fromFirestore).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  Future<void> rejectNgoRequest(String requestId) {
    return _ngoRequests.doc(requestId).update({'status': 'rejected'});
  }

  Future<void> submitFeedback({
    required AppUserModel ngo,
    required AppUserModel donor,
    required String feedbackText,
    required int rating,
  }) {
    return _feedback.add({
      'ngoId': ngo.uid,
      'ngoName': ngo.displayName,
      'ngoProfileImage': ngo.profileImageUrl,
      'donorId': donor.uid,
      'donorName': donor.displayName,
      'donorProfileImage': donor.profileImageUrl,
      'feedbackText': feedbackText.trim(),
      'rating': rating,
      'submittedByRole': 'ngo',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitDonorFeedback({
    required AppUserModel donor,
    required AppUserModel ngo,
    required String feedbackText,
    required int rating,
  }) {
    return _feedback.add({
      'donorId': donor.uid,
      'donorName': donor.displayName,
      'donorProfileImage': donor.profileImageUrl,
      'ngoId': ngo.uid,
      'ngoName': ngo.displayName,
      'ngoProfileImage': ngo.profileImageUrl,
      'feedbackText': feedbackText.trim(),
      'rating': rating,
      'submittedByRole': 'donor',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FeedbackModel>> feedbackStream() {
    return _feedback.orderBy('timestamp', descending: true).snapshots().map((
      snapshot,
    ) {
      final feedbackItems =
          snapshot.docs.map(FeedbackModel.fromFirestore).toList();
      feedbackItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return feedbackItems;
    });
  }

  Future<AppUserModel> approveNgoRequest(NgoRequestModel request) async {
    final defaultApp = Firebase.app();
    final secondaryName = 'ngo-approval-${request.id}';
    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: secondaryName,
        options: defaultApp.options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await _createOrRecoverNgoAuthUser(
        auth: secondaryAuth,
        email: request.email,
        password: request.decodePassword(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'NGO authentication account could not be created.',
        );
      }

      await _users.doc(firebaseUser.uid).set({
        'organizationName': request.organizationName,
        'email': request.email,
        'phone': request.phone,
        'address': request.address,
        'registrationNumber': request.registrationNumber,
        'organizationDescription': request.description,
        'profileImageUrl': request.profileImageUrl,
        'role': 'ngo',
        'approvedByAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _createNotification(
        email: request.email,
        uid: firebaseUser.uid,
        title: 'NGO Request Approved',
        message:
            'Your NGO registration request has been approved. You can now login.',
      );

      await _ngoRequests.doc(request.id).delete();

      final user = await getUserByUid(firebaseUser.uid);
      if (user == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: 'NGO user document was not created correctly.',
        );
      }

      return user;
    } finally {
      if (secondaryApp != null) {
        await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
        await secondaryApp.delete();
      }
    }
  }

  Future<UserCredential> _createOrRecoverNgoAuthUser({
    required FirebaseAuth auth,
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        rethrow;
      }

      return auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  Future<void> deleteUserDocument(String uid) {
    return _users.doc(uid).delete();
  }

  Future<AppUserModel> updateUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));

    final updatedUser = await getUserByUid(uid);
    if (updatedUser == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'User document could not be refreshed after update.',
      );
    }

    return updatedUser;
  }

  Future<void> createNgoRejectionNotification(NgoRequestModel request) {
    return _createNotification(
      email: request.email,
      title: 'NGO Request Rejected',
      message:
          'Your NGO registration request was rejected by admin. Please contact support.',
    );
  }

  Stream<List<Map<String, dynamic>>> notificationsForUser({
    String? uid,
    String? email,
  }) {
    if (uid != null && uid.isNotEmpty) {
      return _notifications
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );
    }

    if (email != null && email.isNotEmpty) {
      return _notifications
          .where('email', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );
    }

    return const Stream<List<Map<String, dynamic>>>.empty();
  }

  Future<void> _createNotification({
    required String email,
    required String title,
    required String message,
    String? uid,
  }) {
    return _notifications.add({
      'email': email,
      'uid': uid,
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
