import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wastenot/core/utils/meal_parser.dart';
import 'package:wastenot/features/goal/services/goal_service.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/local_cache_service.dart';
import 'package:wastenot/services/location_service.dart';

enum DonationStatus {
  active('active'),
  accepted('accepted'),
  expired('expired'),
  completed('completed');

  const DonationStatus(this.value);

  final String value;

  static DonationStatus? fromValue(String? value) {
    for (final status in DonationStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return null;
  }
}

class DonationCreateRequest {
  const DonationCreateRequest({
    required this.foodItems,
    required this.quantity,
    this.description,
    this.precaution,
    required this.location,
    this.imageUrls = const <String>[],
    this.expiryAt,
  });

  final List<String> foodItems;
  final String quantity;
  final String? description;
  final String? precaution;
  final AppLocation location;
  final List<String> imageUrls;
  final DateTime? expiryAt;

  Map<String, dynamic> toFirestore() {
    final payload = <String, dynamic>{
      'foodItems': foodItems,
      'food': foodItems.join(', '),
      'quantity': quantity.trim(),
      'servings': quantity.trim(),
      'description': _normalizeNullable(description),
      'precaution': _normalizeNullable(precaution),
      'location': location.toFirestore(),
      'donationLatitude': location.latitude,
      'donationLongitude': location.longitude,
      'donationAddress': location.address,
      'imageUrls': imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
    };
    if (expiryAt != null) {
      payload['expiryAt'] = Timestamp.fromDate(expiryAt!);
      payload['expiresAt'] = Timestamp.fromDate(expiryAt!);
    }
    return payload;
  }
}

class DonationModel {
  const DonationModel({
    required this.donationId,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    required this.createdAt,
    required this.foodItems,
    required this.quantity,
    required this.status,
    this.donorPhone,
    this.donorAddress,
    this.donorProfileImageUrl,
    this.description,
    this.precaution,
    this.location,
    this.imageUrls = const <String>[],
    this.acceptedByNgoId,
    this.acceptedByNgoName,
    this.acceptedByNgoEmail,
    this.acceptedByNgoPhone,
    this.acceptedByNgoAddress,
    this.acceptedByNgoLocation,
    this.acceptedByNgoProfileImageUrl,
    this.acceptedAt,
    this.completedAt,
    this.expiryAt,
    this.expired = false,
    this.rejectedByNgoIds = const <String>[],
  });

  final String donationId;
  final String donorId;
  final String donorName;
  final String donorEmail;
  final String? donorPhone;
  final String? donorAddress;
  final String? donorProfileImageUrl;
  final List<String> foodItems;
  final String quantity;
  final String? description;
  final String? precaution;
  final AppLocation? location;
  final List<String> imageUrls;
  final String status;
  final String? acceptedByNgoId;
  final String? acceptedByNgoName;
  final String? acceptedByNgoEmail;
  final String? acceptedByNgoPhone;
  final String? acceptedByNgoAddress;
  final AppLocation? acceptedByNgoLocation;
  final String? acceptedByNgoProfileImageUrl;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? expiryAt;
  final bool expired;
  final List<String> rejectedByNgoIds;

  bool get isActive => status == DonationStatus.active.value;
  bool get isAccepted => status == DonationStatus.accepted.value;
  bool get isExpired =>
      expired ||
      status == DonationStatus.expired.value ||
      _shouldAutoExpireDonation(
        status: status,
        acceptedByNgoId: acceptedByNgoId,
        completedAt: completedAt,
        expiryAt: expiryAt,
      );
  bool get isCompleted => status == DonationStatus.completed.value;
  bool get hasAcceptedNgo =>
      acceptedByNgoId != null && acceptedByNgoId!.trim().isNotEmpty;

