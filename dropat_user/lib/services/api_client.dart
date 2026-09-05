import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/environment.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _baseUrl = Environment.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    String? token;
    if (user != null) {
      token = await user.getIdToken();
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
  
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.delete(uri, headers: headers);
      
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String message = 'API Error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body['detail'] != null) {
          message = body['detail'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
