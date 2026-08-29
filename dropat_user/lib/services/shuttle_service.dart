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
          name: w['name'],
          lat: w['lat'],
          lng: w['lng'],
          order: 0,
        )).toList();
        
        final schedules = route['schedule'] as List? ?? [];
        final schedulesList = schedules.map((s) => ShuttleSchedule(
          departureTime: s['departure_time'],
          daysOfWeek: List<String>.from(s['days']),
        )).toList();

        return ShuttleRouteModel(
          routeId: route['id'],
          name: route['name'],
          price: (route['price'] as num).toDouble(),
          totalSeats: route['total_seats'],
          stops: stops,
          schedule: schedulesList,
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
        routeId: 'r1',
        name: 'Hostel → College',
        price: 20,
        totalSeats: 25,
        schedule: [
          ShuttleSchedule(departureTime: '08:00 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
          ShuttleSchedule(departureTime: '08:30 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        ],
        stops: [
          ShuttleStop(name: 'Boys Hostel B1', lat: 26.8436, lng: 75.5652, order: 1),
          ShuttleStop(name: 'Girls Hostel G1', lat: 26.8441, lng: 75.5661, order: 2),
          ShuttleStop(name: 'Main Gate', lat: 26.8450, lng: 75.5670, order: 3),
          ShuttleStop(name: 'Academic Block 1', lat: 26.8465, lng: 75.5685, order: 4),
        ],
      ),
    ];
  }

  /// Book a seat using FastAPI
  static Future<String> bookSeat({
    required String userId,
    required String routeId,
    required String boardingStop,
    required String alightingStop,
    required String scheduleTime,
    String paymentMethod = 'CASH',
    String? voucherCode,
  }) async {
    final response = await _api.post('/bookings/shuttle', body: {
      'user_id': userId,
      'trip_id': routeId,
      'boarding_stop_name': boardingStop,
      'alighting_stop_name': alightingStop,
      'schedule_time': scheduleTime,
      'payment_method': paymentMethod,
      'voucher_code': voucherCode,
    });
    
    return response['id'];
  }
}
