import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../models/ride_status.dart';
import '../models/driver_model.dart';
import '../models/vehicle_type.dart';
import '../services/ride_repository.dart';
import 'cancel_booking_screen.dart';
import 'rate_trip_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String rideId;
  final LatLng pickup;
  final LatLng drop;
  final String pickupAddress;
  final String dropAddress;
  final List<LatLng> polylinePoints;

  const BookingDetailScreen({
    super.key,
    required this.rideId,
    required this.pickup,
    required this.drop,
    required this.pickupAddress,
    required this.dropAddress,
    required this.polylinePoints,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  DriverModel? _driver;
  List<LatLng> _currentPolyline = [];

  @override
  void initState() {
    super.initState();
    _currentPolyline = widget.polylinePoints;
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return [widget.pickup, widget.drop];
    final polylinePoints = PolylinePoints();
    final decoded = polylinePoints.decodePolyline(encoded);
    return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<RideModel>(
        stream: RideRepository.listenToRide(widget.rideId),
        builder: (context, snapshot) {
          final ride = snapshot.data;
          final status = ride?.status ?? RideStatus.requested;

          if (ride != null && ride.encodedPolyline != null && _currentPolyline.length <= 2) {
             _currentPolyline = _decodePolyline(ride.encodedPolyline!);
          }

          // If completed, navigate to rating
          if (status == RideStatus.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RateTripScreen(
                    rideId: widget.rideId,
                    driverName: _driver?.name ?? ride?.driverId ?? 'Driver',
                    pickupAddress: widget.pickupAddress,
                    dropAddress: widget.dropAddress,
                    fare: ride?.fare ?? 0,
                    discount: ride?.discountAmount ?? 0,
                    total: ride?.totalPaid ?? 0,
                  ),
                ),
              );
            });
          }

          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (widget.pickup.latitude + widget.drop.latitude) / 2,
                    (widget.pickup.longitude + widget.drop.longitude) / 2,
                  ),
                  zoom: 13,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _currentPolyline,
                    color: DropAtColors.primary,
                    width: 5,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: widget.pickup,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('drop'),
                    position: widget.drop,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DropAtColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child:
                          const Icon(Icons.arrow_back_rounded, size: 22),
                    ),
                  ),
                ),
              ),

              // Bottom info card
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildInfoCard(ride, status),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(RideModel? ride, RideStatus status) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(DropAtRadius.round),
            ),
            child: Text(
              status.displayLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _statusColor(status),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Driver info (when assigned)
          if (status == RideStatus.requested ||
              status == RideStatus.searching)
            _searchingWidget()
          else
            _driverInfoWidget(ride),

          const SizedBox(height: 16),

          // Route info
          _routeInfo(),

          const SizedBox(height: 16),

          // Stats row
          if (ride != null) _statsRow(ride),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Cancel button
              if (status != RideStatus.started &&
                  status != RideStatus.completed)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelRide(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DropAtColors.error,
                      side: const BorderSide(color: DropAtColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DropAtRadius.md),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (status.isActive) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Call driver placeholder
                    },
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchingWidget() {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: DropAtColors.primary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Looking for your driver...',
          style: DropAtTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _driverInfoWidget(RideModel? ride) {
    // Use placeholder driver when real driver not loaded
    final driverName = ride?.driverId ?? 'Saksham Jain';
    _driver = DriverModel(
      uid: ride?.driverId ?? '',
      name: driverName,
      phone: '',
      vehicleName: 'Maruti Suzuki',
      vehicleNumber: 'RJ 14 AB 1234',
      vehicleType: ride?.vehicleType ?? _driver?.vehicleType ?? VehicleType.mini,
      rating: 4.9,
    );

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: DropAtColors.primarySurface,
          child: Text(
            driverName.isNotEmpty ? driverName[0] : 'D',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DropAtColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driverName, style: DropAtTextStyles.h3),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: DropAtColors.starYellow),
                  const SizedBox(width: 4),
                  Text('4.9', style: DropAtTextStyles.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeInfo() {
    return Column(
      children: [
        _routeRow(DropAtColors.pickupGreen, widget.pickupAddress),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 1.5,
            height: 20,
            color: const Color(0xFFCCCCCC),
          ),
        ),
        _routeRow(DropAtColors.dropRed, widget.dropAddress),
      ],
    );
  }

  Widget _routeRow(Color dotColor, String address) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: DropAtTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statsRow(RideModel ride) {
    return Row(
      children: [
        _statItem('Distance', '${ride.distanceKm.toStringAsFixed(1)} km'),
        _divider(),
        _statItem('Time', '${ride.durationMin} min'),
        _divider(),
        _statItem('Price', '₹${ride.totalPaid.toInt()}'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: DropAtTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: DropAtTextStyles.label),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE0E0E0),
    );
  }

  Color _statusColor(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
      case RideStatus.searching:
        return DropAtColors.accent;
      case RideStatus.accepted:
      case RideStatus.driverEnRoute:
      case RideStatus.arrived:
        return DropAtColors.primary;
      case RideStatus.started:
        return Colors.blue;
      case RideStatus.completed:
        return DropAtColors.success;
      case RideStatus.cancelled:
        return DropAtColors.error;
    }
  }

  void _cancelRide() async {
    final reason = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CancelBookingScreen()),
    );
    if (reason != null && mounted) {
      await RideRepository.cancelRide(widget.rideId, reason);
      if (mounted) Navigator.pop(context);
    }
  }
}
