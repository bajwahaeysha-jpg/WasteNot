import 'package:cloud_firestore/cloud_firestore.dart';

class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  String get label => address;
  String get city {
    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return shortCoordinates;
    }
    if (parts.length >= 2) {
      return parts[parts.length - 3 < 0 ? 0 : parts.length - 3];
    }
    return parts.first;
  }
  double get lat => latitude;
  double get lng => longitude;
  String get shortCoordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  Map<String, dynamic> toFirestore() {
    return {
      'lat': latitude,
      'lng': longitude,
      'address': address.trim(),
    };
  }

  factory AppLocation.fromMap(Map<String, dynamic> data) {
    final latitude = _toDouble(data['lat'] ?? data['latitude']);
    final longitude = _toDouble(data['lng'] ?? data['longitude']);
    return AppLocation(
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      address: ((data['address'] ?? data['label']) as String?)?.trim() ?? '',
    );
  }

  static AppLocation? fromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      final latitude = _toDouble(value['latitude']);
      final longitude = _toDouble(value['longitude']);
      if (latitude == null || longitude == null) {
        return null;
      }
      return AppLocation(
        latitude: latitude,
        longitude: longitude,
        address: ((value['address'] ?? value['label']) as String?)?.trim() ?? '',
      );
    }
    if (value is Map) {
      return fromDynamic(
        value.map(
          (key, item) => MapEntry(key.toString(), item),
        ),
      );
    }
    return null;
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

Map<String, dynamic>? locationToFirestore(AppLocation? location) {
  if (location == null) {
    return null;
  }
  return location.toFirestore();
}

DateTime? dateTimeFromFirestore(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
