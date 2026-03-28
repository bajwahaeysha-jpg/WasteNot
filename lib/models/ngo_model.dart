import 'package:cloud_firestore/cloud_firestore.dart';

class NgoModel {
  const NgoModel({
    required this.id,
    required this.name,
    required this.about,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String about;
  final String? imageUrl;

  factory NgoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    // 🔥 Firestore ke actual fields
    final rawImageUrl = data['profileImageUrl']?.toString();
    final trimmedImageUrl = rawImageUrl?.trim();

    return NgoModel(
      id: doc.id,

      // 🔥 Correct mapping
      name: (data['organizationName'] ?? '').toString().trim(),
      about: (data['organizationDescription'] ?? '').toString().trim(),

      // 🔥 Safe null handling
      imageUrl: (trimmedImageUrl == null || trimmedImageUrl.isEmpty)
          ? null
          : trimmedImageUrl,
    );
  }
}