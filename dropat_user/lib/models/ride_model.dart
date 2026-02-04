import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ride_status.dart';

class RideModel {
  final LatLng pickup;
  final LatLng drop;
  final double distanceMeters;
  final int durationSeconds;
  final RideStatus status;

  RideModel({
    required this.pickup,
    required this.drop,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.status,
  });

  double get distanceKm => distanceMeters / 1000;
  int get durationMin => (durationSeconds / 60).round();
}
