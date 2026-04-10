import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wastenot/features/goal/models/goal_model.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/auth_session_cache.dart';
import 'package:wastenot/models/ngo_model.dart';
import 'package:wastenot/services/concern_services.dart';
import 'package:wastenot/services/donation_services.dart';

class LocalCacheService {
  static const String _sessionUserKey = 'cache.session_user';
  static const String _authSessionKey = 'cache.auth_session';
  static const String _appUserPrefix = 'cache.app_user.';
  static const String _donationListPrefix = 'cache.donations.';
  static const String _ngoListPrefix = 'cache.ngos.';
  static const String _goalProgressPrefix = 'cache.goal_progress.';
  static const String _concernListPrefix = 'cache.concerns.';
  static const String _mapListPrefix = 'cache.map_list.';

  Future<void> saveSessionUser(AppUserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_sessionUserKey);
      await clearAuthSession();
      return;
    }

    await prefs.setString(_sessionUserKey, jsonEncode(_appUserToJson(user)));
    await saveAppUser(user);
    await saveAuthSession(
      AuthSessionCache(
        isLoggedIn: true,
        uid: user.uid,
        role: user.role,
      ),
    );
  }

  Future<AppUserModel?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return _decodeObject(raw, _appUserFromJson);
  }

  Future<void> clearSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserKey);
  }

  Future<void> saveAuthSession(AuthSessionCache session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authSessionKey, jsonEncode(session.toJson()));
  }

  Future<AuthSessionCache?> getAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return _decodeObject(raw, AuthSessionCache.fromJson);
  }

  Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authSessionKey);
  }

  Future<void> saveAppUser(AppUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_appUserPrefix${user.uid}',
      jsonEncode(_appUserToJson(user)),
    );
  }

  Future<AppUserModel?> getAppUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_appUserPrefix${uid.trim()}');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return _decodeObject(raw, _appUserFromJson);
  }

  Future<void> saveDonationList(String key, List<DonationModel> donations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_donationListPrefix$key',
      jsonEncode(
        donations.map(_donationToJson).toList(),
      ),
    );
  }

  Future<List<DonationModel>> getDonationList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_donationListPrefix$key');
    if (raw == null || raw.isEmpty) {
      return const <DonationModel>[];
    }

    return _decodeList(raw, _donationFromJson);
  }

  Future<void> saveNgoList(String key, List<NgoModel> ngos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_ngoListPrefix$key',
      jsonEncode(ngos.map(_ngoToJson).toList()),
    );
  }

  Future<List<NgoModel>> getNgoList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_ngoListPrefix$key');
    if (raw == null || raw.isEmpty) {
      return const <NgoModel>[];
    }

    return _decodeList(raw, _ngoFromJson);
  }

  Future<void> saveGoalProgress(String key, GoalProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_goalProgressPrefix$key',
      jsonEncode(<String, dynamic>{
        'month': progress.month,
        'target': progress.target,
        'achievedCount': progress.achievedCount,
      }),
    );
  }

  Future<GoalProgress?> getGoalProgress(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_goalProgressPrefix$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return _decodeObject(raw, (json) {
      return GoalProgress(
        month: json['month']?.toString() ?? '',
        target: _asInt(json['target']),
        achievedCount: _asInt(json['achievedCount']),
      );
    });
  }

  Future<void> saveConcernList(String key, List<ConcernModel> concerns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_concernListPrefix$key',
      jsonEncode(concerns.map(_concernToJson).toList()),
    );
  }

  Future<List<ConcernModel>> getConcernList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_concernListPrefix$key');
    if (raw == null || raw.isEmpty) {
      return const <ConcernModel>[];
    }

    return _decodeList(raw, _concernFromJson);
  }

  Future<void> saveMapList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_mapListPrefix$key', jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getMapList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_mapListPrefix$key');
    if (raw == null || raw.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    return _decodeList<Map<String, dynamic>>(raw, (json) => json);
  }

  List<T> _decodeList<T>(
    String raw,
    T Function(Map<String, dynamic> json) parser,
  ) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <T>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
          .map(parser)
          .toList();
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalCacheService] Failed to decode list cache: $error\n$stackTrace',
      );
      return <T>[];
    }
  }

  T? _decodeObject<T>(
    String raw,
    T Function(Map<String, dynamic> json) parser,
  ) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }

      return parser(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LocalCacheService] Failed to decode object cache: $error\n$stackTrace',
      );
      return null;
    }
  }

  Map<String, dynamic> _appUserToJson(AppUserModel user) {
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

  AppUserModel _appUserFromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'donor',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      address: _asString(json['address']),
      location: AppLocation.fromDynamic(json['location']),
      about: _asString(json['about']),
      profileImageUrl: _asString(json['profileImageUrl']),
      organizationName: _asString(json['organizationName']),
      registrationNumber: _asString(json['registrationNumber']),
      organizationDescription: _asString(json['organizationDescription']),
      allowMessages: _asBool(json['allowMessages'], fallback: true),
      notificationsEnabled:
          _asBool(json['notificationsEnabled'], fallback: true),
      emailVerified: _asBool(json['emailVerified']),
      approvedByAdmin: _asBool(json['approvedByAdmin']),
      status: _asString(json['status']),
      isSuspended: _asBool(json['isSuspended']),
      suspensionReason: _asString(json['suspensionReason']),
      suspendedAt: DateTime.tryParse(_asString(json['suspendedAt']) ?? ''),
      suspendedBy: _asString(json['suspendedBy']),
    );
  }

  Map<String, dynamic> _donationToJson(DonationModel donation) {
    return <String, dynamic>{
      'donationId': donation.donationId,
      'donorId': donation.donorId,
      'donorName': donation.donorName,
      'donorEmail': donation.donorEmail,
      'donorPhone': donation.donorPhone,
      'donorAddress': donation.donorAddress,
      'donorProfileImageUrl': donation.donorProfileImageUrl,
      'foodItems': donation.foodItems,
      'quantity': donation.quantity,
      'description': donation.description,
      'precaution': donation.precaution,
      'location': donation.location?.toFirestore(),
      'imageUrls': donation.imageUrls,
      'status': donation.status,
      'acceptedByNgoId': donation.acceptedByNgoId,
      'acceptedByNgoName': donation.acceptedByNgoName,
      'acceptedByNgoEmail': donation.acceptedByNgoEmail,
      'acceptedByNgoPhone': donation.acceptedByNgoPhone,
      'acceptedByNgoAddress': donation.acceptedByNgoAddress,
      'acceptedByNgoLocation': donation.acceptedByNgoLocation?.toFirestore(),
      'acceptedByNgoProfileImageUrl': donation.acceptedByNgoProfileImageUrl,
      'createdAt': donation.createdAt.toIso8601String(),
      'acceptedAt': donation.acceptedAt?.toIso8601String(),
      'completedAt': donation.completedAt?.toIso8601String(),
      'expiryAt': donation.expiryAt?.toIso8601String(),
      'expired': donation.expired,
      'rejectedByNgoIds': donation.rejectedByNgoIds,
    };
  }

  DonationModel _donationFromJson(Map<String, dynamic> json) {
    return DonationModel(
      donationId: json['donationId']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? '',
      donorEmail: json['donorEmail']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      foodItems: _stringList(json['foodItems']),
      quantity: json['quantity']?.toString() ?? '',
      status: json['status']?.toString() ?? DonationStatus.active.value,
      donorPhone: _asString(json['donorPhone']),
      donorAddress: _asString(json['donorAddress']),
      donorProfileImageUrl: _asString(json['donorProfileImageUrl']),
      description: _asString(json['description']),
      precaution: _asString(json['precaution']),
      location: AppLocation.fromDynamic(json['location']),
      imageUrls: _stringList(json['imageUrls']),
      acceptedByNgoId: _asString(json['acceptedByNgoId']),
      acceptedByNgoName: _asString(json['acceptedByNgoName']),
      acceptedByNgoEmail: _asString(json['acceptedByNgoEmail']),
      acceptedByNgoPhone: _asString(json['acceptedByNgoPhone']),
      acceptedByNgoAddress: _asString(json['acceptedByNgoAddress']),
      acceptedByNgoLocation: AppLocation.fromDynamic(json['acceptedByNgoLocation']),
      acceptedByNgoProfileImageUrl:
          _asString(json['acceptedByNgoProfileImageUrl']),
      acceptedAt: DateTime.tryParse(_asString(json['acceptedAt']) ?? ''),
      completedAt: DateTime.tryParse(_asString(json['completedAt']) ?? ''),
      expiryAt: DateTime.tryParse(_asString(json['expiryAt']) ?? ''),
      expired: json['expired'] as bool? ?? false,
      rejectedByNgoIds: _stringList(json['rejectedByNgoIds']),
    );
  }

  Map<String, dynamic> _ngoToJson(NgoModel ngo) {
    return <String, dynamic>{
      'id': ngo.id,
      'name': ngo.name,
      'about': ngo.about,
      'imageUrl': ngo.imageUrl,
    };
  }

  NgoModel _ngoFromJson(Map<String, dynamic> json) {
    return NgoModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      imageUrl: _asString(json['imageUrl']),
    );
  }

  Map<String, dynamic> _concernToJson(ConcernModel concern) {
    return <String, dynamic>{
      'concernId': concern.concernId,
      'title': concern.title,
      'message': concern.message,
      'imageUrl': concern.imageUrl,
      'ngoId': concern.ngoId,
      'ngoName': concern.ngoName,
      'ngoEmail': concern.ngoEmail,
      'createdAt': concern.createdAt.toIso8601String(),
      'expiryTime': concern.expiryTime.toIso8601String(),
      'isActive': concern.isActive,
      'imageStoragePath': concern.imageStoragePath,
      'durationLabel': concern.durationLabel,
    };
  }

  ConcernModel _concernFromJson(Map<String, dynamic> json) {
    return ConcernModel(
      concernId: json['concernId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      ngoId: json['ngoId']?.toString() ?? '',
      ngoName: json['ngoName']?.toString() ?? '',
      ngoEmail: _asString(json['ngoEmail']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      expiryTime:
          DateTime.tryParse(json['expiryTime']?.toString() ?? '') ?? DateTime.now(),
      isActive: _asBool(json['isActive'], fallback: true),
      imageStoragePath: _asString(json['imageStoragePath']),
      durationLabel: _asString(json['durationLabel']),
    );
  }

  static String? _asString(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return fallback;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
