import 'dart:async';

import 'package:wastenot/models/repository_state.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/firebase/firebase_service_wrapper.dart';
import 'package:wastenot/services/local_cache_service.dart';

class DonationRepository {
  DonationRepository({
    DonationService? donationService,
    LocalCacheService? cache,
    FirebaseServiceWrapper? firebaseWrapper,
  })  : _donationService = donationService ?? DonationService(),
        _cache = cache ?? LocalCacheService(),
        _firebaseWrapper = firebaseWrapper ?? const FirebaseServiceWrapper();

  final DonationService _donationService;
  final LocalCacheService _cache;
  final FirebaseServiceWrapper _firebaseWrapper;

  Stream<RepositoryState<List<DonationModel>>> watchDonorDonations({
    required String donorId,
    DonationStatus? status,
  }) async* {
    final cacheKey = _cacheKeyForDonorDonations(
      donorId: donorId,
      status: status,
    );
    final cached = await _cache.getDonationList(cacheKey);

    yield RepositoryState<List<DonationModel>>(
      data: cached,
      isLoading: true,
      isFromCache: cached.isNotEmpty,
    );

    final remoteResult = await _firebaseWrapper.execute<List<DonationModel>>(
      () => _donationService.getDonorDonations(
        donorId: donorId,
        status: status,
      ),
      timeout: const Duration(seconds: 3),
      operationName: 'watchDonorDonations',
    );

    if (remoteResult.data != null) {
      yield RepositoryState<List<DonationModel>>(
        data: remoteResult.data!,
        isLoading: false,
        isFromCache: false,
      );
      return;
    }

    yield RepositoryState<List<DonationModel>>(
      data: cached,
      isLoading: false,
      isFromCache: cached.isNotEmpty,
      errorMessage: remoteResult.errorMessage,
    );
  }

  Stream<RepositoryState<List<DonationModel>>> watchAvailableNgoDonations({
    String? ngoId,
  }) async* {
    final cacheKey = _cacheKeyForAvailableNgoDonations(ngoId: ngoId);
    final cached = await _cache.getDonationList(cacheKey);

    yield RepositoryState<List<DonationModel>>(
      data: cached,
      isLoading: true,
      isFromCache: cached.isNotEmpty,
    );

    final remoteResult = await _firebaseWrapper.execute<List<DonationModel>>(
      () => _donationService.getAvailableDonationsForNgo(ngoId: ngoId),
      timeout: const Duration(seconds: 3),
      operationName: 'watchAvailableNgoDonations',
    );

    if (remoteResult.data != null) {
      yield RepositoryState<List<DonationModel>>(
        data: remoteResult.data!,
        isLoading: false,
        isFromCache: false,
      );
      return;
    }

    yield RepositoryState<List<DonationModel>>(
      data: cached,
      isLoading: false,
      isFromCache: cached.isNotEmpty,
      errorMessage: remoteResult.errorMessage,
    );
  }

  String _cacheKeyForDonorDonations({
    required String donorId,
    DonationStatus? status,
  }) =>
      'donation.donor.$donorId.${status?.value ?? 'all'}';

  String _cacheKeyForAvailableNgoDonations({String? ngoId}) =>
      'donation.ngo.available.${ngoId?.trim().isNotEmpty == true ? ngoId!.trim() : 'all'}';
}
