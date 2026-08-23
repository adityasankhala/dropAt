import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/driver_theme.dart';
import '../services/location_service.dart';

class DriverRideScreen extends StatefulWidget {
  final String rideId;
  final double pickupLat, pickupLng, dropLat, dropLng;
  final String pickupAddress, dropAddress;
  final double fare;

  const DriverRideScreen({
    super.key,
    required this.rideId,
    required this.pickupLat, required this.pickupLng,
    required this.dropLat, required this.dropLng,
    required this.pickupAddress, required this.dropAddress,
    required this.fare,
  });

  @override
  State<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends State<DriverRideScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _locationService = LocationService();
  String _status = 'ACCEPTED';

  String get _statusLabel {
    switch (_status) {
      case 'ACCEPTED': return 'Navigate to Pickup';
      case 'DRIVERENROUTE': return 'On the way to pickup';
      case 'ARRIVED': return 'Waiting for rider';
      case 'STARTED': return 'Ride in progress';
      default: return _status;
    }
  }

  String get _nextAction {
    switch (_status) {
      case 'ACCEPTED': return 'I\'m on my way';
      case 'DRIVERENROUTE': return 'I\'ve arrived';
      case 'ARRIVED': return 'Start Ride';
      case 'STARTED': return 'Complete Ride';
      default: return 'Done';
    }
  }

  String get _nextStatus {
    switch (_status) {
      case 'ACCEPTED': return 'DRIVERENROUTE';
      case 'DRIVERENROUTE': return 'ARRIVED';
      case 'ARRIVED': return 'STARTED';
      case 'STARTED': return 'COMPLETED';
      default: return 'COMPLETED';
    }
  }

  void _advanceStatus() async {
    final next = _nextStatus;
    await _firestore.collection('rides').doc(widget.rideId).update({
      'status': next,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Start background GPS tracking when ride begins
    if (next == 'STARTED') {
      await _locationService.startTracking(widget.rideId);
    }

    // Stop tracking when ride is completed
    if (next == 'COMPLETED') {
      await _locationService.stopTracking();
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _status = next);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.pickupLat, widget.pickupLng);
    final drop = LatLng(widget.dropLat, widget.dropLng);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng((pickup.latitude + drop.latitude) / 2, (pickup.longitude + drop.longitude) / 2),
              zoom: 13,
            ),
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: pickup, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
              Marker(markerId: const MarkerId('drop'), position: drop, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
            },
            polylines: {
              Polyline(polylineId: const PolylineId('route'), points: [pickup, drop], color: DriverColors.primary, width: 4),
            },
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: DriverColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: const Icon(Icons.arrow_back_rounded, size: 22),
                ),
              ),
            ),
          ),

          // Bottom card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DriverColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: DriverColors.primarySurface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(_statusLabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: DriverColors.primary)),
                  ),
                  const SizedBox(height: 16),

                  // Route
                  Row(children: [
                    Column(children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: DriverColors.success, shape: BoxShape.circle)),
                      Container(width: 1.5, height: 24, color: DriverColors.grey),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: DriverColors.error, shape: BoxShape.circle)),
                    ]),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.pickupAddress, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DriverColors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 16),
                        Text(widget.dropAddress, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DriverColors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    )),
                    Text('₹${widget.fare.toInt()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: DriverColors.primary)),
                  ]),
                  const SizedBox(height: 20),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _advanceStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == 'STARTED' ? DriverColors.success : DriverColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_nextAction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
