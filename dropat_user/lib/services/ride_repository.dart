import '../models/ride_model.dart';
import '../models/ride_status.dart';
import '../models/vehicle_type.dart';
import '../models/lat_lng.dart';
import 'api_client.dart';
import 'supabase_service.dart';

/// RideRepository — handles ride CRUD and real-time status listening.
///
/// WHY this exists as a separate layer from ApiClient:
/// - ApiClient is generic HTTP (GET/POST/PUT/DELETE)
/// - RideRepository adds ride-specific business logic:
///   mapping backend statuses → local enums, Supabase Realtime streams
/// - This separation means screens don't know about API details
class RideRepository {
  static final ApiClient _api = ApiClient();

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
    return SupabaseService.listenToBookingStatus(rideId).map((data) {
      if (data.isEmpty) throw Exception('Ride not found');
      
      // Convert backend status to local enum
      RideStatus status;
      switch (data['status']) {
        case 'pending':
        case 'confirmed':
        case 'requested': status = RideStatus.requested; break;
        case 'searching': status = RideStatus.searching; break;
        case 'accepted': status = RideStatus.accepted; break;
        case 'driver_en_route': status = RideStatus.driverEnRoute; break;
        case 'arrived': status = RideStatus.arrived; break;
        case 'started': status = RideStatus.started; break;
        case 'completed': status = RideStatus.completed; break;
        case 'cancelled':
        case 'refunded': status = RideStatus.cancelled; break;
        default: status = RideStatus.requested;
      }
      
      VehicleType vType = VehicleType.bike;
      try {
        final typeStr = (data['vehicle_type'] ?? 'bike').toString().toLowerCase();
        vType = VehicleType.values.firstWhere((e) => e.name == typeStr, orElse: () => VehicleType.bike);
      } catch (_) {}

      return RideModel(
        rideId: data['id'],
        userId: data['user_id'],
        pickup: const LatLng(0, 0), // Coordinates fetched separately from trip table
        drop: const LatLng(0, 0),
        pickupAddress: data['boarding_stop_name'] ?? 'Pickup',
        dropAddress: data['alighting_stop_name'] ?? 'Drop',
        distanceMeters: 0,
        durationSeconds: 0,
        vehicleType: vType,
        fare: (data['fare'] as num).toDouble(),
        discountAmount: (data['discount_amount'] as num).toDouble(),
        totalPaid: (data['total_paid'] as num).toDouble(),
        paymentMethod: data['payment_method'],
        status: status,
        driverId: data['driver_id'],
      );
    });
  }

  /// Cancel a ride via API
  static Future<void> cancelRide(String rideId, String reason) async {
    await _api.delete('/bookings/$rideId?reason=${Uri.encodeComponent(reason)}');
  }

  /// Get active rides from API
  static Future<RideModel?> getActiveRide() async {
    try {
      final response = await _api.get('/bookings/me?status=active&limit=1');
      if (response['bookings'] != null && (response['bookings'] as List).isNotEmpty) {
        return RideModel(
          rideId: response['bookings'][0]['id'],
          userId: '',
          pickup: const LatLng(0, 0),
          drop: const LatLng(0, 0),
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

  /// Listen to nearby drivers (for home screen markers)
  /// Returns a stream of driver location maps
  static Stream<List<Map<String, dynamic>>> listenToNearbyDrivers() {
    // TODO: Wire to Supabase Realtime channel for driver locations
    // For now return empty stream
    return Stream.value([]);
  }
}
