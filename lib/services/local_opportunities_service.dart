import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wastenot/models/ngo_model.dart';
import 'package:wastenot/services/local_cache_service.dart';

class LocalOpportunitiesService {
  LocalOpportunitiesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final LocalCacheService _cache = LocalCacheService();

  // 🔥 IMPORTANT: users collection use ho rahi hai
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<List<NgoModel>> getLocalOpportunities() async {
    const cacheKey = 'local_opportunities';
    try {
      // 🔥 Sirf NGOs filter kar rahe hain
      final snapshot = await _users
          .where('role', isEqualTo: 'ngo')
          .where('approvedByAdmin', isEqualTo: true)
          .get();

      debugPrint("NGOs found: ${snapshot.docs.length}");

      final ngos = snapshot.docs.map((doc) {
        final data = doc.data();

        return NgoModel(
          id: doc.id,

          // 🔥 Firestore ke actual field names use ho rahe hain
          name: (data['organizationName'] ?? '').toString(),
          about: (data['organizationDescription'] ?? '').toString(),

          // null safe handling
          imageUrl: data['profileImageUrl'] != null
              ? data['profileImageUrl'].toString()
              : null,
        );
      }).toList();
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
