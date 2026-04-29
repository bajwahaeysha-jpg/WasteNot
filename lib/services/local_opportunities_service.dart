import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/ngo_model.dart';
import 'package:wastenot/services/local_cache_service.dart';

class LocalOpportunitiesService {
  LocalOpportunitiesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalCacheService _cache = LocalCacheService();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<List<NgoModel>> getLocalOpportunities() async {
    const cacheKey = 'local_opportunities';
    try {
      final snapshot = await _users
          .where('role', isEqualTo: 'ngo')
          .where('approvedByAdmin', isEqualTo: true)
          .get();

      debugPrint("NGOs found: ${snapshot.docs.length}");

      final ngos = snapshot.docs
          .map(AppUserModel.fromFirestore)
          .where((user) => !user.isDeleted && !user.isSuspended)
          .map(
            (user) => NgoModel(
              id: user.uid,
              name: user.organizationName ?? user.displayName,
              about:
                  user.organizationDescription ??
                  user.about ??
                  'No NGO description available.',
              imageUrl: user.profileImageUrl,
            ),
          )
          .toList();
      await _cache.saveNgoList(cacheKey, ngos);
      return ngos;
    } on FirebaseException catch (error) {
      final cached = await _cache.getNgoList(cacheKey);
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint(
        '[LocalOpportunitiesService] FirebaseException(${error.code}): ${error.message}',
      );
      rethrow;
    } catch (error) {
      final cached = await _cache.getNgoList(cacheKey);
      if (cached.isNotEmpty) {
        return cached;
      }
      debugPrint('[LocalOpportunitiesService] error: $error');
      rethrow;
    }
  }
}
