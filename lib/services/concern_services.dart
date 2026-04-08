import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wastenot/features/admin/shared/services/admin_user_notification_service.dart';
import 'package:wastenot/services/local_cache_service.dart';

class ConcernModel {
  const ConcernModel({
    required this.concernId,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.ngoId,
    required this.ngoName,
    required this.createdAt,
    required this.expiryTime,
    required this.isActive,
    this.ngoEmail,
    this.imageStoragePath,
    this.durationLabel,
  });

  final String concernId;
  final String title;
  final String message;
  final String imageUrl;
  final String ngoId;
  final String ngoName;
  final DateTime createdAt;
  final DateTime expiryTime;
  final bool isActive;
  final String? ngoEmail;
  final String? imageStoragePath;
  final String? durationLabel;

  bool get isExpired => expiryTime.isBefore(DateTime.now());

  factory ConcernModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return ConcernModel(
      concernId: (data['concernId'] as String?) ?? doc.id,
      title: (data['title'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      ngoId: (data['ngoId'] as String?) ?? '',
      ngoName: (data['ngoName'] as String?) ?? '',
      ngoEmail: data['ngoEmail'] as String?,
      createdAt: _dateTime(data['createdAt']) ?? DateTime.now(),
      expiryTime: _dateTime(data['expiryTime']) ?? DateTime.now(),
      isActive: (data['isActive'] as bool?) ?? true,
      imageStoragePath: data['imageStoragePath'] as String?,
      durationLabel: data['durationLabel'] as String?,
    );
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class ConcernDurationOption {
  const ConcernDurationOption({
    required this.label,
    required this.duration,
  });

  final String label;
  final Duration duration;
}

class ConcernService {
  ConcernService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    AdminUserNotificationService? adminUserNotificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _adminUserNotificationService =
            adminUserNotificationService ?? AdminUserNotificationService();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final AdminUserNotificationService _adminUserNotificationService;
  final LocalCacheService _cache = LocalCacheService();

  CollectionReference<Map<String, dynamic>> get _concerns =>
      _firestore.collection('concerns');

  static const List<ConcernDurationOption> durationOptions = [
    ConcernDurationOption(label: '24 Hours', duration: Duration(hours: 24)),
    ConcernDurationOption(label: '2 Days', duration: Duration(days: 2)),
    ConcernDurationOption(label: '3 Days', duration: Duration(days: 3)),
    ConcernDurationOption(label: '1 Week', duration: Duration(days: 7)),
    ConcernDurationOption(label: '2 Weeks', duration: Duration(days: 14)),
  ];

  Future<void> createConcern({
    required String title,
    required String message,
    required String ngoId,
    required String ngoName,
    String? ngoEmail,
    File? imageFile,
    required Duration duration,
    required String durationLabel,
  }) async {
    final concernRef = _concerns.doc();
    final now = DateTime.now();
    final expiryTime = now.add(duration);

    String imageUrl = '';
    String? imageStoragePath;

    if (imageFile != null) {
      final segments = imageFile.path.split('.');
      final extension = segments.isEmpty ? null : segments.last.trim();
      final safeExtension =
          (extension == null || extension.isEmpty) ? 'jpg' : extension;
      imageStoragePath =
          'concerns/$ngoId/${concernRef.id}_${now.millisecondsSinceEpoch}.$safeExtension';
      final storageRef = _storage.ref().child(imageStoragePath);
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    await concernRef.set({
      'concernId': concernRef.id,
      'title': title.trim(),
      'message': message.trim(),
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'ngoId': ngoId,
      'ngoName': ngoName.trim(),
      'ngoEmail': ngoEmail?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiryTime': Timestamp.fromDate(expiryTime),
      'isActive': true,
      'durationLabel': durationLabel,
    });
  }

  Stream<List<ConcernModel>> getActiveConcerns() {
    return _streamConcerns(
      cacheKey: 'active',
      stream: _concerns.where('isActive', isEqualTo: true).snapshots(),
      sorter: (concerns) => concerns.sort((a, b) => a.expiryTime.compareTo(b.expiryTime)),
      filter: (concern) => concern.isActive && concern.expiryTime.isAfter(DateTime.now()),
    );
  }

  Stream<List<ConcernModel>> getAllConcerns() {
    return _streamConcerns(
      cacheKey: 'all',
      stream: _concerns.snapshots(),
      sorter: (concerns) => concerns.sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  Stream<List<ConcernModel>> getNgoConcerns(String ngoId) {
    return _streamConcerns(
      cacheKey: 'ngo.${ngoId.trim()}',
      stream: _concerns.where('ngoId', isEqualTo: ngoId).snapshots(),
      sorter: (concerns) => concerns.sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  Stream<List<ConcernModel>> _streamConcerns({
    required String cacheKey,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required void Function(List<ConcernModel> concerns) sorter,
    bool Function(ConcernModel concern)? filter,
  }) async* {
    final cached = await _cache.getConcernList(cacheKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    try {
      await for (final snapshot in stream) {
        final concerns = snapshot.docs.map(ConcernModel.fromFirestore).where((concern) {
          return filter == null ? true : filter(concern);
        }).toList();
        sorter(concerns);
        await _cache.saveConcernList(cacheKey, concerns);
        yield concerns;
      }
    } catch (error, stackTrace) {
      developer.log(
        'Concern stream fallback to cache.',
        name: 'ConcernService',
        error: error,
        stackTrace: stackTrace,
      );
      final fallback = await _cache.getConcernList(cacheKey);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
    }
  }

  Future<void> deleteConcern(
    String concernId, {
    bool deletedByAdmin = false,
    String? reason,
  }) async {
    final concernRef = _concerns.doc(concernId);
    final snapshot = await concernRef.get();
    if (!snapshot.exists) {
      return;
    }

    final concern = ConcernModel.fromFirestore(snapshot);
    await concernRef.delete();

    final imageStoragePath = concern.imageStoragePath?.trim();
    if (imageStoragePath != null && imageStoragePath.isNotEmpty) {
      try {
        await _storage.ref().child(imageStoragePath).delete();
      } on FirebaseException catch (_) {}
    } else if (concern.imageUrl.trim().isNotEmpty) {
      try {
        await _storage.refFromURL(concern.imageUrl).delete();
      } on FirebaseException catch (_) {}
    }

    if (!deletedByAdmin || concern.ngoId.trim().isEmpty) {
      return;
    }

    final removalReason = (reason ?? '').trim().isEmpty
        ? 'Removed by admin review'
        : reason!.trim();

    await _adminUserNotificationService.sendNotificationToNgoAndLog(
      ngoId: concern.ngoId,
      ngoName: concern.ngoName.trim().isEmpty ? 'NGO' : concern.ngoName,
      email: concern.ngoEmail,
      title: 'Concern Removed',
      message: 'Your concern was removed by admin. Reason: $removalReason',
    );
  }
}
