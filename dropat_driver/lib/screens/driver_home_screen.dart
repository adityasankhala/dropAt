import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../theme/driver_theme.dart';
import 'driver_ride_screen.dart';
import '../services/location_service.dart';
import '../services/supabase_service.dart';
import '../services/api_client.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPos = const LatLng(26.9124, 75.7873);
  bool _isOnline = false;
  Map<String, dynamic>? _pendingRide;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _rideSubscription;

  double _todayEarnings = 0;
  int _tripsCompleted = 0;
  double _rating = 4.9;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadStats();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPos = LatLng(pos.latitude, pos.longitude));
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 15));
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final rides = await _firestore.collection('rides')
          .where('driverId', isEqualTo: uid)
          .where('status', isEqualTo: 'COMPLETED')
          .get();

      double earnings = 0;
      for (final doc in rides.docs) {
        earnings += (doc.data()['totalPaid'] ?? 0).toDouble();
      }

      if (mounted) {
        setState(() {
          _todayEarnings = earnings;
          _tripsCompleted = rides.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Stats error: $e');
    }
  }

  void _toggleOnline() {
    setState(() => _isOnline = !_isOnline);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _updateDriverStatus();

    if (_isOnline) {
      _startListeningForRides();
      _startLocationUpdates();
    } else {
      _rideSubscription?.cancel();
      _rideSubscription = null;
      _locationTimer?.cancel();
    }
  }

  void _updateDriverStatus() {
    LocationService.toggleOnline(
      _isOnline, 
      lat: _currentPos.latitude, 
      lng: _currentPos.longitude
    );
  }

  Timer? _locationTimer;
  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isOnline) {
        timer.cancel();
        return;
      }
      try {
        final pos = await Geolocator.getCurrentPosition();
        setState(() => _currentPos = LatLng(pos.latitude, pos.longitude));
        
        LocationService.pushLocationUpdate(
          lat: pos.latitude,
          lng: pos.longitude,
          speed: pos.speed,
          heading: pos.heading,
        );
      } catch (e) {
         debugPrint('Location update error: $e');
      }
    });
  }

  void _startListeningForRides() {
    _rideSubscription?.cancel();

    debugPrint('🚗 [Driver] Starting to listen for ride requests...');

    // Simple query - no orderBy to avoid needing a composite index
    _rideSubscription = _firestore.collection('rides')
        .where('status', isEqualTo: 'REQUESTED')
        .snapshots()
        .listen((snapshot) {
      debugPrint('🚗 [Driver] Got ${snapshot.docs.length} ride requests');
      if (!mounted || !_isOnline) return;
      if (snapshot.docs.isNotEmpty && _pendingRide == null) {
        final ride = snapshot.docs.first;
        debugPrint('🚗 [Driver] Showing ride: ${ride.id}');
        _showRideRequest(ride.id, ride.data());
      }
    }, onError: (e) {
      debugPrint('❌ [Driver] Ride listener error: $e');
    });
  }

  void _showRideRequest(String rideId, Map<String, dynamic> data) {
    if (_pendingRide != null) return;
    setState(() => _pendingRide = {'id': rideId, ...data});
  }

  void _acceptRide() async {
    if (_pendingRide == null) return;
    final rideId = _pendingRide!['id'];
    final uid = FirebaseAuth.instance.currentUser?.uid;

    await _firestore.collection('rides').doc(rideId).update({
      'status': 'ACCEPTED',
      'driverId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    final rideData = _pendingRide!;
    setState(() => _pendingRide = null);

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DriverRideScreen(
        rideId: rideId,
        pickupLat: (rideData['pickup']?['lat'] ?? 0).toDouble(),
        pickupLng: (rideData['pickup']?['lng'] ?? 0).toDouble(),
        dropLat: (rideData['drop']?['lat'] ?? 0).toDouble(),
        dropLng: (rideData['drop']?['lng'] ?? 0).toDouble(),
        pickupAddress: rideData['pickupAddress'] ?? 'Pickup',
        dropAddress: rideData['dropAddress'] ?? 'Drop',
        fare: (rideData['totalPaid'] ?? 0).toDouble(),
      ),
    )).then((_) => _loadStats());
  }

  void _declineRide() {
    setState(() => _pendingRide = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPos, zoom: 15),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            liteModeEnabled: false,
          ),

          // Top status bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isOnline ? DriverColors.success : DriverColors.error,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Location button
                  GestureDetector(
                    onTap: () => _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 15)),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: DriverColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                      child: const Icon(Icons.my_location_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCard(),
          ),

          // Ride request popup
          if (_pendingRide != null) _buildRideRequestPopup(),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DriverColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats row
          Row(
            children: [
              _statCard('Today', '₹${_todayEarnings.toInt()}', Icons.account_balance_wallet_rounded),
              const SizedBox(width: 12),
              _statCard('Trips', '$_tripsCompleted', Icons.directions_car_rounded),
              const SizedBox(width: 12),
              _statCard('Rating', _rating.toStringAsFixed(1), Icons.star_rounded),
            ],
          ),
          const SizedBox(height: 20),

          // Online toggle
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleOnline,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOnline ? DriverColors.error : DriverColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isOnline ? Icons.power_settings_new_rounded : Icons.play_arrow_rounded, size: 22, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(_isOnline ? 'Go Offline' : 'Go Online', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DriverColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: DriverColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: DriverColors.black)),
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: DriverColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestPopup() {
    final pickup = _pendingRide?['pickupAddress'] ?? 'Pickup';
    final drop = _pendingRide?['dropAddress'] ?? 'Drop';
    final fare = (_pendingRide?['totalPaid'] ?? 0).toDouble();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DriverColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_rounded, size: 48, color: DriverColors.primary),
                  const SizedBox(height: 14),
                  const Text('New Ride Request!', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Route
                  Row(children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: DriverColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(pickup, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  Padding(padding: const EdgeInsets.only(left: 4), child: Container(width: 2, height: 16, color: DriverColors.grey)),
                  Row(children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: DriverColors.error, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(drop, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 16),

                  // Fare
                  Text('₹${fare.toInt()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: DriverColors.primary)),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: _declineRide,
                      style: OutlinedButton.styleFrom(foregroundColor: DriverColors.error, side: const BorderSide(color: DriverColors.error), padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Decline'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: _acceptRide,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Accept'),
                    )),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
