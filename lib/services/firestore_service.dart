import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wastenot/features/admin/more/feedback/feedback_model.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/services/local_cache_service.dart';
import 'package:wastenot/services/notification_service.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const String _donorsByRoleCacheKey = 'users_by_role.donor';
  static const String _ngosByRoleCacheKey = 'users_by_role.ngo';
  static const String _feedbackCacheKey = 'feedback.all';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final LocalCacheService _cache = LocalCacheService();

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
      if (error.code == 'unauthorized') {
        throw FirebaseException(
          plugin: error.plugin,
          code: error.code,
          message: 'You do not have permission to upload donation images.',
        );
      }
      if (error.code == 'object-not-found') {
        return null;
      }
      rethrow;
    }
  }

  Future<String?> uploadDonationImage({
    required String donorId,
    required String donationId,
    File? imageFile,
  }) async {
    if (imageFile == null) {
      return null;
    }

    final segments = imageFile.path.split('.');
    final extension = segments.length > 1 ? segments.last : 'jpg';
    final ref = _storage.ref().child(
          'donation_images/$donorId/${donationId}_${DateTime.now().millisecondsSinceEpoch}.$extension',
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
    required String role,
    required String phone,
    required String address,
    required AppLocation location,
    required String about,
    bool emailVerified = false,
    String? profileImageUrl,
  }) {
    return _users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'location': location.toFirestore(),
      ...flatLocationFields(location),
      'about': about,
      'allowMessages': true,
      'notificationsEnabled': true,
      'emailVerified': emailVerified,
      'profileImageUrl': profileImageUrl,
      'role': role,
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
    AppLocation? location,
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
    if (location != null) {
      payload['location'] = locationToFirestore(location);
      payload.addAll(flatLocationFields(location));
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
    required String uid,
    required String organizationName,
    required String email,
    required String password,
    required String phone,
    required String address,
    AppLocation? location,
    required String registrationNumber,
    required String description,
    String? profileImageUrl,
  }) {
    final encodedPassword = base64Encode(utf8.encode(password));

    return _ngoRequests.add({
      'organizationName': organizationName,
      'email': email,
      'password': encodedPassword,
      'uid': uid,
      'phone': phone,
      'address': address,
      'location': locationToFirestore(location),
      ...flatLocationFields(location),
      'registrationNumber': registrationNumber,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'emailVerified': false,
      'status': 'email_verification_pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> syncUserEmailVerification({
    required String uid,
    required bool emailVerified,
  }) {
    return _users.doc(uid).set({
      'uid': uid,
      'emailVerified': emailVerified,
    }, SetOptions(merge: true));
  }

  Future<NgoRequestModel> markNgoRequestEmailVerified(NgoRequestModel request) async {
    final updatedData = <String, dynamic>{
      'emailVerified': true,
      'status': 'pending',
      'emailVerifiedAt': FieldValue.serverTimestamp(),
    };

    if ((request.uid ?? '').trim().isNotEmpty) {
      updatedData['uid'] = request.uid!.trim();
    }

    await _ngoRequests.doc(request.id).set(updatedData, SetOptions(merge: true));
    final refreshed = await _ngoRequests.doc(request.id).get();
    return NgoRequestModel.fromFirestore(refreshed);
  }

  Future<AppUserModel?> getUserByUid(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) {
        return null;
      }

      final user = AppUserModel.fromFirestore(doc);
      await _cache.saveAppUser(user);
      return user;
    } on FirebaseException {
      return _cache.getAppUser(uid);
    }
  }

  Stream<AppUserModel?> userStream(String uid) async* {
    final cached = await _cache.getAppUser(uid);
    if (cached != null) {
      yield cached;
    }

    try {
      await for (final doc in _users.doc(uid).snapshots()) {
        if (!doc.exists) {
          yield null;
          continue;
        }

        final user = AppUserModel.fromFirestore(doc);
        await _cache.saveAppUser(user);
        yield user;
      }
    } on FirebaseException {
      final fallback = await _cache.getAppUser(uid);
      if (fallback != null) {
        yield fallback;
      }
    }
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

  Stream<List<AppUserModel>> usersByRole(String role) async* {
    final cacheKey = _usersByRoleCacheKey(role);
    final cachedUsers = await _cache.getMapList(cacheKey);
    if (cachedUsers.isNotEmpty) {
      yield cachedUsers.map(_appUserFromMap).toList();
    }

    try {
      await for (final snapshot in _users.where('role', isEqualTo: role).snapshots()) {
        final users = snapshot.docs.map(AppUserModel.fromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await _cache.saveMapList(
          cacheKey,
          users.map(_appUserToMap).toList(),
        );
        yield users;
      }
    } on FirebaseException {
      final fallback = await _cache.getMapList(cacheKey);
      if (fallback.isNotEmpty) {
        yield fallback.map(_appUserFromMap).toList();
      }
    }
  }

  Stream<List<AppUserModel>> registeredNgos() {
    return usersByRole('ngo');
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
    return _submitFeedbackRecord(
      donor: donor,
      ngo: ngo,
      feedbackText: feedbackText,
      rating: rating,
      submittedByRole: 'ngo',
    );
  }

  Future<void> submitDonorFeedback({
    required AppUserModel donor,
    required AppUserModel ngo,
    required String feedbackText,
    required int rating,
  }) {
    return _submitFeedbackRecord(
      donor: donor,
      ngo: ngo,
      feedbackText: feedbackText,
      rating: rating,
      submittedByRole: 'donor',
    );
  }

  Future<void> _submitFeedbackRecord({
    required AppUserModel donor,
    required AppUserModel ngo,
    required String feedbackText,
    required int rating,
    required String submittedByRole,
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
      'submittedByRole': submittedByRole,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FeedbackModel>> feedbackStream() async* {
    final cachedFeedback = await _cache.getMapList(_feedbackCacheKey);
    if (cachedFeedback.isNotEmpty) {
      yield cachedFeedback.map(_feedbackFromMap).toList();
    }

    try {
      await for (final snapshot
          in _feedback.orderBy('timestamp', descending: true).snapshots()) {
        final feedbackItems = snapshot.docs.map(FeedbackModel.fromFirestore).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        await _cache.saveMapList(
          _feedbackCacheKey,
          feedbackItems.map(_feedbackToMap).toList(),
        );
        yield feedbackItems;
      }
    } on FirebaseException {
      final fallback = await _cache.getMapList(_feedbackCacheKey);
      if (fallback.isNotEmpty) {
        yield fallback.map(_feedbackFromMap).toList();
      }
    }
  }

  Future<AppUserModel> approveNgoRequest(NgoRequestModel request) async {
    final requestUid = request.uid?.trim() ?? '';
    if (requestUid.isNotEmpty) {
      await _users.doc(requestUid).set({
        'uid': requestUid,
        'organizationName': request.organizationName,
        'email': request.email,
        'phone': request.phone,
        'address': request.address,
        'location': locationToFirestore(request.location),
        ...flatLocationFields(request.location),
        'registrationNumber': request.registrationNumber,
        'organizationDescription': request.description,
        'allowMessages': true,
        'notificationsEnabled': true,
        'emailVerified': request.emailVerified,
        'profileImageUrl': request.profileImageUrl,
        'role': 'ngo',
        'approvedByAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _ngoRequests.doc(request.id).delete();

      final user = await getUserByUid(requestUid);
      if (user == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: 'NGO user document was not created correctly.',
        );
      }

      return user;
    }

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
        'uid': firebaseUser.uid,
        'organizationName': request.organizationName,
        'email': request.email,
        'phone': request.phone,
        'address': request.address,
        'location': locationToFirestore(request.location),
        ...flatLocationFields(request.location),
        'registrationNumber': request.registrationNumber,
        'organizationDescription': request.description,
        'allowMessages': true,
        'notificationsEnabled': true,
        'emailVerified': request.emailVerified,
        'profileImageUrl': request.profileImageUrl,
        'role': 'ngo',
        'approvedByAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
  }) async* {
    final cacheKey = _notificationsCacheKey(uid: uid, email: email);
    final cachedItems = await _cache.getMapList(cacheKey);
    if (cachedItems.isNotEmpty) {
      yield cachedItems;
    }

    if (uid != null && uid.isNotEmpty) {
      try {
        await for (final snapshot
            in _notifications.where('uid', isEqualTo: uid).snapshots()) {
          final items =
              snapshot.docs.map((doc) => _notificationToMap(doc)).toList();
          items.sort((a, b) {
            final aDate = _notificationCreatedAt(a);
            final bDate = _notificationCreatedAt(b);
            return bDate.compareTo(aDate);
          });
          await _cache.saveMapList(cacheKey, items);
          yield items;
        }
      } on FirebaseException {
        final fallback = await _cache.getMapList(cacheKey);
        if (fallback.isNotEmpty) {
          yield fallback;
        }
      }
      return;
    }

    yield const <Map<String, dynamic>>[];
  }

  static DateTime _notificationCreatedAt(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }
    if (createdAt is DateTime) {
      return createdAt;
    }
    if (createdAt is String) {
      return DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _createNotification({
    required String email,
    required String title,
    required String message,
    String? uid,
  }) {
    return _createNotificationGuarded(
      email: email,
      title: title,
      message: message,
      uid: uid,
    );
  }

  Future<void> _createNotificationGuarded({
    required String email,
    required String title,
    required String message,
    String? uid,
  }) async {
    final trimmedUid = uid?.trim() ?? '';
    if (trimmedUid.isNotEmpty) {
      final enabled =
          await NotificationService(firestore: _firestore).isNotificationEnabled(
        trimmedUid,
      );
      if (!enabled) {
        return;
      }
    }

    await _notifications.add({
      'email': email,
      'uid': uid,
      'receiverId': trimmedUid.isEmpty ? null : trimmedUid,
      'title': title,
      'body': message,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _usersByRoleCacheKey(String role) {
    switch (role.trim()) {
      case 'ngo':
        return _ngosByRoleCacheKey;
      case 'donor':
        return _donorsByRoleCacheKey;
      default:
        return 'users_by_role.${role.trim()}';
    }
  }

  String _notificationsCacheKey({String? uid, String? email}) {
    final trimmedUid = uid?.trim();
    if (trimmedUid != null && trimmedUid.isNotEmpty) {
      return 'notifications.uid.$trimmedUid';
    }

    final trimmedEmail = email?.trim().toLowerCase();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      return 'notifications.email.$trimmedEmail';
    }

    return 'notifications.unknown';
  }

  Map<String, dynamic> _appUserToMap(AppUserModel user) {
    return <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'name': user.name,
      'phone': user.phone,
      'address': user.address,
      'location': user.location?.toFirestore(),
      'about': user.about,
      'profileImageUrl': user.profileImageUrl,
      'organizationName': user.organizationName,
      'registrationNumber': user.registrationNumber,
      'organizationDescription': user.organizationDescription,
      'allowMessages': user.allowMessages,
      'notificationsEnabled': user.notificationsEnabled,
      'emailVerified': user.emailVerified,
      'approvedByAdmin': user.approvedByAdmin,
      'status': user.status,
      'isSuspended': user.isSuspended,
      'suspensionReason': user.suspensionReason,
      'suspendedAt': user.suspendedAt?.toIso8601String(),
      'suspendedBy': user.suspendedBy,
    };
  }

  AppUserModel _appUserFromMap(Map<String, dynamic> data) {
    return AppUserModel(
      uid: data['uid']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'donor',
      createdAt:
          DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      location: AppLocation.fromDynamic(data['location']),
      about: data['about'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      organizationName: data['organizationName'] as String?,
      registrationNumber: data['registrationNumber'] as String?,
      organizationDescription: data['organizationDescription'] as String?,
      allowMessages: (data['allowMessages'] as bool?) ?? true,
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
      emailVerified: (data['emailVerified'] as bool?) ?? false,
      approvedByAdmin: (data['approvedByAdmin'] as bool?) ?? false,
      status: data['status'] as String?,
      isSuspended: (data['isSuspended'] as bool?) ?? false,
      suspensionReason: data['suspensionReason'] as String?,
      suspendedAt: DateTime.tryParse(data['suspendedAt']?.toString() ?? ''),
      suspendedBy: data['suspendedBy'] as String?,
    );
  }

  Map<String, dynamic> _feedbackToMap(FeedbackModel item) {
    return <String, dynamic>{
      'id': item.id,
      'donorId': item.donorId,
      'donorName': item.donorName,
      'donorProfileImage': item.donorProfileImage,
      'ngoId': item.ngoId,
      'ngoName': item.ngoName,
      'ngoProfileImage': item.ngoProfileImage,
      'feedbackText': item.feedbackText,
      'rating': item.rating,
      'submittedByRole': item.submittedByRole,
      'timestamp': item.timestamp.toIso8601String(),
    };
  }

  FeedbackModel _feedbackFromMap(Map<String, dynamic> data) {
    return FeedbackModel(
      id: data['id']?.toString() ?? '',
      donorId: data['donorId']?.toString() ?? '',
      donorName: data['donorName']?.toString() ?? '',
      donorProfileImage: data['donorProfileImage']?.toString(),
      ngoId: data['ngoId']?.toString() ?? '',
      ngoName: data['ngoName']?.toString() ?? '',
      ngoProfileImage: data['ngoProfileImage']?.toString(),
      feedbackText: data['feedbackText']?.toString() ?? '',
      rating: data['rating'] is num
          ? (data['rating'] as num).toInt()
          : int.tryParse(data['rating']?.toString() ?? '') ?? 0,
      submittedByRole: data['submittedByRole']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _notificationToMap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return <String, dynamic>{
      'id': doc.id,
      'email': data['email'],
      'uid': data['uid'],
      'receiverId': data['receiverId'],
      'title': data['title'],
      'body': data['body'],
      'message': data['message'],
      'createdAt': _dateToIso(data['createdAt']),
      'timestamp': _dateToIso(data['timestamp']),
    };
  }

  String? _dateToIso(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    final normalized = value?.toString();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
