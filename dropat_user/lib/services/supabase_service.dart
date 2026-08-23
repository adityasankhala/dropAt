import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment.dart';

/// Lightweight data class for a driver's GPS position.
/// Keeps this service independent of any map SDK.
class DriverLocation {
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final bool isMoving;
  final DateTime timestamp;

  const DriverLocation({
    required this.lat,
    required this.lng,
    this.heading,
    this.speed,
    this.isMoving = true,
    required this.timestamp,
  });

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    return DriverLocation(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      heading: map['heading'] != null ? (map['heading'] as num).toDouble() : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      isMoving: map['is_moving'] ?? true,
      timestamp: DateTime.parse(map['timestamp'] ?? map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Listen to live location updates for a specific trip.
  /// 
  /// WHY trip_id and not driver_id?
  /// → A passenger books a TRIP, not a driver. The trip_id is what they have.
  ///   The backend writes the trip_id into location_updates when the driver starts.
  ///   This makes the query natural and avoids a round-trip to resolve driver_id.
  static Stream<DriverLocation> listenToTripLocation(String tripId) {
    return client
        .from('location_updates')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .map((events) {
          if (events.isEmpty) {
            return DriverLocation(lat: 0, lng: 0, timestamp: DateTime.now());
          }

          // Sort by timestamp to get the latest (upsert pattern means usually 1 row)
          events.sort((a, b) =>
            DateTime.parse(b['updated_at']).compareTo(DateTime.parse(a['updated_at']))
          );

          return DriverLocation.fromMap(events.first);
        });
  }

  /// Listen to live location updates for a specific driver (direct lookup).
  static Stream<DriverLocation> listenToDriverLocation(String driverId) {
    return client
        .from('location_updates')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((events) {
          if (events.isEmpty) {
            return DriverLocation(lat: 0, lng: 0, timestamp: DateTime.now());
          }
          return DriverLocation.fromMap(events.first);
        });
  }

  /// Listen to booking status changes (e.g. driver accepted, arrived)
  static Stream<Map<String, dynamic>> listenToBookingStatus(String bookingId) {
    return client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .map((events) {
          if (events.isEmpty) return {};
          return events.first;
        });
  }
}

