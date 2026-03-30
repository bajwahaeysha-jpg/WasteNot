import 'package:wastenot/models/app_location.dart';

class UserModel {
  String name;
  String email;
  double? latitude;
  double? longitude;
  String? address;

  UserModel({
    required this.name,
    required this.email,
    this.latitude,
    this.longitude,
    this.address,
  });

  AppLocation? get location {
    if (latitude == null || longitude == null) {
      return null;
    }

    return AppLocation(
      latitude: latitude!,
      longitude: longitude!,
      address: address ?? '',
    );
  }
}
