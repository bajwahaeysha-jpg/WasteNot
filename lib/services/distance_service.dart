import 'dart:math' as math;

import 'package:wastenot/models/app_location.dart';

class DistanceEstimate {
  const DistanceEstimate({
    required this.distanceKm,
    required this.estimatedMinutes,
  });

  final double distanceKm;
  final int estimatedMinutes;

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';
  String get durationLabel => '$estimatedMinutes mins';
}

class DistanceService {
  const DistanceService();

  static const double _averageCitySpeedKmPerHour = 30;

  DistanceEstimate? calculate({
    required AppLocation? from,
    required AppLocation? to,
  }) {
    if (from == null || to == null) {
      return null;
    }

    final distanceKm = _haversineKm(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    final estimatedMinutes = math.max(
      1,
      ((distanceKm / _averageCitySpeedKmPerHour) * 60).round(),
    );

    return DistanceEstimate(
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
    );
  }

  double _haversineKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(endLat - startLat);
    final dLng = _toRadians(endLng - startLng);
    final a = (math.pow(math.sin(dLat / 2), 2) +
            math.cos(_toRadians(startLat)) *
                math.cos(_toRadians(endLat)) *
                math.pow(math.sin(dLng / 2), 2))
        .toDouble();
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}
