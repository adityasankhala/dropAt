import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  bool isOnline = false;
  LatLng? _currentLatLng;

  StreamSubscription<QuerySnapshot>? _rideSub;
  Map<String, dynamic>? _incomingRide;
  String? _rideId;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 14));

    setState(() {});
  }

  void _startListeningForRides() {
    _rideSub = FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'REQUESTED')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) return;

          final doc = snapshot.docs.first;

          setState(() {
            _rideId = doc.id;
            _incomingRide = doc.data() as Map<String, dynamic>;
          });
        });
  }

  void _stopListening() {
    _rideSub?.cancel();
    _rideSub = null;
    _incomingRide = null;
    _rideId = null;
  }

  Future<void> _acceptRide() async {
    if (_rideId == null) return;

    await FirebaseFirestore.instance.collection('rides').doc(_rideId).update({
      'status': 'ACCEPTED',
      'driverId': FirebaseAuth.instance.currentUser!.uid,
    });

    _stopListening();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 13,
            ),
            myLocationEnabled: true,
            onMapCreated: (c) => _mapController.complete(c),
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnline ? Colors.red : Colors.green,
              ),
              onPressed: () {
                setState(() => isOnline = !isOnline);
                isOnline ? _startListeningForRides() : _stopListening();
              },
              child: Text(isOnline ? 'Go Offline' : 'Go Online'),
            ),
          ),

          if (_incomingRide != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Ride Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _acceptRide,
                      child: const Text('Accept Ride'),
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
