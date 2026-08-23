import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/environment.dart';
import 'api_client.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static final ApiClient _api = ApiClient();
  bool _isConfigured = false;

  /// Configure the background geolocation plugin
  /// This sets up the SQLite queueing and HTTP batch pushing.
  Future<void> configure() async {
    if (_isConfigured) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final token = await user.getIdToken();

    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0, // meters
      stopOnTerminate: false,
      startOnBoot: true,
      debug: false,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      
      // HTTP Batch Pushing Configuration
      url: '${Environment.apiBaseUrl}/tracking/update',
      method: 'POST',
      batchSync: true,      // Send multiple locations in a single array
      maxBatchSize: 50,     // Max locations to send per request
      autoSync: true,       // Automatically sync when internet is available
      autoSyncThreshold: 1, // Sync immediately when we have 1 location in the queue
      
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      
      // Map the plugin's JSON to match FastAPI's LocationBatchRequest
      // We wrap the batch in an "updates" key since our request schema expects it
      httpRootProperty: 'updates',
      locationTemplate: '{ "lat": <%= latitude %>, "lng": <%= longitude %>, "heading": <%= heading %>, "speed": <%= speed %>, "accuracy": <%= accuracy %>, "battery_level": <%= battery.level %>, "is_moving": <%= is_moving %> }',
    ));

    _isConfigured = true;
  }

  /// Start tracking the driver
  Future<void> startTracking(String tripId) async {
    if (!_isConfigured) await configure();
    
    // Add tripId to the HTTP extras so it gets sent with every batch
    await bg.BackgroundGeolocation.setConfig(bg.Config(
      extras: {
        'trip_id': tripId,
      }
    ));

    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true); // Force it into moving state
  }

  /// Stop tracking the driver
  Future<void> stopTracking() async {
    await bg.BackgroundGeolocation.stop();
  }

  /// Push driver location updates manually (legacy/fallback)
  static Future<void> pushLocationUpdate({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    bool isMoving = true,
  }) async {
    try {
      await _api.post('/tracking/update', body: {
        'updates': [
          {
            'lat': lat,
            'lng': lng,
            'heading': heading,
            'speed': speed,
            'is_moving': isMoving,
          }
        ]
      });
    } catch (e) {
      print('Failed to push location: $e');
    }
  }
  
  static Future<void> toggleOnline(bool isOnline, {double? lat, double? lng}) async {
    try {
      await _api.post('/drivers/toggle-online', body: {
        'is_online': isOnline,
        'lat': lat,
        'lng': lng,
      });
    } catch (e) {
      print('Failed to toggle online status: $e');
    }
  }
}
