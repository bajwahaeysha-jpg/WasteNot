import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.name,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.organizationName,
    this.registrationNumber,
    this.organizationDescription,
    this.approvedByAdmin = false,
  });

  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? name;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final String? organizationName;
  final String? registrationNumber;
  final String? organizationDescription;
  final bool approvedByAdmin;

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
    String? profileImageUrl,
    String? organizationName,
    String? registrationNumber,
    String? organizationDescription,
    bool? approvedByAdmin,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      organizationName: organizationName ?? this.organizationName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      organizationDescription:
          organizationDescription ?? this.organizationDescription,
      approvedByAdmin: approvedByAdmin ?? this.approvedByAdmin,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'organizationName': organizationName,
      'registrationNumber': registrationNumber,
      'organizationDescription': organizationDescription,
      'role': role,
      'approvedByAdmin': approvedByAdmin,
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
      'profileImageUrl': profileImageUrl,
    };
  }
  factory AppUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];

    return AppUserModel(
      uid: doc.id,
      name: data['name'] as String?,
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      organizationName: data['organizationName'] as String?,
      registrationNumber: data['registrationNumber'] as String?,
      organizationDescription: data['organizationDescription'] as String?,
      role: (data['role'] as String?) ?? 'donor',
      approvedByAdmin: (data['approvedByAdmin'] as bool?) ?? false,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
