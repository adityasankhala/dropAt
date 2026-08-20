import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/shuttle_route_model.dart';
import 'api_client.dart';

class ShuttleService {
  static final ApiClient _api = ApiClient();

  /// Fetch available routes from FastAPI backend
  static Future<List<ShuttleRouteModel>> getRoutes() async {
    try {
      final data = await _api.get('/routes');
      
      final routesList = data['routes'] as List;
      return routesList.map((route) {
        
        final waypoints = route['waypoints'] as List;
        final stops = waypoints.map((w) => ShuttleStop(
          id: w['id'],
          name: w['name'],
          location: LatLng(w['lat'], w['lng']),
          estimatedArrivalOffset: w['estimated_arrival_offset_min'] ?? 0,
        )).toList();
        
        final schedules = route['schedule'] as List? ?? [];
        final schedulesList = schedules.map((s) => ShuttleSchedule(
          departureTime: s['departure_time'],
          days: List<String>.from(s['days']),
        )).toList();

        return ShuttleRouteModel(
          id: route['id'],
          name: route['name'],
          price: (route['price'] as num).toDouble(),
          totalSeats: route['total_seats'],
          stops: stops,
          schedules: schedulesList,
          isActive: route['is_active'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching routes: $e');
      // For fallback/demo if backend is offline
      return _getDemoRoutes();
    }
  }
  
  static List<ShuttleRouteModel> _getDemoRoutes() {
    return [
      ShuttleRouteModel(
        id: 'r1',
        name: 'Hostel → College',
        price: 20,
        totalSeats: 25,
        isActive: true,
        schedules: [
          ShuttleSchedule(departureTime: '08:00 AM', days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
          ShuttleSchedule(departureTime: '08:30 AM', days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        ],
        stops: [
          ShuttleStop(id: 's1', name: 'Boys Hostel B1', location: const LatLng(26.8436, 75.5652), estimatedArrivalOffset: 0),
          ShuttleStop(id: 's2', name: 'Girls Hostel G1', location: const LatLng(26.8441, 75.5661), estimatedArrivalOffset: 5),
          ShuttleStop(id: 's3', name: 'Main Gate', location: const LatLng(26.8450, 75.5670), estimatedArrivalOffset: 10),
          ShuttleStop(id: 's4', name: 'Academic Block 1', location: const LatLng(26.8465, 75.5685), estimatedArrivalOffset: 15),
        ],
      ),
    ];
  }

  /// Book a seat using FastAPI
  static Future<String> bookSeat({
    required String tripId,
    required String boardingStopName,
    required String alightingStopName,
    required String scheduleTime,
    String paymentMethod = 'CASH',
    String? voucherCode,
  }) async {
    final response = await _api.post('/bookings/shuttle', body: {
      'trip_id': tripId,
      'boarding_stop_name': boardingStopName,
      'alighting_stop_name': alightingStopName,
      'schedule_time': scheduleTime,
      'payment_method': paymentMethod,
      'voucher_code': voucherCode,
    });
    
    return response['id'];
  }
}
