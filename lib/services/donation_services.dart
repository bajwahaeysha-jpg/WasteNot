import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wastenot/models/app_user_model.dart';

enum DonationStatus {
  active('active'),
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
    this.location,
    this.imageUrls = const <String>[],
    this.expiryAt,
  });

  final List<String> foodItems;
  final String quantity;
  final String? description;
  final String? location;
  final List<String> imageUrls;
  final DateTime? expiryAt;

  Map<String, dynamic> toFirestore() {
    return {
      'foodItems': foodItems,
      'quantity': quantity.trim(),
      'servings': quantity.trim(),
      'description': _normalizeNullable(description),
      'location': _normalizeNullable(location),
      'imageUrls': imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      'expiryAt': expiryAt == null ? null : Timestamp.fromDate(expiryAt!),
    };
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
    this.location,
    this.imageUrls = const <String>[],
    this.acceptedByNgoId,
    this.acceptedByNgoName,
    this.acceptedByNgoEmail,
    this.acceptedByNgoPhone,
    this.acceptedByNgoAddress,
    this.acceptedByNgoProfileImageUrl,
    this.acceptedAt,
    this.completedAt,
    this.expiryAt,
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
  final String? location;
  final List<String> imageUrls;
  final String status;
  final String? acceptedByNgoId;
  final String? acceptedByNgoName;
  final String? acceptedByNgoEmail;
  final String? acceptedByNgoPhone;
  final String? acceptedByNgoAddress;
  final String? acceptedByNgoProfileImageUrl;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? expiryAt;

  bool get isActive => status == DonationStatus.active.value;
  bool get isExpired => status == DonationStatus.expired.value;
  bool get isCompleted => status == DonationStatus.completed.value;
  bool get isAccepted =>
      acceptedByNgoId != null && acceptedByNgoId!.trim().isNotEmpty;

  Map<String, dynamic> toFirestore() {
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
      'location': location,
      'imageUrls': imageUrls,
      'status': status,
      'acceptedByNgoId': acceptedByNgoId,
      'acceptedByNgoName': acceptedByNgoName,
      'acceptedByNgoEmail': acceptedByNgoEmail,
      'acceptedByNgoPhone': acceptedByNgoPhone,
      'acceptedByNgoAddress': acceptedByNgoAddress,
      'acceptedByNgoProfileImageUrl': acceptedByNgoProfileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt == null ? null : Timestamp.fromDate(acceptedAt!),
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'expiryAt': expiryAt == null ? null : Timestamp.fromDate(expiryAt!),
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
    final donorId = (data['donorId'] as String?)?.trim();

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
      location: _normalizeNullable(data['location'] as String?),
      imageUrls: normalizedImageUrls,
      status: (data['status'] as String?)?.trim() ?? DonationStatus.active.value,
      acceptedByNgoId: _normalizeNullable(data['acceptedByNgoId'] as String?),
      acceptedByNgoName:
          _normalizeNullable(data['acceptedByNgoName'] as String?),
      acceptedByNgoEmail:
          _normalizeNullable(data['acceptedByNgoEmail'] as String?),
      acceptedByNgoPhone:
          _normalizeNullable(data['acceptedByNgoPhone'] as String?),
      acceptedByNgoAddress:
          _normalizeNullable(data['acceptedByNgoAddress'] as String?),
      acceptedByNgoProfileImageUrl:
          _normalizeNullable(data['acceptedByNgoProfileImageUrl'] as String?),
      createdAt: _dateFromFirestore(data['createdAt']) ?? DateTime.now(),
      acceptedAt: _dateFromFirestore(data['acceptedAt']),
      completedAt: _dateFromFirestore(data['completedAt']),
      expiryAt: _dateFromFirestore(data['expiryAt']),
    );
  }
}

class DonationService {
  DonationService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _donations =>
      _firestore.collection('donations');

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

