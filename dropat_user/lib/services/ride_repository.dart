import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps_flutter;
import '../models/ride_model.dart';
import '../models/ride_status.dart';
import '../models/vehicle_type.dart';
import 'api_client.dart';

class RideRepository {
  static final ApiClient _api = ApiClient();

  /// Listen to nearby drivers
  static Stream<dynamic> listenToNearbyDrivers() {
    return const Stream.empty();
  }

  /// Get user ride history
  static Future<List<RideModel>> getUserRideHistory() async {
    return [];
  }

  /// Create a ride booking via API
  static Future<String> createRide({required RideModel ride}) async {
    final response = await _api.post('/bookings/ride', body: {
      'pickup_lat': ride.pickup.latitude,
      'pickup_lng': ride.pickup.longitude,
      'drop_lat': ride.drop.latitude,
      'drop_lng': ride.drop.longitude,
      'pickup_address': ride.pickupAddress,
      'drop_address': ride.dropAddress,
      'vehicle_type': ride.vehicleType.name.toUpperCase(),
      'payment_method': ride.paymentMethod,
    });
    
    return response['id'];
  }

  /// Listen to ride status updates via Supabase Realtime
  static Stream<RideModel> listenToRide(String rideId) {
    // SupabaseService is not yet implemented
    return const Stream.empty();
  }

  /// Cancel a ride via API
  static Future<void> cancelRide(String rideId, String reason) async {
    await _api.delete('/bookings/$rideId?reason=${Uri.encodeComponent(reason)}');
  }

  /// Rate a ride
  static Future<void> rateRide({
    required String rideId,
    required double rating,
    String? feedback,
    double? tipAmount,
  }) async {
    await _api.post('/bookings/$rideId/rate', body: {
      'rating': rating,
      'feedback': feedback,
      'tip_amount': tipAmount,
    });
  }

  /// Get active rides from API
  static Future<RideModel?> getActiveRide() async {
    try {
      final response = await _api.get('/bookings/me?status=active&limit=1');
      if (response['bookings'] != null && (response['bookings'] as List).isNotEmpty) {
        // Just return a dummy model to trigger the UI if there is an active ride
        return RideModel(
          rideId: response['bookings'][0]['id'],
          userId: '',
          pickup: const google_maps_flutter.LatLng(0, 0),
          drop: const google_maps_flutter.LatLng(0, 0),
          pickupAddress: '',
          dropAddress: '',
          distanceMeters: 0,
          durationSeconds: 0,
          vehicleType: VehicleType.shuttle,
          fare: 0,
          totalPaid: 0,
          paymentMethod: 'CASH',
          status: RideStatus.requested,
        );
      }
    } catch (e) {
      print('Error getting active ride: $e');
    }
    return null;
  }
}
