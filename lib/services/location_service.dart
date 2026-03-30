import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/shared/map_picker_screen.dart';

class LocationPermissionException implements Exception {
  const LocationPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  const LocationService();

  Future<AppLocation?> pickLocation(
    BuildContext context, {
    AppLocation? initialLocation,
    String title = 'Select Location',
  }) {
    return Navigator.of(context).push<AppLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: initialLocation,
          title: title,
        ),
      ),
    );
  }

  Future<AppLocation> getCurrentLocation() async {
    await _ensureLocationAccess();

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return reverseGeocode(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<String> getAddressFromLatLng({
    required double latitude,
    required double longitude,
  }) async {
    final location = await reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
    return location.address;
  }

  Future<AppLocation> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final fallback =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final address = _buildAddress(placemarks.first);
        return AppLocation(
          latitude: latitude,
          longitude: longitude,
          address: address.isEmpty ? fallback : address,
        );
      }
    } catch (_) {
      // Fall back to coordinates when geocoding fails.
    }

    return AppLocation(
      latitude: latitude,
      longitude: longitude,
      address: fallback,
    );
  }

  Future<List<AppLocation>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const <AppLocation>[];
    }

    try {
      final locations = await locationFromAddress(trimmedQuery);
      final results = <AppLocation>[];

      for (final location in locations.take(5)) {
        results.add(
          await reverseGeocode(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );
      }

      return results;
    } catch (_) {
      return const <AppLocation>[];
    }
  }

  double? calculateDistance({
    required AppLocation? from,
    required AppLocation? to,
  }) {
    if (from == null || to == null) {
      return null;
    }

    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        ) /
        1000;
  }

  int? calculateEstimatedMinutes({
    required AppLocation? from,
    required AppLocation? to,
  }) {
    final distanceKm = calculateDistance(from: from, to: to);
    if (distanceKm == null) {
      return null;
    }
    return ((distanceKm / 30) * 60).clamp(1, 24 * 60).round();
  }

  Future<void> _ensureLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationPermissionException(
        'Location services are disabled. Please turn on GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(
        'Location permission was denied. Please allow access to continue.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Location permission is permanently denied. Enable it from app settings.',
      );
    }
  }

  String _buildAddress(Placemark place) {
    final parts = <String>{
      if ((place.name ?? '').trim().isNotEmpty) place.name!.trim(),
      if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
      if ((place.subLocality ?? '').trim().isNotEmpty)
        place.subLocality!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
      if ((place.administrativeArea ?? '').trim().isNotEmpty)
        place.administrativeArea!.trim(),
      if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
    };

    return parts.join(', ');
  }
}