  DonationModel copyWith({
    String? donationId,
    String? donorId,
    String? donorName,
    String? donorEmail,
    String? donorPhone,
    String? donorAddress,
    String? donorProfileImageUrl,
    List<String>? foodItems,
    String? quantity,
    String? description,
    String? precaution,
    AppLocation? location,
    List<String>? imageUrls,
    String? status,
    String? acceptedByNgoId,
    String? acceptedByNgoName,
    String? acceptedByNgoEmail,
    String? acceptedByNgoPhone,
    String? acceptedByNgoAddress,
    AppLocation? acceptedByNgoLocation,
    String? acceptedByNgoProfileImageUrl,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? expiryAt,
    bool? expired,
    List<String>? rejectedByNgoIds,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      createdAt: createdAt ?? this.createdAt,
      foodItems: foodItems ?? this.foodItems,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      donorPhone: donorPhone ?? this.donorPhone,
      donorAddress: donorAddress ?? this.donorAddress,
      donorProfileImageUrl: donorProfileImageUrl ?? this.donorProfileImageUrl,
      description: description ?? this.description,
      precaution: precaution ?? this.precaution,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      acceptedByNgoId: acceptedByNgoId ?? this.acceptedByNgoId,
      acceptedByNgoName: acceptedByNgoName ?? this.acceptedByNgoName,
      acceptedByNgoEmail: acceptedByNgoEmail ?? this.acceptedByNgoEmail,
      acceptedByNgoPhone: acceptedByNgoPhone ?? this.acceptedByNgoPhone,
      acceptedByNgoAddress: acceptedByNgoAddress ?? this.acceptedByNgoAddress,
      acceptedByNgoLocation:
          acceptedByNgoLocation ?? this.acceptedByNgoLocation,
      acceptedByNgoProfileImageUrl:
          acceptedByNgoProfileImageUrl ?? this.acceptedByNgoProfileImageUrl,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      expiryAt: expiryAt ?? this.expiryAt,
      expired: expired ?? this.expired,
      rejectedByNgoIds: rejectedByNgoIds ?? this.rejectedByNgoIds,
    );
  }

  Map<String, dynamic> toFirestore() {
    final effectiveExpiryAt = expiryAt ?? _defaultExpiryAtForCreatedAt(createdAt);
    return {
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'donorEmail': donorEmail,
      'donorPhone': donorPhone,
      'donorAddress': donorAddress,
      'donorProfileImageUrl': donorProfileImageUrl,
      'foodItems': foodItems,
      'quantity': quantity,
      'servings': quantity,
      'description': description,
      'precaution': precaution,
      'location': locationToFirestore(location),
      'imageUrls': imageUrls,
      'status': status,
      'acceptedByNgoId': acceptedByNgoId,
      'acceptedByNgoName': acceptedByNgoName,
      'acceptedByNgoEmail': acceptedByNgoEmail,
      'acceptedByNgoPhone': acceptedByNgoPhone,
      'acceptedByNgoAddress': acceptedByNgoAddress,
      'acceptedByNgoLocation': locationToFirestore(acceptedByNgoLocation),
      'acceptedByNgoProfileImageUrl': acceptedByNgoProfileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt == null ? null : Timestamp.fromDate(acceptedAt!),
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'expiryAt': Timestamp.fromDate(effectiveExpiryAt),
      'expiresAt': Timestamp.fromDate(effectiveExpiryAt),
      'expired': expired,
      'rejectedByNgoIds': rejectedByNgoIds,
    };
  }

  factory DonationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawFoodItems = data['foodItems'];
    final normalizedFoodItems = rawFoodItems is List
        ? rawFoodItems
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[
            if ((data['foodItems'] as String?)?.trim().isNotEmpty ?? false)
              (data['foodItems'] as String).trim(),
          ];
    final rawImageUrls = data['imageUrls'];
    final normalizedImageUrls = rawImageUrls is List
        ? rawImageUrls
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];
    final rawRejectedNgoIds = data['rejectedByNgoIds'];
    final normalizedRejectedNgoIds = rawRejectedNgoIds is List
        ? rawRejectedNgoIds
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];
    final donorId = (data['donorId'] as String?)?.trim();
    final createdAt = _dateFromFirestore(data['createdAt']) ?? DateTime.now();
    final status =
        (data['status'] as String?)?.trim() ?? DonationStatus.active.value;
    final acceptedByNgoId =
        _normalizeNullable(data['acceptedByNgoId'] as String?);
    final completedAt = _dateFromFirestore(data['completedAt']);
    final resolvedExpiryAt =
        _dateFromFirestore(data['expiresAt']) ??
        _dateFromFirestore(data['expiryAt']) ??
        _defaultExpiryAtForCreatedAt(createdAt);
    final shouldAutoExpire = _shouldAutoExpireDonation(
      status: status,
      acceptedByNgoId: acceptedByNgoId,
      completedAt: completedAt,
      expiryAt: resolvedExpiryAt,
    );
    final resolvedExpired =
        (data['expired'] as bool?) == true ||
        status == DonationStatus.expired.value ||
        shouldAutoExpire;
    final donationLocation =
        AppLocation.fromDynamic(data['location']) ??
        _locationFromLegacyDonationFields(data) ??
        AppLocation.fromDynamic(data['pickupLocation']);
    final acceptedByNgoLocation =
        AppLocation.fromDynamic(data['acceptedByNgoLocation']);

    return DonationModel(
      donationId: ((data['donationId'] as String?)?.trim().isNotEmpty ?? false)
          ? (data['donationId'] as String).trim()
          : doc.id,
      donorId: donorId?.isNotEmpty == true ? donorId! : '',
      donorName: (data['donorName'] as String?)?.trim() ?? '',
      donorEmail: (data['donorEmail'] as String?)?.trim() ?? '',
      donorPhone: _normalizeNullable(data['donorPhone'] as String?),
      donorAddress: _normalizeNullable(data['donorAddress'] as String?),
      donorProfileImageUrl:
          _normalizeNullable(data['donorProfileImageUrl'] as String?),
      foodItems: normalizedFoodItems,
      quantity: _resolveQuantity(data),
      description: _normalizeNullable(data['description'] as String?),
      precaution: _normalizeNullable(data['precaution'] as String?),
      location: donationLocation,
      imageUrls: normalizedImageUrls,
      status: resolvedExpired ? DonationStatus.expired.value : status,
      acceptedByNgoId: acceptedByNgoId,
      acceptedByNgoName:
          _normalizeNullable(data['acceptedByNgoName'] as String?),
      acceptedByNgoEmail:
          _normalizeNullable(data['acceptedByNgoEmail'] as String?),
      acceptedByNgoPhone:
          _normalizeNullable(data['acceptedByNgoPhone'] as String?),
      acceptedByNgoAddress:
          _normalizeNullable(data['acceptedByNgoAddress'] as String?),
      acceptedByNgoLocation: acceptedByNgoLocation,
      acceptedByNgoProfileImageUrl:
          _normalizeNullable(data['acceptedByNgoProfileImageUrl'] as String?),
      createdAt: createdAt,
      acceptedAt: _dateFromFirestore(data['acceptedAt']),
      completedAt: completedAt,
      expiryAt: resolvedExpiryAt,
      expired: resolvedExpired,
      rejectedByNgoIds: normalizedRejectedNgoIds,
    );
  }
}

