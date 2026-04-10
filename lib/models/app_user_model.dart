import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/app_location.dart';

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.name,
    this.phone,
    this.address,
    this.location,
    this.about,
    this.profileImageUrl,
    this.organizationName,
    this.registrationNumber,
    this.organizationDescription,
    this.allowMessages = true,
    this.notificationsEnabled = true,
    this.emailVerified = false,
    this.approvedByAdmin = false,
    this.status,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedBy,
  });

  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? name;
  final String? phone;
  final String? address;
  final AppLocation? location;
  final String? about;
  final String? profileImageUrl;
  final String? organizationName;
  final String? registrationNumber;
  final String? organizationDescription;
  final bool allowMessages;
  final bool notificationsEnabled;
  final bool emailVerified;
  final bool approvedByAdmin;
  final String? status;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? suspendedBy;

  String get displayName => organizationName ?? name ?? email;

  bool get isDonor => role == 'donor';
  bool get isNgo => role == 'ngo';
  bool get isAdmin => role == 'admin';

  AppUserModel copyWith({
    String? uid,
    String? email,
    String? role,
    DateTime? createdAt,
    String? name,
    String? phone,
    String? address,
    AppLocation? location,
    String? about,
    String? profileImageUrl,
    String? organizationName,
    String? registrationNumber,
    String? organizationDescription,
    bool? allowMessages,
    bool? notificationsEnabled,
    bool? emailVerified,
    bool? approvedByAdmin,
    String? status,
    bool? isSuspended,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      about: about ?? this.about,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      organizationName: organizationName ?? this.organizationName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      organizationDescription:
          organizationDescription ?? this.organizationDescription,
      allowMessages: allowMessages ?? this.allowMessages,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailVerified: emailVerified ?? this.emailVerified,
      approvedByAdmin: approvedByAdmin ?? this.approvedByAdmin,
      status: status ?? this.status,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'location': locationToFirestore(location),
      'about': about,
      'profileImageUrl': profileImageUrl,
      'organizationName': organizationName,
      'registrationNumber': registrationNumber,
      'organizationDescription': organizationDescription,
      'allowMessages': allowMessages,
      'notificationsEnabled': notificationsEnabled,
      'emailVerified': emailVerified,
      'role': role,
      'approvedByAdmin': approvedByAdmin,
      'status': status,
      'isSuspended': isSuspended,
      'suspensionReason': suspensionReason,
      'suspendedAt': suspendedAt == null ? null : Timestamp.fromDate(suspendedAt!),
      'suspendedBy': suspendedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toNavigationUser() {
    return {
      'uid': uid,
      'name': displayName,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'location': locationToFirestore(location),
      'profileImageUrl': profileImageUrl,
      'status': status,
      'isSuspended': isSuspended,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    final suspendedAt = data['suspendedAt'];
    final location =
        AppLocation.fromDynamic(data['location']) ??
        _locationFromFlatFields(data);
    final isSuspended = (data['isSuspended'] as bool?) ??
        ((data['status'] as String?)?.toLowerCase() == 'suspended');

    return AppUserModel(
      uid: doc.id,
      name: data['name'] as String?,
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      address: (data['address'] as String?) ?? location?.address,
      location: location,
      about: data['about'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      organizationName: data['organizationName'] as String?,
      registrationNumber: data['registrationNumber'] as String?,
      organizationDescription: data['organizationDescription'] as String?,
      allowMessages: (data['allowMessages'] as bool?) ?? true,
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
      emailVerified: (data['emailVerified'] as bool?) ?? false,
      role: (data['role'] as String?) ?? 'donor',
      approvedByAdmin: (data['approvedByAdmin'] as bool?) ?? false,
      status: data['status'] as String?,
      isSuspended: isSuspended,
      suspensionReason: data['suspensionReason'] as String?,
      suspendedAt: suspendedAt is Timestamp ? suspendedAt.toDate() : null,
      suspendedBy: data['suspendedBy'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  static AppLocation? _locationFromFlatFields(Map<String, dynamic> data) {
    final latitude = _toDouble(data['latitude'] ?? data['lat']);
    final longitude = _toDouble(data['longitude'] ?? data['lng']);
    if (latitude == null || longitude == null) {
      return null;
    }

    return AppLocation(
      latitude: latitude,
      longitude: longitude,
      address: (data['address'] as String?)?.trim() ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
