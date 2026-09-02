/// Platform-agnostic LatLng class.
///
/// WHY: We need lat/lng coordinates in models and services that should NOT
/// depend on any specific map SDK (Google Maps, Mapbox, etc.).
/// This class is a simple data container — the UI layer converts it to
/// whatever the active map SDK expects (e.g., mapbox.Position, google.LatLng).
///
/// ALTERNATIVES CONSIDERED:
/// - Using google_maps_flutter LatLng everywhere: ties models to Google Maps
/// - Using a tuple (double, double): loses named access, harder to read
/// - Using Map<String, double>: no type safety
///
/// This is the cleanest approach for a cross-platform Flutter app.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      );
}
