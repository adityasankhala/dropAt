import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/shuttle_route_model.dart';
import '../services/shuttle_service.dart';

class ShuttleBookingScreen extends StatefulWidget {
  final ShuttleRouteModel route;

  const ShuttleBookingScreen({super.key, required this.route});

  @override
  State<ShuttleBookingScreen> createState() => _ShuttleBookingScreenState();
}

class _ShuttleBookingScreenState extends State<ShuttleBookingScreen> {
  int? _boardingIndex;
  int? _alightingIndex;
  int _selectedScheduleIndex = 0;
  bool _booking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DropAtColors.white,
      appBar: AppBar(
        backgroundColor: DropAtColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.route.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route stops
            Text('Route Stops', style: DropAtTextStyles.h3),
            const SizedBox(height: 16),
            _buildStopsList(),

            const SizedBox(height: 28),

            // Schedule
            Text('Select Time', style: DropAtTextStyles.h3),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                widget.route.schedule.length,
                (index) {
                  final schedule = widget.route.schedule[index];
                  final isSelected = index == _selectedScheduleIndex;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedScheduleIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DropAtColors.primary
                            : DropAtColors.lightGrey,
                        borderRadius:
                            BorderRadius.circular(DropAtRadius.md),
                      ),
                      child: Column(
                        children: [
                          Text(
                            schedule.departureTime,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : DropAtColors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.daysOfWeek.join(', '),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white70
                                  : DropAtColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Summary
            if (_boardingIndex != null && _alightingIndex != null)
              _buildSummary(),

            const SizedBox(height: 28),

            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook ? _book : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor:
                      DropAtColors.grey.withOpacity(0.3),
                ),
                child: _booking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Confirm Booking  ₹${widget.route.price.toInt()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsList() {
    return Column(
      children: List.generate(widget.route.stops.length, (index) {
        final stop = widget.route.stops[index];
        final isBoarding = _boardingIndex == index;
        final isAlighting = _alightingIndex == index;
        final isLast = index == widget.route.stops.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isBoarding
                        ? DropAtColors.pickupGreen
                        : isAlighting
                            ? DropAtColors.dropRed
                            : const Color(0xFFD0D0D0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isBoarding || isAlighting
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isBoarding || isAlighting
                        ? [
                            BoxShadow(
                              color: (isBoarding
                                      ? DropAtColors.pickupGreen
                                      : DropAtColors.dropRed)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: const Color(0xFFD0D0D0),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Stop details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.name, style: DropAtTextStyles.label),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _stopAction(
                        'Board here',
                        isBoarding,
                        () => setState(() => _boardingIndex = index),
                      ),
                      const SizedBox(width: 8),
                      if (index > (_boardingIndex ?? -1))
                        _stopAction(
                          'Alight here',
                          isAlighting,
                          () =>
                              setState(() => _alightingIndex = index),
                        ),
                    ],
                  ),
                  SizedBox(height: isLast ? 0 : 14),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _stopAction(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? DropAtColors.primary
              : DropAtColors.lightGrey,
          borderRadius: BorderRadius.circular(DropAtRadius.round),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : DropAtColors.darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final boarding = widget.route.stops[_boardingIndex!];
    final alighting = widget.route.stops[_alightingIndex!];
    final schedule = widget.route.schedule[_selectedScheduleIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DropAtColors.primarySurface,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
      ),
      child: Column(
        children: [
          _summaryRow('Boarding', boarding.name),
          const SizedBox(height: 8),
          _summaryRow('Alighting', alighting.name),
          const SizedBox(height: 8),
          _summaryRow('Time', schedule.departureTime),
          const SizedBox(height: 8),
          _summaryRow('Price', '₹${widget.route.price.toInt()}'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DropAtTextStyles.bodyMedium),
        Text(value, style: DropAtTextStyles.label),
      ],
    );
  }

  bool get _canBook =>
      _boardingIndex != null &&
      _alightingIndex != null &&
      _alightingIndex! > _boardingIndex! &&
      !_booking;

  Future<void> _book() async {
    setState(() => _booking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await ShuttleService.bookSeat(
        tripId: widget.route.routeId,
        boardingStopName: widget.route.stops[_boardingIndex!].name,
        alightingStopName: widget.route.stops[_alightingIndex!].name,
        scheduleTime:
            widget.route.schedule[_selectedScheduleIndex].departureTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shuttle booked successfully! 🚐'),
          backgroundColor: DropAtColors.primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }
}