    final now = DateTime.now();
    final docRef = donationId == null || donationId.trim().isEmpty
        ? _donations.doc()
        : _donations.doc(donationId.trim());
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
      'createdAt': Timestamp.fromDate(now),
      ...request.toFirestore(),
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
      return DonationModel.fromFirestore(doc);
    } on FirebaseException catch (error) {
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
      final snapshot = await _donations.get();
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      final filtered = status == null
          ? donations
          : donations.where((donation) => donation.status == status.value).toList();
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
        '[DonationService] getAllDonations -> ${filtered.length} results',
      );
      return filtered;
    } on FirebaseException catch (error) {
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
      final snapshot = await _donations.get();
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      final filtered = donations.where((donation) {
        if (donation.donorId != normalizedDonorId) {
          return false;
        }
        if (status != null && donation.status != status.value) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
        '[DonationService] getDonorDonations -> ${filtered.length} results for donorId=$normalizedDonorId',
      );
      return filtered;
    } on FirebaseException catch (error) {
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
    DateTime? now,
  }) async {
    try {
      debugPrint('[DonationService] getAvailableDonationsForNgo()');
      final snapshot = await _donations.get();

      final referenceTime = now ?? DateTime.now();
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      final filtered = donations.where((donation) {
        if (donation.status != DonationStatus.active.value) {
          return false;
        }
        if (donation.isAccepted) {
          return false;
        }
        final expiryAt = donation.expiryAt;
        return expiryAt == null || !expiryAt.isBefore(referenceTime);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
        '[DonationService] getAvailableDonationsForNgo -> ${filtered.length} results',
      );
      return filtered;
    } on FirebaseException catch (error) {
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
      final snapshot = await _donations.get();
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      final filtered = donations.where((donation) {
        if (donation.acceptedByNgoId != normalizedNgoId) {
          return false;
        }
        if (status != null && donation.status != status.value) {
          return false;
        }
        return true;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
        '[DonationService] getNgoAcceptedDonations -> ${filtered.length} results for ngoId=$normalizedNgoId',
      );
      return filtered;
    } on FirebaseException catch (error) {
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
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      donations.sort((a, b) {
        final aTime = a.completedAt ?? a.createdAt;
        final bTime = b.completedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      final recent = donations.take(limit).toList();
      debugPrint(
        '[DonationService] getRecentCompletedDonations -> ${recent.length} results',
      );
      return recent;
    } on FirebaseException catch (error) {
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

        if (!donation.isActive) {
          throw const DonationException(
            'Only active donations can be accepted.',
          );
        }

        if (donation.expiryAt != null && donation.expiryAt!.isBefore(now)) {
          throw const DonationException(
            'This donation has already expired.',
          );
        }

        if (donation.isAccepted) {
          throw const DonationException(
            'This donation has already been accepted by another NGO.',
          );
        }

        transaction.update(docRef, {
          'acceptedByNgoId': ngo.uid,
          'acceptedByNgoName': ngo.displayName,
          'acceptedByNgoEmail': ngo.email.trim(),
          'acceptedByNgoPhone': _normalizeNullable(ngo.phone),
          'acceptedByNgoAddress': _normalizeNullable(ngo.address),
          'acceptedByNgoProfileImageUrl': _normalizeNullable(
            ngo.profileImageUrl,
          ),
          'acceptedAt': Timestamp.fromDate(now),
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
        if (donation.isCompleted) {
          return;
        }

        if (donation.isExpired) {
          throw const DonationException(
            'Expired donations cannot be completed.',
          );
        }

        if (!donation.isAccepted) {
          throw const DonationException(
            'Only accepted donations can be marked as completed.',
          );
        }

        transaction.update(docRef, {
          'status': DonationStatus.completed.value,
          'completedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      return getDonationById(donationId);
    } on DonationException {
      rethrow;
    } on FirebaseException catch (error) {
      throw DonationException(_mapFirebaseError(error));
    }
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
        if (donation.isCompleted) {
          throw const DonationException(
            'Completed donations cannot be marked as expired.',
          );
        }

        if (donation.isExpired) {
          return;
        }

        final effectiveExpiry = expiredAt ?? donation.expiryAt ?? DateTime.now();
        transaction.update(docRef, {
          'status': DonationStatus.expired.value,
          'expiryAt': Timestamp.fromDate(effectiveExpiry),
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
  }) {
    Query<Map<String, dynamic>> query = _donations;
    final effectiveStatus =
        onlyAvailableForNgo ? DonationStatus.active : status;

    if (donorId != null && donorId.trim().isNotEmpty) {
      query = query.where('donorId', isEqualTo: donorId.trim());
    }

    if (ngoId != null && ngoId.trim().isNotEmpty) {
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

    return effectiveQuery.snapshots().map((snapshot) {
      final now = DateTime.now();
      final donations = snapshot.docs.map(DonationModel.fromFirestore).toList();
      if (!onlyAvailableForNgo) {
        return donations;
      }

      return donations.where((donation) {
        final expiryAt = donation.expiryAt;
        return expiryAt == null || !expiryAt.isBefore(now);
      }).toList();
    });
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
}

class DonationException implements Exception {
  const DonationException(this.message);

  final String message;

  @override
  String toString() => message;
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
