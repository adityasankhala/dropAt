import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/shuttle_route_model.dart';
import '../services/shuttle_service.dart';
import 'shuttle_booking_screen.dart';

class ShuttleScreen extends StatefulWidget {
  const ShuttleScreen({super.key});

  @override
  State<ShuttleScreen> createState() => _ShuttleScreenState();
}

class _ShuttleScreenState extends State<ShuttleScreen> {
  List<ShuttleRouteModel> _routes = [];
  bool _loading = true;

  // Real Bagru → Jaipur routes (fallback when API is offline)
  final List<ShuttleRouteModel> _demoRoutes = [
    ShuttleRouteModel(
      routeId: 'city-express',
      name: 'City Express',
      stops: [
        ShuttleStop(name: 'College Campus (Bagru)', lat: 26.8156, lng: 75.5422, order: 1),
        ShuttleStop(name: 'Jaipur Airport', lat: 26.8242, lng: 75.8122, order: 2),
        ShuttleStop(name: 'Malviya Nagar', lat: 26.8530, lng: 75.8025, order: 3),
        ShuttleStop(name: 'WTP (World Trade Park)', lat: 26.8927, lng: 75.8050, order: 4),
        ShuttleStop(name: 'C-Scheme', lat: 26.9040, lng: 75.7930, order: 5),
      ],
      schedule: [
        ShuttleSchedule(departureTime: '07:00 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        ShuttleSchedule(departureTime: '05:00 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      ],
      price: 60,
      totalSeats: 30,
      availableSeats: 22,
    ),
    ShuttleRouteModel(
      routeId: 'station-express',
      name: 'Station Express',
      stops: [
        ShuttleStop(name: 'College Campus (Bagru)', lat: 26.8156, lng: 75.5422, order: 1),
        ShuttleStop(name: 'Chandpole', lat: 26.9218, lng: 75.7770, order: 2),
        ShuttleStop(name: 'Sindhi Camp Bus Stand', lat: 26.9270, lng: 75.7870, order: 3),
        ShuttleStop(name: 'Jaipur Railway Station', lat: 26.9196, lng: 75.7878, order: 4),
      ],
      schedule: [
        ShuttleSchedule(departureTime: '07:00 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        ShuttleSchedule(departureTime: '05:30 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      ],
      price: 50,
      totalSeats: 30,
      availableSeats: 18,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await ShuttleService.getRoutes();
      setState(() {
        _routes = routes.isNotEmpty ? routes : _demoRoutes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _routes = _demoRoutes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DropAtColors.lightGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DropAtColors.primary, DropAtColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Shuttle',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Affordable shared rides across campus',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Routes
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: DropAtColors.primary),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _routes.length,
                  itemBuilder: (context, index) =>
                      _routeCard(_routes[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(ShuttleRouteModel route) {
    final seatColor = (route.availableSeats ?? route.totalSeats) <= 5
        ? DropAtColors.error
        : DropAtColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route name & price
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DropAtColors.primarySurface,
                  borderRadius: BorderRadius.circular(DropAtRadius.md),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: DropAtColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route.name, style: DropAtTextStyles.h3),
                    Text(
                      '${route.stops.length} stops',
                      style: DropAtTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '₹${route.price.toInt()}',
                style: DropAtTextStyles.price.copyWith(
                  color: DropAtColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stops preview
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: route.stops.map((stop) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DropAtColors.lightGrey,
                  borderRadius:
                      BorderRadius.circular(DropAtRadius.round),
                ),
                child: Text(
                  stop.name,
                  style: DropAtTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: DropAtColors.darkGrey,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Schedule & seats
          Row(
            children: [
              // Next departure
              Icon(Icons.access_time_rounded,
                  size: 16, color: DropAtColors.grey),
              const SizedBox(width: 6),
              Text(
                route.schedule.isNotEmpty
                    ? 'Next: ${route.schedule.first.departureTime}'
                    : 'No schedule',
                style: DropAtTextStyles.bodySmall,
              ),
              const Spacer(),

              // Available seats
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: seatColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(DropAtRadius.round),
                ),
                child: Text(
                  '${route.availableSeats ?? route.totalSeats} seats left',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: seatColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Book button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ShuttleBookingScreen(route: route),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Book Seat'),
            ),
          ),
        ],
      ),
    );
  }
}