class DonationService {
  DonationService({
    FirebaseFirestore? firestore,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _locationService = locationService ?? const LocationService();

  final FirebaseFirestore _firestore;
  final LocationService _locationService;
  final LocalCacheService _cache = LocalCacheService();

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  String createDraftDonationId() => _donations.doc().id;

  Future<DonationModel> createDonation({
    required AppUserModel donor,
    String? donationId,
    required DonationCreateRequest request,
  }) async {
    if (!donor.isDonor) {
      throw const DonationException(
        'Only donors can create donations.',
      );
    }

    if (request.foodItems.isEmpty) {
      throw const DonationException(
        'Please add at least one food item for the donation.',
      );
    }

    if (request.quantity.trim().isEmpty) {
      throw const DonationException(
        'Please provide quantity or servings for the donation.',
      );
    }

    final docRef = donationId == null || donationId.trim().isEmpty
        ? _donations.doc()
        : _donations.doc(donationId.trim());
    final expiresAt = DateTime.now().add(_donationExpiryWindow);
    final payload = <String, dynamic>{
      'donationId': docRef.id,
      'donorId': donor.uid,
      'donorName': donor.displayName,
      'donorEmail': donor.email.trim(),
      'donorPhone': _normalizeNullable(donor.phone),
      'donorAddress': _normalizeNullable(donor.address),
      'donorProfileImageUrl': _normalizeNullable(donor.profileImageUrl),
      'status': DonationStatus.active.value,
      'acceptedByNgoId': null,
      'acceptedByNgoName': null,
      'acceptedByNgoEmail': null,
      'acceptedByNgoPhone': null,
      'acceptedByNgoAddress': null,
      'acceptedByNgoProfileImageUrl': null,
      'acceptedAt': null,
      'completedAt': null,
      ...request.toFirestore(),
      'notificationSent': false,
      'expiringSoonNotificationSent': false,
      'expired': false,
      'expiryAt': Timestamp.fromDate(expiresAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(payload);
      final snapshot = await docRef.get();
      return DonationModel.fromFirestore(snapshot);
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Future<DonationModel> getDonationById(String donationId) async {
    if (donationId.trim().isEmpty) {
      throw const DonationException('Donation id is required.');
    }

    try {
      final doc = await _donations.doc(donationId.trim()).get();
      if (!doc.exists) {
        throw const DonationException('Donation not found.');
      }
      var donation =
          await _resolveDonationLocation(DonationModel.fromFirestore(doc));
      donation = _normalizeDonationForDisplay(donation);
      _syncExpiredDonationIfNeeded(doc.reference, donation);
      await _cache.saveDonationList(
        _cacheKeyForSingleDonation(donationId.trim()),
        <DonationModel>[donation],
      );
      return donation;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForSingleDonation(donationId.trim()),
      );
      if (cached.isNotEmpty) {
        return cached.first;
      }
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Future<List<DonationModel>> getAllDonations({
    DonationStatus? status,
  }) async {
    try {
      debugPrint(
        '[DonationService] getAllDonations(status: ${status?.value ?? 'all'})',
      );
      Query<Map<String, dynamic>> query = _donations;
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      final snapshot = await query.get();
      final donations = await Future.wait(
        snapshot.docs
            .map(DonationModel.fromFirestore)
            .map(_resolveDonationLocation),
      );
      final filtered = donations.toList();
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _cache.saveDonationList(
        _cacheKeyForAllDonations(status: status),
        filtered,
      );
      debugPrint(
        '[DonationService] getAllDonations -> ${filtered.length} results',
      );
      return filtered;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForAllDonations(status: status),
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[DonationService] getAllDonations FirebaseException(${error.code}): ${error.message}',
      );
      throw DonationException(_mapFirebaseError(error));
    } catch (error) {
      debugPrint('[DonationService] getAllDonations error: $error');
      throw DonationException('Failed to load donations: $error');
    }
  }

  Future<List<DonationModel>> getDonorDonations({
    required String donorId,
    DonationStatus? status,
  }) async {
    if (donorId.trim().isEmpty) {
      throw const DonationException('Donor id is required.');
    }

    try {
      final normalizedDonorId = donorId.trim();
      debugPrint(
        '[DonationService] getDonorDonations(donorId: $normalizedDonorId, status: ${status?.value ?? 'all'})',
      );
      final query = _donations.where(
        'donorId',
        isEqualTo: normalizedDonorId,
      );
      final snapshot = await query.get();
      final donations = await Future.wait(snapshot.docs.map((doc) async {
        var donation = await _resolveDonationLocation(
          DonationModel.fromFirestore(doc),
        );
        donation = _normalizeDonationForDisplay(donation);
        _syncExpiredDonationIfNeeded(doc.reference, donation);
        return donation;
      }));
      final filtered = donations
          .where((donation) => status == null || donation.status == status.value)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _cache.saveDonationList(
        _cacheKeyForDonorDonations(donorId: normalizedDonorId, status: status),
        filtered,
      );
      debugPrint(
        '[DonationService] getDonorDonations -> ${filtered.length} results for donorId=$normalizedDonorId',
      );
      return filtered;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForDonorDonations(donorId: donorId.trim(), status: status),
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[DonationService] getDonorDonations FirebaseException(${error.code}): ${error.message}',
      );
      throw DonationException(_mapFirebaseError(error));
    } catch (error) {
      debugPrint('[DonationService] getDonorDonations error: $error');
      throw DonationException('Failed to load donor donations: $error');
    }
  }

  Future<List<DonationModel>> getAvailableDonationsForNgo({
    String? ngoId,
    DateTime? now,
  }) async {
    try {
      debugPrint('[DonationService] getAvailableDonationsForNgo()');
      final snapshot = await _donations
          .where('status', isEqualTo: DonationStatus.active.value)
          .where('acceptedByNgoId', isNull: true)
          .get();

      final referenceTime = now ?? DateTime.now();
      final donations = await Future.wait(snapshot.docs.map((doc) async {
        var donation = await _resolveDonationLocation(
          DonationModel.fromFirestore(doc),
        );
        donation = _normalizeDonationForDisplay(donation);
        _syncExpiredDonationIfNeeded(doc.reference, donation);
        return donation;
      }));
      final filtered = donations.where((donation) {
        if (donation.status != DonationStatus.active.value || donation.isExpired) {
          return false;
        }
        if (donation.hasAcceptedNgo) {
          return false;
        }
        if (ngoId != null &&
            ngoId.trim().isNotEmpty &&
            donation.rejectedByNgoIds.contains(ngoId.trim())) {
          return false;
        }
        final expiryAt = donation.expiryAt;
        return expiryAt == null || !expiryAt.isBefore(referenceTime);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _cache.saveDonationList(
        _cacheKeyForAvailableNgoDonations(ngoId: ngoId),
        filtered,
      );
      debugPrint(
        '[DonationService] getAvailableDonationsForNgo -> ${filtered.length} results',
      );
      return filtered;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForAvailableNgoDonations(ngoId: ngoId),
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[DonationService] getAvailableDonationsForNgo FirebaseException(${error.code}): ${error.message}',
      );
      throw DonationException(_mapFirebaseError(error));
    } catch (error) {
      debugPrint('[DonationService] getAvailableDonationsForNgo error: $error');
      throw DonationException('Failed to load available donations: $error');
    }
  }

  Future<List<DonationModel>> getNgoAcceptedDonations({
    required String ngoId,
    DonationStatus? status,
  }) async {
    if (ngoId.trim().isEmpty) {
      throw const DonationException('NGO id is required.');
    }

    try {
      final normalizedNgoId = ngoId.trim();
      debugPrint(
        '[DonationService] getNgoAcceptedDonations(ngoId: $normalizedNgoId, status: ${status?.value ?? 'all'})',
      );
      Query<Map<String, dynamic>> query = _donations.where(
        'acceptedByNgoId',
        isEqualTo: normalizedNgoId,
      );
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      final snapshot = await query.get();
      final donations = await Future.wait(
        snapshot.docs
            .map(DonationModel.fromFirestore)
            .map(_resolveDonationLocation),
      );
      final filtered = donations.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _cache.saveDonationList(
        _cacheKeyForNgoAcceptedDonations(ngoId: normalizedNgoId, status: status),
        filtered,
      );
      debugPrint(
        '[DonationService] getNgoAcceptedDonations -> ${filtered.length} results for ngoId=$normalizedNgoId',
      );
      return filtered;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForNgoAcceptedDonations(ngoId: ngoId.trim(), status: status),
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[DonationService] getNgoAcceptedDonations FirebaseException(${error.code}): ${error.message}',
      );
      throw DonationException(_mapFirebaseError(error));
    } catch (error) {
      debugPrint('[DonationService] getNgoAcceptedDonations error: $error');
      throw DonationException('Failed to load NGO donations: $error');
    }
  }

  Future<List<DonationModel>> getRecentCompletedDonations({
    int limit = 3,
  }) async {
    if (limit <= 0) {
      return const <DonationModel>[];
    }

    try {
      debugPrint(
        '[DonationService] getRecentCompletedDonations(limit: $limit)',
      );
      final snapshot = await _donations
          .where('status', isEqualTo: DonationStatus.completed.value)
          .get();
      final donations = await Future.wait(
        snapshot.docs
            .map(DonationModel.fromFirestore)
            .map(_resolveDonationLocation),
      );
      donations.sort((a, b) {
        final aTime = a.completedAt ?? a.createdAt;
        final bTime = b.completedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      final recent = donations.take(limit).toList();
      await _cache.saveDonationList(
        _cacheKeyForRecentCompleted(limit: limit),
        recent,
      );
      debugPrint(
        '[DonationService] getRecentCompletedDonations -> ${recent.length} results',
      );
      return recent;
    } on FirebaseException catch (error) {
      final cached = await _cache.getDonationList(
        _cacheKeyForRecentCompleted(limit: limit),
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[DonationService] getRecentCompletedDonations FirebaseException(${error.code}): ${error.message}',
      );
      throw DonationException(_mapFirebaseError(error));
    } catch (error) {
      debugPrint('[DonationService] getRecentCompletedDonations error: $error');
      throw DonationException(
        'Failed to load recent completed donations: $error',
      );
    }
  }

  Future<DonationModel> acceptDonation({
    required String donationId,
    required AppUserModel ngo,
  }) async {
    if (!ngo.isNgo) {
      throw const DonationException(
        'Only NGO accounts can accept donations.',
      );
    }

    if (donationId.trim().isEmpty) {
      throw const DonationException('Donation id is required.');
    }

    final docRef = _donations.doc(donationId.trim());

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const DonationException('Donation not found.');
        }

        final donation = DonationModel.fromFirestore(snapshot);
        final now = DateTime.now();

        if (!donation.isActive || donation.isExpired) {
          throw const DonationException(
            'Only active donations can be accepted.',
          );
        }

        if (donation.expiryAt != null && donation.expiryAt!.isBefore(now)) {
          throw const DonationException(
            'This donation has already expired.',
          );
        }

        if (donation.hasAcceptedNgo) {
          throw const DonationException(
            'This donation has already been accepted by another NGO.',
          );
        }

        transaction.update(docRef, {
          'status': DonationStatus.accepted.value,
          'expired': false,
          'acceptedByNgoId': ngo.uid,
          'acceptedByNgoName': ngo.displayName,
          'acceptedByNgoEmail': ngo.email.trim(),
          'acceptedByNgoPhone': _normalizeNullable(ngo.phone),
          'acceptedByNgoAddress': _normalizeNullable(ngo.address),
          'acceptedByNgoLocation': locationToFirestore(ngo.location),
          'acceptedByNgoProfileImageUrl': _normalizeNullable(
            ngo.profileImageUrl,
          ),
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });

      return getDonationById(donationId);
    } on DonationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Future<DonationModel> rejectDonation({
    required String donationId,
    required AppUserModel ngo,
  }) async {
    if (!ngo.isNgo) {
      throw const DonationException('Only NGO accounts can reject donations.');
    }

    if (donationId.trim().isEmpty) {
      throw const DonationException('Donation id is required.');
    }

    final docRef = _donations.doc(donationId.trim());

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const DonationException('Donation not found.');
        }

        final donation = DonationModel.fromFirestore(snapshot);
        if (!donation.isActive) {
          throw const DonationException(
            'Only active donations can be rejected.',
          );
        }

        transaction.update(docRef, {
          'rejectedByNgoIds': FieldValue.arrayUnion(<String>[ngo.uid]),
        });
      });

      return getDonationById(donationId);
    } on DonationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Future<DonationModel> markDonationCompleted({
    required String donationId,
  }) async {
    if (donationId.trim().isEmpty) {
      throw const DonationException('Donation id is required.');
    }

    final docRef = _donations.doc(donationId.trim());

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const DonationException('Donation not found.');
        }

        final donation = DonationModel.fromFirestore(snapshot);
        if (donation.status == DonationStatus.completed.value) {
          return;
        }

        if (donation.status == DonationStatus.expired.value) {
          throw const DonationException(
            'Expired donations cannot be completed.',
          );
        }

        if (donation.status != DonationStatus.accepted.value) {
          throw const DonationException(
            'Only accepted donations can be marked as completed.',
          );
        }

        transaction.update(docRef, {
          'status': DonationStatus.completed.value,
          'expired': false,
          'completedAt': FieldValue.serverTimestamp(),
        });
      });

