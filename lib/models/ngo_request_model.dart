import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/models/app_location.dart';

class NgoRequestModel {
  const NgoRequestModel({
    required this.id,
    required this.organizationName,
    required this.email,
    required this.pendingPassword,
    required this.phone,
    required this.address,
    this.location,
    required this.registrationNumber,
    required this.description,
    required this.status,
    required this.createdAt,
    this.profileImageUrl,
  });

  final String id;
  final String organizationName;
  final String email;
  final String pendingPassword;
  final String phone;
  final String address;
  final AppLocation? location;
  final String registrationNumber;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? profileImageUrl;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  String decodePassword() => utf8.decode(base64Decode(pendingPassword));

  Map<String, dynamic> toFirestore() {
    return {
      'organizationName': organizationName,
      'email': email,
      'password': pendingPassword,
      'phone': phone,
      'address': address,
      'location': locationToFirestore(location),
      'registrationNumber': registrationNumber,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NgoRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    final location = AppLocation.fromDynamic(data['location']);

    return NgoRequestModel(
      id: doc.id,
      organizationName: (data['organizationName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      pendingPassword: (data['password'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      address: ((data['address'] as String?) ?? location?.address ?? '').trim(),
      location: location,
      registrationNumber: (data['registrationNumber'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
      status: (data['status'] as String?) ?? 'pending',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
