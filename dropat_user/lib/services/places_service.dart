import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  // 🔴 REPLACE WITH YOUR REAL GOOGLE MAPS API KEY
  static const String _apiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  /// AUTOCOMPLETE SUGGESTIONS
  static Future<List<Map<String, dynamic>>> getSuggestions(String input) async {
    if (input.length < 2) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$_apiKey'
        '&components=country:in';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') return [];

    return List<Map<String, dynamic>>.from(data['predictions']);
  }

  /// PLACE DETAILS (LAT / LNG)
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$_apiKey'
        '&fields=formatted_address,geometry';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final result = data['result'];

    return {
      'address': result['formatted_address'],
      'lat': result['geometry']['location']['lat'],
      'lng': result['geometry']['location']['lng'],
    };
  }
}
