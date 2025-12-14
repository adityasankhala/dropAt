import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/places_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentLatLng = const LatLng(26.9124, 75.7873);
  bool _locating = true;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  final _places = PlacesService(
    apiKey: "YOUR_GOOGLE_MAPS_API_KEY",
  ); // ← ADD YOUR KEY HERE
  List<PlacePrediction> _suggestions = [];
  bool _isPickup = false;

  // Ride info
  bool _showRideOptions = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _currentLatLng = LatLng(pos.latitude, pos.longitude);

      _pickupController.text = "Current Location";
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng, zoom: 14),
        ),
      );
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      setState(() => _locating = false);
    }
  }

  Future<void> _moveToPlace(PlaceDetails place) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.lat, place.lng), zoom: 14),
      ),
    );
  }

  void _onQueryChanged(String value, bool isPickup) async {
    setState(() {
      _isPickup = isPickup;
    });
    if (value.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    final results = await _places.getAutocomplete(value);
    setState(() => _suggestions = results);
  }

  Future<void> _onSuggestionTap(PlacePrediction p) async {
    final details = await _places.getPlaceDetails(p.placeId);
    if (details == null) return;

    setState(() {
      if (_isPickup) {
        _pickupController.text = details.address;
      } else {
        _dropController.text = details.address;
      }
      _suggestions.clear();
    });

    _moveToPlace(details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _currentLatLng,
              zoom: 13,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // App Bar (menu + profile)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(Icons.menu),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                ],
              ),
            ),
          ),

          // Bottom UI
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: _showRideOptions ? 360 : 360,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInputField(
                    hint: "Pickup location",
                    icon: Icons.my_location,
                    controller: _pickupController,
                    onChanged: (v) => _onQueryChanged(v, true),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    hint: "Drop location",
                    icon: Icons.location_on,
                    controller: _dropController,
                    onChanged: (v) => _onQueryChanged(v, false),
                  ),

                  // Suggestions dropdown
                  if (_suggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final s = _suggestions[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                            title: Text(s.description),
                            onTap: () => _onSuggestionTap(s),
                          );
                        },
                      ),
                    )
                  else
                    const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      if (_pickupController.text.isNotEmpty &&
                          _dropController.text.isNotEmpty) {
                        setState(() => _showRideOptions = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Next →",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildTopButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black),
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7AAB98)),
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
