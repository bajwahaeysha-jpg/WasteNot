import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/services/distance_service.dart';

class LocationEstimate {
  const LocationEstimate({
    required this.distanceKm,
    required this.estimatedMinutes,
  });

  final double distanceKm;
  final int estimatedMinutes;

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  String get durationLabel {
    if (estimatedMinutes < 60) {
      return '$estimatedMinutes min';
    }

    final hours = estimatedMinutes ~/ 60;
    final minutes = estimatedMinutes % 60;
    if (minutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $minutes min';
  }
}

class LocationEstimateService {
  const LocationEstimateService();

  LocationEstimate? estimate({
    required AppLocation? from,
    required AppLocation? to,
  }) {
    final result = const DistanceService().calculate(from: from, to: to);
    if (result == null) {
      return null;
    }

    return LocationEstimate(
      distanceKm: result.distanceKm,
      estimatedMinutes: result.estimatedMinutes,
    );
  }
}
