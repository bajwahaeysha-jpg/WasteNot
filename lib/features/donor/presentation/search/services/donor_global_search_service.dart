import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';

class DonorGlobalSearchResults {
  const DonorGlobalSearchResults({
    this.donations = const <DonationModel>[],
    this.ngos = const <AppUserModel>[],
  });

  final List<DonationModel> donations;
  final List<AppUserModel> ngos;

  bool get isEmpty => donations.isEmpty && ngos.isEmpty;
}

class DonorGlobalSearchService {
  DonorGlobalSearchService({
    DonationService? donationService,
    FirebaseFirestore? firestore,
  })  : _donationService = donationService ?? DonationService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const Duration _cacheTtl = Duration(minutes: 2);

  final DonationService _donationService;
  final FirebaseFirestore _firestore;

  List<DonationModel>? _cachedDonations;
  DateTime? _donationsFetchedAt;
  List<AppUserModel>? _cachedNgos;
  DateTime? _ngosFetchedAt;
  Future<void>? _loadingFuture;

  Future<DonorGlobalSearchResults> search(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const DonorGlobalSearchResults();
    }

    await _ensureDataLoaded();

    final donations = (_cachedDonations ?? const <DonationModel>[])
        .where((donation) => _matchesDonation(donation, query))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final ngos = (_cachedNgos ?? const <AppUserModel>[])
        .where((ngo) => _matchesNgo(ngo, query))
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return DonorGlobalSearchResults(
      donations: donations,
      ngos: ngos,
    );
  }

  Future<void> _ensureDataLoaded() {
    final now = DateTime.now();
    final donationsFresh =
        _cachedDonations != null &&
        _donationsFetchedAt != null &&
        now.difference(_donationsFetchedAt!) < _cacheTtl;
    final ngosFresh =
        _cachedNgos != null &&
        _ngosFetchedAt != null &&
        now.difference(_ngosFetchedAt!) < _cacheTtl;

    if (donationsFresh && ngosFresh) {
      return Future.value();
    }

    final existingLoad = _loadingFuture;
    if (existingLoad != null) {
      return existingLoad;
    }

    final future = _loadData();
    _loadingFuture = future;
    return future.whenComplete(() {
      if (identical(_loadingFuture, future)) {
        _loadingFuture = null;
      }
    });
  }

  Future<void> _loadData() async {
    final results = await Future.wait<dynamic>([
      _donationService.getAllDonations(),
      _fetchNgos(),
    ]);

    _cachedDonations = List<DonationModel>.from(results[0] as List<DonationModel>);
    _donationsFetchedAt = DateTime.now();
    _cachedNgos = List<AppUserModel>.from(results[1] as List<AppUserModel>);
    _ngosFetchedAt = DateTime.now();
  }

  Future<List<AppUserModel>> _fetchNgos() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'ngo')
        .where('approvedByAdmin', isEqualTo: true)
        .get();

    return snapshot.docs
        .map(AppUserModel.fromFirestore)
        .where((user) => !user.isSuspended)
        .toList();
  }

  bool _matchesDonation(DonationModel donation, String query) {
    return _joinParts(<String?>[
      donation.foodItems.join(' '),
      donation.description,
      donation.precaution,
      donation.donorName,
      donation.donorAddress,
      donation.locationAddress,
      donation.acceptedByNgoName,
      donation.acceptedByNgoAddress,
    ]).contains(query);
  }

  bool _matchesNgo(AppUserModel ngo, String query) {
    return _joinParts(<String?>[
      ngo.displayName,
      ngo.organizationName,
      ngo.organizationDescription,
      ngo.about,
      ngo.address,
      ngo.location?.address,
    ]).contains(query);
  }

  String _joinParts(List<String?> parts) {
    return parts
        .map((part) => part?.trim().toLowerCase() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');
  }
}
