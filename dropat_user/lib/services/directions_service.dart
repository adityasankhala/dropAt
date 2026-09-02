import 'dart:convert';
import 'dart:math' as math;
import '../models/lat_lng.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'places_service.dart';

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String encodedPolyline;
  final int distanceMeters;
  final int durationSeconds;
  final String distanceText;
  final String durationText;

  DirectionsResult({
    required this.polylinePoints,
    required this.encodedPolyline,
    required this.distanceMeters,
    required this.durationSeconds,
    this.distanceText = '',
    this.durationText = '',
  });

  double get distanceKm => distanceMeters / 1000;
  int get durationMin => (durationSeconds / 60).round();
}

class DirectionsService {
  static const String _apiKey = PlacesService.apiKey;

  static Future<DirectionsResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey'
        '&mode=driving';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return _fallbackResult(origin, destination);
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 'OK' ||
          (data['routes'] as List).isEmpty) {
        return _fallbackResult(origin, destination);
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      // Decode polyline
      final polylinePointsDecoder = PolylinePoints();
      final encodedPolyline = route['overview_polyline']['points'];
      final decodedPoints =
          polylinePointsDecoder.decodePolyline(encodedPolyline);

      final points = decodedPoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      return DirectionsResult(
        polylinePoints: points,
        encodedPolyline: encodedPolyline,
        distanceMeters: leg['distance']['value'],
        durationSeconds: leg['duration']['value'],
        distanceText: leg['distance']['text'],
        durationText: leg['duration']['text'],
      );
    } catch (e) {
      return _fallbackResult(origin, destination);
    }
  }

  /// Fallback result using straight-line distance
  static DirectionsResult _fallbackResult(LatLng origin, LatLng destination) {
    // Haversine approximation
    const double earthRadius = 6371000; // meters
    final dLat = _toRad(destination.latitude - origin.latitude);
    final dLng = _toRad(destination.longitude - origin.longitude);
    final a = _sin2(dLat / 2) +
        _cos(origin.latitude) *
            _cos(destination.latitude) *
            _sin2(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    final distance = earthRadius * c;

    // Rough duration: 30 km/h average
    final duration = (distance / 30000 * 3600).round();

    return DirectionsResult(
      polylinePoints: [origin, destination],
      encodedPolyline: '', // No encoded polyline for fallback
      distanceMeters: distance.round(),
      durationSeconds: duration,
      distanceText: '${(distance / 1000).toStringAsFixed(1)} km',
      durationText: '${(duration / 60).round()} min',
    );
  }

  static double _toRad(double deg) => deg * 3.14159265359 / 180;
  static double _sin2(double x) {
    final s = _sinVal(x);
    return s * s;
  }

  static double _cos(double deg) => _cosVal(_toRad(deg));
  static double _sinVal(double x) {
    // Taylor series approximation for sin
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cosVal(double x) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) return _atanVal(y / x);
    if (x < 0 && y >= 0) return _atanVal(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atanVal(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0;
  }

  static double _atanVal(double x) {
    if (x.abs() > 1) {
      return (3.14159265359 / 2) * x.sign - _atanVal(1 / x);
    }
    double result = x;
    double term = x;
    for (int i = 1; i <= 15; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }
}
