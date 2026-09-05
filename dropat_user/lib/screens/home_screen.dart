import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';
import '../services/places_service.dart';
import '../services/ride_repository.dart';
import '../models/driver_model.dart';
import '../models/vehicle_type.dart';
import 'choose_vehicle_screen.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng _currentPos = const LatLng(26.9124, 75.7873); // Jaipur default

  final TextEditingController _pickupCtrl = TextEditingController();
  final TextEditingController _dropCtrl = TextEditingController();

  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;
  String? _pickupAddress;
  String? _dropAddress;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchingPickup = false;
  bool _isSearchingDrop = false;
  bool _showLocationSearch = false;
  String? _searchFor; // 'pickup' or 'drop'

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;
  late AnimationController _pulseController;

  List<DriverModel> _nearbyDrivers = [];
  StreamSubscription? _driverSubscription;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sheetController.forward();
    _getCurrentLocation();
    _initDriverListener();
  }

  void _initDriverListener() {
    _driverSubscription = RideRepository.listenToNearbyDrivers().listen((data) {
      if (mounted) {
        setState(() {
          _nearbyDrivers = data.map((d) => DriverModel.fromMap(d)).toList();
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPos = LatLng(position.latitude, position.longitude);
          _pickupLatLng = _currentPos;
          _pickupCtrl.text = 'Current Location';
          _pickupAddress = 'Current Location';
        });
      }
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 15));
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await PlacesService.getSuggestions(query);
    if (mounted) setState(() => _searchResults = results);
  }

  void _onPlaceSelected(Map<String, dynamic> place) async {
    try {
      final details = await PlacesService.getPlaceDetails(place['place_id']);

      final lat = details['lat'];
      final lng = details['lng'];
      if (lat == null || lng == null) return;

      final latLng = LatLng(lat.toDouble(), lng.toDouble());
      final address = details['address'] ?? place['description'] ?? '';

      setState(() {
        if (_searchFor == 'pickup') {
          _pickupLatLng = latLng;
          _pickupCtrl.text = place['description'] ?? address;
          _pickupAddress = address;
        } else {
          _dropLatLng = latLng;
          _dropCtrl.text = place['description'] ?? address;
          _dropAddress = address;
        }
        _searchResults = [];
        _showLocationSearch = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

      // If both set, go to vehicle selection
      if (_pickupLatLng != null && _dropLatLng != null) {
        _navigateToVehicleSelection();
      }
    } catch (e) {
      debugPrint('Place selection error: $e');
    }
  }

  void _navigateToVehicleSelection() {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseVehicleScreen(
          pickup: _pickupLatLng!,
          drop: _dropLatLng!,
          pickupAddress: _pickupAddress ?? 'Pickup',
          dropAddress: _dropAddress ?? 'Drop',
        ),
      ),
    );
  }

  void _openSearchFor(String type) {
    setState(() {
      _searchFor = type;
      _showLocationSearch = true;
      _searchResults = [];
    });
  }

  void _setQuickDestination(String name, LatLng latLng) {
    setState(() {
      _dropLatLng = latLng;
      _dropCtrl.text = name;
      _dropAddress = name;
    });
    if (_pickupLatLng != null) {
      _navigateToVehicleSelection();
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
    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPos,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController?.setMapStyle(_mapStyle);
          },
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Floating Top Header
        if (!_showLocationSearch)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Hamburger Menu — opens MainShell drawer
                  Builder(
                    builder: (innerContext) => _circleButton(
                      Icons.menu_rounded,
                      () => Scaffold.of(innerContext).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: DropAtColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: DropAtShadows.light,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _pickupAddress ?? 'Fetching location...',
                        style: DropAtTextStyles.labelSmall.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleButton(Icons.my_location_rounded, () {
                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPos, 15));
                  }),
                ],
              ),
            ),
          ),

        // Location search overlay
        if (_showLocationSearch) _buildSearchOverlay(),

        // Integrated Bottom UI
        if (!_showLocationSearch)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _sheetAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _sheetAnimation,
                  curve: Curves.easeOutCubic,
                )),
                child: _buildMainUI(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainUI() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dashboard Content
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: DropAtColors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: DropAtShadows.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _animatedSearchBar(),
                const SizedBox(height: 12),

                // Recent Places List (Snippet)
                _recentTripItem(Icons.access_time_rounded, 'Elements Mall Jaipur', 'Subway Elements Mall...'),
                _recentTripItem(Icons.access_time_rounded, 'Dyore Restaurant', 'Experience 16 Pari...'),
                _recentTripItem(Icons.access_time_rounded, 'Manipal University', 'Manipal University Jaipur...'),
              ],
            ),
          ),
          const SizedBox(height: 100), // Clearance for glassy nav
        ],
      ),
    );
  }

  Widget _animatedSearchBar() {
    return GestureDetector(
      onTap: () => _openSearchFor('drop'),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Ring
              Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: DropAtColors.primary.withOpacity(0.3 * (1 - _pulseController.value)),
                    width: 8 * _pulseController.value,
                  ),
                ),
              ),
              // Main Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: DropAtColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DropAtColors.primary.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: DropAtColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: DropAtColors.black, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Enter Destination',
                      style: DropAtTextStyles.h3.copyWith(
                        color: DropAtColors.black.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _recentTripItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: DropAtColors.grey, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DropAtTextStyles.label.copyWith(fontSize: 14)),
                Text(subtitle, style: DropAtTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: DropAtColors.grey, size: 20),
        ],
      ),
    );
  }

  void _onSelectQuickDestination(LatLng destination, String address) {
    setState(() {
      _dropLatLng = destination;
      _dropCtrl.text = address;
    });
    _navigateToVehicleSelection();
  }

  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DropAtColors.lightGrey,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
      ),
      child: Row(
        children: [
          // Dots
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: DropAtColors.pickupGreen,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1.5,
                height: 28,
                color: const Color(0xFFBBBBBB),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: DropAtColors.dropRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _openSearchFor('pickup'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _pickupCtrl.text.isNotEmpty
                          ? _pickupCtrl.text
                          : 'Choose pick up point',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: _pickupCtrl.text.isNotEmpty
                            ? DropAtColors.black
                            : DropAtColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFDDDDDD)),
                GestureDetector(
                  onTap: () => _openSearchFor('drop'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _dropCtrl.text.isNotEmpty
                          ? _dropCtrl.text
                          : 'Choose your DropAt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: _dropCtrl.text.isNotEmpty
                            ? DropAtColors.black
                            : DropAtColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: Container(
        color: DropAtColors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showLocationSearch = false),
                      child: const Icon(Icons.arrow_back_rounded, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: DropAtColors.lightGrey,
                          borderRadius:
                              BorderRadius.circular(DropAtRadius.md),
                        ),
                        child: TextField(
                          autofocus: true,
                          onChanged: _onSearchChanged,
                          style: DropAtTextStyles.bodyMedium.copyWith(
                            color: DropAtColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: _searchFor == 'pickup'
                                ? 'Search pickup location'
                                : 'Search drop location',
                            hintStyle: DropAtTextStyles.bodyMedium
                                .copyWith(color: DropAtColors.grey),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: DropAtColors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DropAtColors.primarySurface,
                          borderRadius:
                              BorderRadius.circular(DropAtRadius.sm),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: DropAtColors.primary, size: 20),
                      ),
                      title: Text(
                        place['description'] ?? '',
                        style: DropAtTextStyles.bodyMedium.copyWith(
                          color: DropAtColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _onPlaceSelected(place),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String emoji, String label, LatLng latLng) {
    return GestureDetector(
      onTap: () => _setQuickDestination(label, latLng),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: DropAtColors.primarySurface,
          borderRadius: BorderRadius.circular(DropAtRadius.round),
          border: Border.all(color: DropAtColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: DropAtTextStyles.labelSmall.copyWith(
                color: DropAtColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedPlaceTile(
      IconData icon, String title, String subtitle, LatLng latLng) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DropAtColors.primarySurface,
          borderRadius: BorderRadius.circular(DropAtRadius.sm),
        ),
        child: Icon(icon, color: DropAtColors.primary, size: 20),
      ),
      title:
          Text(title, style: DropAtTextStyles.label.copyWith(fontSize: 14)),
      subtitle: Text(subtitle, style: DropAtTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: DropAtColors.grey),
      onTap: () => _setQuickDestination(title, latLng),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, color: DropAtColors.black, size: 22),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_pickupLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup'),
      ));
    }
    if (_dropLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Drop'),
      ));
    }

    // Add nearby drivers
    for (final driver in _nearbyDrivers) {
      if (driver.lat != null && driver.lng != null) {
        markers.add(Marker(
          markerId: MarkerId('driver_${driver.uid}'),
          position: LatLng(driver.lat!, driver.lng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getDriverHue(driver.vehicleType)),
          infoWindow: InfoWindow(title: '${driver.name} (${driver.vehicleType.displayName})'),
        ));
      }
    }

    // Phase 1 Real Use Case: Fixed Drop Points for Shuttle Routes
    final dropPoints = {
      'College (Bagru)': const LatLng(26.8156, 75.5422),
      'Chandpole': const LatLng(26.9218, 75.7770),
      'Sindhi Camp': const LatLng(26.9270, 75.7870),
      'Railway Station': const LatLng(26.9196, 75.7878),
      'Jaipur Airport': const LatLng(26.8242, 75.8122),
      'Malviya Nagar': const LatLng(26.8530, 75.8025),
      'WTP': const LatLng(26.8927, 75.8050),
      'C-Scheme': const LatLng(26.9040, 75.7930),
    };

    for (final point in dropPoints.entries) {
      markers.add(Marker(
        markerId: MarkerId('stop_${point.key}'),
        position: point.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: '${point.key} Drop Point', snippet: 'Shuttle Stop'),
      ));
    }

    return markers;
  }

  double _getDriverHue(VehicleType type) {
    switch (type) {
      case VehicleType.bike:
        return BitmapDescriptor.hueOrange;
      case VehicleType.auto:
        return BitmapDescriptor.hueRose;
      case VehicleType.mini:
      case VehicleType.sedan:
      case VehicleType.suv:
        return BitmapDescriptor.hueCyan;
      case VehicleType.shuttle:
        return BitmapDescriptor.hueViolet;
    }
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    _sheetController.dispose();
    _pulseController.dispose();
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
