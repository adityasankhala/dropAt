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

  // Demo routes for UI preview
  final List<ShuttleRouteModel> _demoRoutes = [
    ShuttleRouteModel(
      routeId: 'demo1',
      name: 'Hostel → College',
      stops: [
        ShuttleStop(name: 'Boys Hostel', lat: 26.8467, lng: 75.5610, order: 1),
        ShuttleStop(name: 'Girls Hostel', lat: 26.8480, lng: 75.5625, order: 2),
        ShuttleStop(name: 'Main Gate', lat: 26.8500, lng: 75.5650, order: 3),
        ShuttleStop(name: 'Academic Block', lat: 26.8520, lng: 75.5670, order: 4),
      ],
      schedule: [
        ShuttleSchedule(departureTime: '07:30 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        ShuttleSchedule(departureTime: '08:00 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        ShuttleSchedule(departureTime: '08:30 AM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      ],
      price: 20,
      totalSeats: 25,
      availableSeats: 18,
    ),
    ShuttleRouteModel(
      routeId: 'demo2',
      name: 'College → Market',
      stops: [
        ShuttleStop(name: 'Academic Block', lat: 26.8520, lng: 75.5670, order: 1),
        ShuttleStop(name: 'Main Gate', lat: 26.8500, lng: 75.5650, order: 2),
        ShuttleStop(name: 'GT Mall', lat: 26.8560, lng: 75.5700, order: 3),
        ShuttleStop(name: 'City Market', lat: 26.8600, lng: 75.5730, order: 4),
      ],
      schedule: [
        ShuttleSchedule(departureTime: '04:00 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        ShuttleSchedule(departureTime: '06:00 PM', daysOfWeek: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      ],
      price: 30,
      totalSeats: 25,
      availableSeats: 12,
    ),
    ShuttleRouteModel(
      routeId: 'demo3',
      name: 'College → Railway Station',
      stops: [
        ShuttleStop(name: 'Academic Block', lat: 26.8520, lng: 75.5670, order: 1),
        ShuttleStop(name: 'Bus Stand', lat: 26.8700, lng: 75.5800, order: 2),
        ShuttleStop(name: 'Railway Station', lat: 26.9200, lng: 75.7900, order: 3),
      ],
      schedule: [
        ShuttleSchedule(departureTime: '03:00 PM', daysOfWeek: ['Fri', 'Sat']),
        ShuttleSchedule(departureTime: '05:00 PM', daysOfWeek: ['Fri', 'Sat']),
      ],
      price: 50,
      totalSeats: 25,
      availableSeats: 5,
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
