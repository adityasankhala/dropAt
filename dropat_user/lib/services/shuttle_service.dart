import '../models/shuttle_route_model.dart';
import 'api_client.dart';

/// ShuttleService — fetches shuttle routes from backend and handles bookings.
///
/// WHY this calls our FastAPI backend instead of Firebase directly:
/// - All business logic (seat availability, pricing, scheduling) lives in the backend
/// - The Flutter app is a thin client — it only displays data and sends user actions
/// - This makes it easy to change the backend without touching the app
class ShuttleService {
  static final ApiClient _api = ApiClient();

  /// Fetch available routes from FastAPI backend.
  /// Falls back to demo routes if the backend is unreachable,
  /// so the app UI still works during development.
  static Future<List<ShuttleRouteModel>> getRoutes() async {
    try {
      final data = await _api.get('/routes');
      
      final routesList = data['routes'] as List;
      return routesList.map((route) {
        
        final waypoints = route['waypoints'] as List? ?? [];
        final stops = waypoints.map((w) => ShuttleStop(
          name: w['name'] ?? '',
          lat: (w['lat'] ?? 0).toDouble(),
          lng: (w['lng'] ?? 0).toDouble(),
          order: w['order'] ?? 0,
        )).toList();
        
        final schedules = route['schedule'] as List? ?? [];
        final schedulesList = schedules.map((s) => ShuttleSchedule(
          departureTime: s['departure_time'] ?? '',
          daysOfWeek: List<String>.from(s['days'] ?? []),
        )).toList();

        return ShuttleRouteModel(
          routeId: route['id'] ?? '',
          name: route['name'] ?? '',
          price: (route['price'] as num?)?.toDouble() ?? 0,
          totalSeats: route['total_seats'] ?? 20,
          stops: stops,
          schedule: schedulesList,
          availableSeats: route['available_seats'],
        );
      }).toList();
    } catch (e) {
      // Backend unreachable — return demo routes so the UI still renders
      return _getDemoRoutes();
    }
  }
  
  /// Demo routes for offline/development testing.
  /// These mirror the real Bagru → Jaipur routes seeded in the backend.
  static List<ShuttleRouteModel> _getDemoRoutes() {
    return [
      ShuttleRouteModel(
        routeId: 'city-express',
        name: 'City Express',
        price: 80,
        totalSeats: 25,
        schedule: [
          ShuttleSchedule(departureTime: '08:00 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
          ShuttleSchedule(departureTime: '05:30 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        ],
        stops: [
          ShuttleStop(name: 'College (Bagru)', lat: 26.8156, lng: 75.5422, order: 0),
          ShuttleStop(name: 'Jaipur Airport', lat: 26.8242, lng: 75.8122, order: 1),
          ShuttleStop(name: 'Malviya Nagar', lat: 26.8530, lng: 75.8025, order: 2),
          ShuttleStop(name: 'WTP', lat: 26.8927, lng: 75.8050, order: 3),
          ShuttleStop(name: 'C-Scheme', lat: 26.9040, lng: 75.7930, order: 4),
        ],
      ),
      ShuttleRouteModel(
        routeId: 'station-express',
        name: 'Station Express',
        price: 70,
        totalSeats: 25,
        schedule: [
          ShuttleSchedule(departureTime: '07:30 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
          ShuttleSchedule(departureTime: '06:00 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        ],
        stops: [
          ShuttleStop(name: 'College (Bagru)', lat: 26.8156, lng: 75.5422, order: 0),
          ShuttleStop(name: 'Chandpole', lat: 26.9218, lng: 75.7770, order: 1),
          ShuttleStop(name: 'Sindhi Camp', lat: 26.9270, lng: 75.7870, order: 2),
          ShuttleStop(name: 'Railway Station', lat: 26.9196, lng: 75.7878, order: 3),
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
