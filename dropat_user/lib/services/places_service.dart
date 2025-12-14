// lib/services/places_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;
  PlacesService({required this.apiKey});

  /// Autocomplete suggestions for given input, optionally bias by lat/lng and radius.
  Future<List<PlacePrediction>> getAutocomplete(
    String input, {
    double? latitude,
    double? longitude,
    int radiusMeters = 50000,
    String language = 'en',
    String components = '', // e.g. "country:in"
  }) async {
    if (input.trim().isEmpty) return [];

    final params = <String, String>{
      'input': input,
      'key': apiKey,
      'language': language,
      'types':
          'geocode', // geocode returns addresses; you can use 'establishment' too
    };
    if (latitude != null && longitude != null) {
      params['location'] = '$latitude,$longitude';
      params['radius'] = radiusMeters.toString();
    }
    if (components.isNotEmpty) {
      params['components'] = components;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Places API error: ${resp.statusCode}');
    }

    final json = jsonDecode(resp.body);
    if (json['status'] != 'OK' && json['status'] != 'ZERO_RESULTS') {
      // could be REQUEST_DENIED, OVER_QUERY_LIMIT, etc.
      throw Exception(
        'Places API status: ${json['status']} ${json['error_message'] ?? ''}',
      );
    }

    final predictions = json['predictions'] as List<dynamic>;
    return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
  }

  /// Get place details (lat/lng) for a place_id
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': apiKey,
        'fields': 'geometry,name,formatted_address',
      },
    );

    final resp = await http.get(uri);
    final json = jsonDecode(resp.body);
    if (json['status'] != 'OK') {
      throw Exception('Place details error: ${json['status']}');
    }

    final result = json['result'];
    final loc = result['geometry']['location'];
    return PlaceDetails(
      name: result['name'] ?? '',
      address: result['formatted_address'] ?? '',
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
    );
  }
}

class PlacePrediction {
  final String description;
  final String placeId;
  PlacePrediction({required this.description, required this.placeId});
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}

class PlaceDetails {
  final String name;
  final String address;
  final double lat;
  final double lng;
  PlaceDetails({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}