      GoalService.refreshNotifier.value++;

      return getDonationById(donationId);
    } on DonationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Future<DonationModel> markDonationAsComplete(String donationId) {
    return markDonationCompleted(donationId: donationId);
  }

  Future<DonationModel> markDonationExpired({
    required String donationId,
    DateTime? expiredAt,
  }) async {
    if (donationId.trim().isEmpty) {
      throw const DonationException('Donation id is required.');
    }

    final docRef = _donations.doc(donationId.trim());

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const DonationException('Donation not found.');
        }

        final donation = DonationModel.fromFirestore(snapshot);
        if (donation.status == DonationStatus.completed.value) {
          throw const DonationException(
            'Completed donations cannot be marked as expired.',
          );
        }

        if (donation.status == DonationStatus.expired.value) {
          return;
        }

        if (donation.status != DonationStatus.active.value) {
          throw const DonationException(
            'Only active donations can be marked as expired.',
          );
        }

        final effectiveExpiry = expiredAt ?? donation.expiryAt ?? DateTime.now();
        transaction.update(docRef, {
          'status': DonationStatus.expired.value,
          'expired': true,
          'expiryAt': Timestamp.fromDate(effectiveExpiry),
          'expiresAt': Timestamp.fromDate(effectiveExpiry),
        });
      });

      return getDonationById(donationId);
    } on DonationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
  }

  Stream<List<DonationModel>> streamDonationsByStatus({
    DonationStatus? status,
    String? donorId,
    String? ngoId,
    bool onlyAvailableForNgo = false,
    bool orderByCreatedAt = true,
  }) async* {
    Query<Map<String, dynamic>> query = _donations;
    final effectiveStatus =
        onlyAvailableForNgo ? DonationStatus.active : status;
    final cacheKey = _cacheKeyForStatusStream(
      status: effectiveStatus,
      donorId: donorId,
      ngoId: ngoId,
      onlyAvailableForNgo: onlyAvailableForNgo,
      orderByCreatedAt: orderByCreatedAt,
    );

    if (donorId != null && donorId.trim().isNotEmpty) {
      query = query.where('donorId', isEqualTo: donorId.trim());
    }

    if (!onlyAvailableForNgo && ngoId != null && ngoId.trim().isNotEmpty) {
      query = query.where('acceptedByNgoId', isEqualTo: ngoId.trim());
    }

    if (effectiveStatus != null) {
      query = query.where('status', isEqualTo: effectiveStatus.value);
    }

    if (onlyAvailableForNgo) {
      query = query.where('acceptedByNgoId', isNull: true);
    }

    final effectiveQuery = orderByCreatedAt
        ? query.orderBy('createdAt', descending: true)
        : query;

    final cached = await _cache.getDonationList(cacheKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    try {
      await for (final snapshot in effectiveQuery.snapshots()) {
        final now = DateTime.now();
        final donations = snapshot.docs.map((doc) {
          final donation = _normalizeDonationForDisplay(
            DonationModel.fromFirestore(doc),
          );
          _syncExpiredDonationIfNeeded(doc.reference, donation);
          return donation;
        }).toList();
        final result = donations.where((donation) {
          if (status != null && donation.status != status.value) {
            return false;
          }
          if (!onlyAvailableForNgo) {
            return true;
          }
          if (donation.isExpired || donation.hasAcceptedNgo) {
            return false;
          }
          if (ngoId != null &&
              ngoId.trim().isNotEmpty &&
              donation.rejectedByNgoIds.contains(ngoId.trim())) {
            return false;
          }
          final expiryAt = donation.expiryAt;
          return expiryAt == null || !expiryAt.isBefore(now);
        }).toList();
        await _cache.saveDonationList(cacheKey, result);
        yield result;
      }
    } on FirebaseException {
      final fallback = await _cache.getDonationList(cacheKey);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
    }
  }

  Stream<List<DonationModel>> streamRecentCompletedDonationsForDonor({
    required String donorId,
    int limit = 3,
  }) async* {
    final normalizedDonorId = donorId.trim();
    if (normalizedDonorId.isEmpty || limit <= 0) {
      yield const <DonationModel>[];
      return;
    }

    final cacheKey =
        'donation.donor.recent_completed.$normalizedDonorId.$limit';
    final cached = await _cache.getDonationList(cacheKey);
    if (cached.isNotEmpty) {
      yield cached;
    }

    try {
      await for (final snapshot in _donations
          .where('donorId', isEqualTo: normalizedDonorId)
          .where('status', isEqualTo: DonationStatus.completed.value)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .snapshots()) {
        final donations = await Future.wait(
          snapshot.docs
              .map(DonationModel.fromFirestore)
              .map(_resolveDonationLocation),
        );

        var result = donations.toList()
          ..sort((a, b) {
            final aTime = a.completedAt ?? a.createdAt;
            final bTime = b.completedAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

        if (result.length < limit) {
          final fallbackSnapshot = await _donations
              .where('donorId', isEqualTo: normalizedDonorId)
              .where('status', isEqualTo: DonationStatus.completed.value)
              .get();
          final fallbackDonations = await Future.wait(
            fallbackSnapshot.docs
                .map(DonationModel.fromFirestore)
                .map(_resolveDonationLocation),
          );
          result = fallbackDonations
            ..sort((a, b) {
              final aTime = a.completedAt ?? a.createdAt;
              final bTime = b.completedAt ?? b.createdAt;
              return bTime.compareTo(aTime);
            });
        }

        final limited = result.take(limit).toList();
        await _cache.saveDonationList(cacheKey, limited);
        yield limited;
      }
    } on FirebaseException {
      final fallback = await _cache.getDonationList(cacheKey);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
    }
  }

String _mapFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this donation action.';
      case 'unavailable':
        return 'Donation service is unavailable right now. Please try again.';
      case 'not-found':
        return 'Donation not found.';
      case 'aborted':
        return 'This donation was updated by another user. Please try again.';
      default:
        return error.message ?? 'Something went wrong while handling donations.';
    }
  }

  Future<DonationModel> _resolveDonationLocation(DonationModel donation) async {
    if (donation.location != null || donation.donorId.trim().isEmpty) {
      return donation;
    }

    try {
      final donorDoc = await _users.doc(donation.donorId).get();
      final donorData = donorDoc.data();
      if (donorData != null) {
        final donorLocation = AppLocation.fromDynamic(donorData['location']);
        if (donorLocation != null) {
          return _copyDonationWithLocation(donation, donorLocation);
        }
      }

      final fallbackAddress =
          donation.locationAddress ??
          (donorData?['address'] as String?)?.trim() ??
          donation.donorAddress;
      if (fallbackAddress == null || fallbackAddress.trim().isEmpty) {
        return donation;
      }

      final matches = await _locationService.searchLocations(fallbackAddress);
      if (matches.isEmpty) {
        return donation;
      }

      return _copyDonationWithLocation(donation, matches.first);
    } catch (_) {
      return donation;
    }
  }

  DonationModel _copyDonationWithLocation(
    DonationModel donation,
    AppLocation location,
  ) {
    return donation.copyWith(location: location);
  }

  DonationModel _normalizeDonationForDisplay(
    DonationModel donation, {
    DateTime? referenceTime,
  }) {
    final effectiveExpiryAt =
        donation.expiryAt ?? _defaultExpiryAtForCreatedAt(donation.createdAt);
    final shouldAutoExpire = _shouldAutoExpireDonation(
      status: donation.status,
      acceptedByNgoId: donation.acceptedByNgoId,
      completedAt: donation.completedAt,
      expiryAt: effectiveExpiryAt,
      referenceTime: referenceTime,
    );

    return donation.copyWith(
      expiryAt: effectiveExpiryAt,
      expired: donation.expired || shouldAutoExpire,
      status: shouldAutoExpire ? DonationStatus.expired.value : donation.status,
    );
  }

  void _syncExpiredDonationIfNeeded(
    DocumentReference<Map<String, dynamic>> reference,
    DonationModel donation,
  ) {
    if (!donation.isExpired || donation.status != DonationStatus.expired.value) {
      return;
    }

    unawaited(
      reference.set({
        'status': DonationStatus.expired.value,
        'expired': true,
        'expiryAt': donation.expiryAt == null
            ? null
            : Timestamp.fromDate(donation.expiryAt!),
        'expiresAt': donation.expiryAt == null
            ? null
            : Timestamp.fromDate(donation.expiryAt!),
        'expiredAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  String _cacheKeyForSingleDonation(String donationId) =>
      'donation.single.$donationId';

  String _cacheKeyForAllDonations({DonationStatus? status}) =>
      'donation.all.${status?.value ?? 'all'}';

  String _cacheKeyForDonorDonations({
    required String donorId,
    DonationStatus? status,
  }) =>
      'donation.donor.$donorId.${status?.value ?? 'all'}';

  String _cacheKeyForAvailableNgoDonations({String? ngoId}) =>
      'donation.ngo.available.${ngoId?.trim().isNotEmpty == true ? ngoId!.trim() : 'all'}';

  String _cacheKeyForNgoAcceptedDonations({
    required String ngoId,
    DonationStatus? status,
  }) =>
      'donation.ngo.accepted.$ngoId.${status?.value ?? 'all'}';

  String _cacheKeyForRecentCompleted({required int limit}) =>
      'donation.completed.recent.$limit';

  String _cacheKeyForStatusStream({
    DonationStatus? status,
    String? donorId,
    String? ngoId,
    required bool onlyAvailableForNgo,
    required bool orderByCreatedAt,
  }) {
    return [
      'donation',
      'stream',
      status?.value ?? 'all',
      donorId?.trim().isNotEmpty == true ? donorId!.trim() : 'nodonor',
      ngoId?.trim().isNotEmpty == true ? ngoId!.trim() : 'nongo',
      onlyAvailableForNgo ? 'available' : 'allitems',
      orderByCreatedAt ? 'ordered' : 'unordered',
    ].join('.');
  }
}

const Duration _donationExpiryWindow = Duration(hours: 2);

int parseMealRangeValue(String range) => parseMealRange(range);

class DonationException implements Exception {
  const DonationException(this.message);

  final String message;

  @override
  String toString() => message;
}

extension DonationModelLocationX on DonationModel {
  AppLocation? get pickupLocation => location;
  String? get locationAddress =>
      location?.address ?? _normalizeNullable(donorAddress);
}

DateTime? _dateFromFirestore(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}

DateTime _defaultExpiryAtForCreatedAt(DateTime createdAt) {
  return createdAt.add(_donationExpiryWindow);
}

bool _shouldAutoExpireDonation({
  required String status,
  required String? acceptedByNgoId,
  required DateTime? completedAt,
  required DateTime? expiryAt,
  DateTime? referenceTime,
}) {
  if (status != DonationStatus.active.value) {
    return false;
  }
  if (completedAt != null) {
    return false;
  }
  if (acceptedByNgoId != null && acceptedByNgoId.trim().isNotEmpty) {
    return false;
  }
  if (expiryAt == null) {
    return false;
  }
  final now = referenceTime ?? DateTime.now();
  return !expiryAt.isAfter(now);
}

String? _normalizeNullable(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

String _resolveQuantity(Map<String, dynamic> data) {
  final quantity = (data['quantity'] as String?)?.trim();
  if (quantity != null && quantity.isNotEmpty) {
    return quantity;
  }

  final servings = (data['servings'] as String?)?.trim();
  if (servings != null && servings.isNotEmpty) {
    return servings;
  }

  return '';
}

AppLocation? _locationFromLegacyDonationFields(Map<String, dynamic> data) {
  final lat = _toDouble(data['donationLatitude']);
  final lng = _toDouble(data['donationLongitude']);
  if (lat == null || lng == null) {
    return null;
  }

  return AppLocation(
    latitude: lat,
    longitude: lng,
    address: (data['donationAddress'] as String?)?.trim() ?? '',
  );
}

double? _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
