import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final int distanceMeters;
  final int durationSeconds;

  DirectionsResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class DirectionsService {
  static Future<DirectionsResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // TEMP MOCK (real API later)
    return DirectionsResult(
      polylinePoints: [origin, destination],
      distanceMeters: 5000,
      durationSeconds: 900,
    );
  }
}
