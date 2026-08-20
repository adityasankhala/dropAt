import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/vehicle_type.dart';
import '../models/ride_model.dart';
import '../models/ride_status.dart';
import '../services/directions_service.dart';
import '../services/fare_service.dart';
import '../services/ride_repository.dart';
import '../widgets/vehicle_card.dart';
import 'voucher_screen.dart';
import 'payment_method_screen.dart';
import 'booking_detail_screen.dart';

class ChooseVehicleScreen extends StatefulWidget {
  final LatLng pickup;
  final LatLng drop;
  final String pickupAddress;
  final String dropAddress;

  const ChooseVehicleScreen({
    super.key,
    required this.pickup,
    required this.drop,
    required this.pickupAddress,
    required this.dropAddress,
  });

  @override
  State<ChooseVehicleScreen> createState() => _ChooseVehicleScreenState();
}

class _ChooseVehicleScreenState extends State<ChooseVehicleScreen>
    with SingleTickerProviderStateMixin {
  VehicleType _selectedType = VehicleType.bike;
  DirectionsResult? _directions;
  bool _loading = true;
  String _paymentMethod = 'Cash';
  double _discount = 0;
  Set<Polyline> _polylines = {};

  late AnimationController _sheetCtrl;
  late Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));

    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final directions = await DirectionsService.getRoute(
      origin: widget.pickup,
      destination: widget.drop,
    );

    setState(() {
      _directions = directions;
      _loading = false;
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: directions.polylinePoints,
          color: DropAtColors.primary,
          width: 5,
        ),
      };
    });

    _sheetCtrl.forward();
  }

  String _getFareEstimate(VehicleType type) {
    if (_directions == null) return '...';
    return FareService.estimateFare(
      distanceKm: _directions!.distanceKm,
      durationMin: _directions!.durationMin,
      vehicleType: type,
    );
  }

  double _getSelectedFare() {
    if (_directions == null) return 0;
    final breakdown = FareService.calculateFare(
      distanceKm: _directions!.distanceKm,
      durationMin: _directions!.durationMin,
      vehicleType: _selectedType,
      discount: _discount,
    );
    return breakdown.total;
  }

  Future<void> _bookRide() async {
    if (_directions == null) return;

    final breakdown = FareService.calculateFare(
      distanceKm: _directions!.distanceKm,
      durationMin: _directions!.durationMin,
      vehicleType: _selectedType,
      discount: _discount,
    );

    // Create ride
    final ride = RideModel(
      userId: FirebaseAuth.instance.currentUser?.uid,
      pickup: widget.pickup,
      drop: widget.drop,
      pickupAddress: widget.pickupAddress,
      dropAddress: widget.dropAddress,
      distanceMeters: _directions!.distanceMeters.toDouble(),
      durationSeconds: _directions!.durationSeconds,
      vehicleType: _selectedType,
      fare: breakdown.subtotal,
      discountAmount: breakdown.discount,
      totalPaid: breakdown.total,
      paymentMethod: _paymentMethod.toUpperCase(),
      status: RideStatus.requested,
      encodedPolyline: _directions!.encodedPolyline,
    );

    try {
      final rideId = await RideRepository.createRide(ride: ride);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(
            rideId: rideId,
            pickup: widget.pickup,
            drop: widget.drop,
            pickupAddress: widget.pickupAddress,
            dropAddress: widget.dropAddress,
            polylinePoints: _directions!.polylinePoints,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    }
  }

  // Premium Map Style (Silver/Clean)
  static const String _mapStyle = '''
[
  { "elementType": "geometry", "stylers": [ { "color": "#f5f5f5" } ] },
  { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] },
  { "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] },
  { "elementType": "labels.text.stroke", "stylers": [ { "color": "#f5f5f5" } ] },
  { "featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#eeeeee" } ] },
  { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] },
  { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#e5e5e5" } ] },
  { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#ffffff" } ] },
  { "featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#dadada" } ] },
  { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#c9c9c9" } ] }
]
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
            onMapCreated: (controller) => controller.setMapStyle(_mapStyle),
            polylines: _polylines,
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: widget.pickup,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('drop'),
                position: widget.drop,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
                    boxShadow: DropAtShadows.medium,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 22, color: DropAtColors.black),
                ),
              ),
            ),
          ),

          // Loading
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: DropAtColors.primary),
            ),

          // Bottom sheet
          if (!_loading)
            SlideTransition(
              position: _sheetSlide,
              child: _buildBottomSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: DropAtColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: DropAtShadows.premium,
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Route Info Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DropAtColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _directions?.durationText ?? '...',
                    style: DropAtTextStyles.label.copyWith(color: DropAtColors.primaryDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '· ${_directions?.distanceText ?? '...'}',
                  style: DropAtTextStyles.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.info_outline_rounded, size: 20, color: DropAtColors.grey),
              ],
            ),
            const SizedBox(height: 20),

            // Vehicle options
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: VehicleType.values
                      .where((v) => v != VehicleType.shuttle)
                      .map((type) => VehicleCard(
                            vehicleType: type,
                            fareEstimate: _getFareEstimate(type),
                            isSelected: type == _selectedType,
                            onTap: () => setState(() => _selectedType = type),
                          ))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Payment & promo row
            Row(
              children: [
                _actionButton(Icons.money_rounded, _paymentMethod, _openPaymentMethod),
                const SizedBox(width: 12),
                _actionButton(
                  Icons.local_offer_rounded,
                  _discount > 0 ? '₹${_discount.toInt()} off' : 'Promo',
                  _openVoucher,
                  active: _discount > 0,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Book button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _bookRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DropAtColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm ${_selectedType.displayName} · ₹${_getSelectedFare().toInt()}',
                      style: DropAtTextStyles.button.copyWith(fontSize: 17),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? DropAtColors.primary.withOpacity(0.05) : DropAtColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            border: active ? Border.all(color: DropAtColors.primary.withOpacity(0.3)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? DropAtColors.primary : DropAtColors.primaryDark),
              const SizedBox(width: 8),
              Text(label, style: DropAtTextStyles.labelSmall),
            ],
          ),
        ),
      ),
    );
  }

  void _openPaymentMethod() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );
    if (result != null) {
      setState(() => _paymentMethod = result);
    }
  }

  void _openVoucher() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => const VoucherScreen()),
    );
    if (result != null) {
      setState(() => _discount = result);
    }
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }
}
