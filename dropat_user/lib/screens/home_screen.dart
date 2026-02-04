import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import '../services/places_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  LatLng? _currentLatLng;
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;

  bool _mapReady = false;
  int _selectedRideIndex = 0;

  // 💰 WALLET BALANCE (mock - will connect to backend)
  double _walletBalance = 250.00;

  // 🚗 RIDE OPTIONS with better categorization
  final List<Map<String, dynamic>> _rideOptions = [
    {
      'name': 'Auto',
      'description': 'Affordable rides',
      'icon': '🛺',
      'multiplier': 1.0,
      'seats': '3',
      'eta': '2 min',
    },
    {
      'name': 'Bike',
      'description': 'Quick & cheap',
      'icon': '🏍️',
      'multiplier': 0.7,
      'seats': '1',
      'eta': '1 min',
    },
    {
      'name': 'Mini',
      'description': 'Compact car',
      'icon': '🚗',
      'multiplier': 1.2,
      'seats': '4',
      'eta': '3 min',
    },
    {
      'name': 'Sedan',
      'description': 'Comfortable ride',
      'icon': '🚕',
      'multiplier': 1.5,
      'seats': '4',
      'eta': '4 min',
    },
    {
      'name': 'SUV',
      'description': 'Extra space',
      'icon': '🚙',
      'multiplier': 2.0,
      'seats': '6',
      'eta': '5 min',
    },
    {
      'name': 'Shuttle',
      'description': 'Share & save',
      'icon': '🚐',
      'multiplier': 0.5,
      'seats': '10+',
      'eta': '8 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
      _pickupLatLng = _currentLatLng;
      _pickupController.text = "Current location";
    });
  }

  void _confirmLocations() {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    final selectedRide = _rideOptions[_selectedRideIndex];
    debugPrint("Pickup: $_pickupLatLng");
    debugPrint("Drop: $_dropLatLng");
    debugPrint("Ride Type: ${selectedRide['name']}");

    // TODO: Navigate to fare/booking screen
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      
      // ==================== SIDE DRAWER ====================
      drawer: _buildDrawer(user),
      
      body: Stack(
        children: [
          // ==================== MAP ====================
          if (_currentLatLng != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (c) {
                _mapController.complete(c);
                setState(() => _mapReady = true);
              },
            )
          else
            Container(
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF7AAB98)),
              ),
            ),

          // ==================== TOP BAR ====================
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Menu Button
                _topBarButton(
                  icon: Icons.menu_rounded,
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const Spacer(),
                // Wallet Button
                _walletChip(),
                const SizedBox(width: 12),
                // SOS Button
                _topBarButton(
                  icon: Icons.sos_rounded,
                  onTap: () => _showSOSDialog(),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),

          // ==================== MY LOCATION BUTTON ====================
          Positioned(
            right: 16,
            bottom: 420,
            child: _topBarButton(
              icon: Icons.my_location_rounded,
              onTap: _goToCurrentLocation,
            ),
          ),

          // ==================== BOTTOM SHEET ====================
          DraggableScrollableSheet(
            initialChildSize: 0.48,
            minChildSize: 0.25,
            maxChildSize: 0.88,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ========== LOCATION INPUTS ==========
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Pickup
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7AAB98),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TypeAheadField(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: _pickupController,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: const InputDecoration(
                                          hintText: "Pickup location",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      suggestionsCallback: PlacesService.getSuggestions,
                                      itemBuilder: (_, s) =>
                                          ListTile(
                                            dense: true,
                                            leading: const Icon(Icons.location_on, size: 20),
                                            title: Text(s['description'], style: const TextStyle(fontSize: 14)),
                                          ),
                                      onSuggestionSelected: (s) async {
                                        final place = await PlacesService.getPlaceDetails(s['place_id']);
                                        setState(() {
                                          _pickupLatLng = LatLng(place['lat'], place['lng']);
                                          _pickupController.text = place['address'];
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Divider line
                              Padding(
                                padding: const EdgeInsets.only(left: 26),
                                child: Container(
                                  height: 24,
                                  width: 1.5,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              
                              // Drop
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TypeAheadField(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: _dropController,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: const InputDecoration(
                                          hintText: "Where to?",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      suggestionsCallback: PlacesService.getSuggestions,
                                      itemBuilder: (_, s) =>
                                          ListTile(
                                            dense: true,
                                            leading: const Icon(Icons.location_on, size: 20),
                                            title: Text(s['description'], style: const TextStyle(fontSize: 14)),
                                          ),
                                      onSuggestionSelected: (s) async {
                                        final place = await PlacesService.getPlaceDetails(s['place_id']);
                                        setState(() {
                                          _dropLatLng = LatLng(place['lat'], place['lng']);
                                          _dropController.text = place['address'];
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ========== RIDE OPTIONS ==========
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Choose your ride",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text("Fare info"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade600,
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Ride Cards
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rideOptions.length,
                          itemBuilder: (context, index) {
                            final ride = _rideOptions[index];
                            final isSelected = _selectedRideIndex == index;
                            return _rideOptionCard(ride, isSelected, index);
                          },
                        ),

                        const SizedBox(height: 16),

                        // ========== QUICK OPTIONS ==========
                        Row(
                          children: [
                            Expanded(child: _quickOption(Icons.access_time_filled, "Schedule")),
                            const SizedBox(width: 10),
                            Expanded(child: _quickOption(Icons.person_add_alt_1, "For Other")),
                            const SizedBox(width: 10),
                            Expanded(child: _quickOption(Icons.local_offer, "Offers")),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ========== BOOK BUTTON ==========
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_pickupLatLng != null && _dropLatLng != null)
                                ? _confirmLocations
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7AAB98),
                              disabledBackgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _rideOptions[_selectedRideIndex]['icon'],
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Book ${_rideOptions[_selectedRideIndex]['name']}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer(User? user) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF7AAB98),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.displayName?.isNotEmpty == true 
                          ? user!.displayName![0].toUpperCase() 
                          : "U",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7AAB98),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "User",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phoneNumber ?? user?.email ?? "",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "4.8 Rating",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Wallet Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AAB98), Color(0xFF5D8F7B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Wallet Balance",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "₹${_walletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "+ Add",
                      style: TextStyle(
                        color: Color(0xFF7AAB98),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _drawerItem(Icons.history, "My Rides", () {}),
                  _drawerItem(Icons.account_balance_wallet_outlined, "Wallet", () {}),
                  _drawerItem(Icons.local_offer_outlined, "Offers & Promos", () {}),
                  _drawerItem(Icons.favorite_border, "Saved Places", () {}),
                  _drawerItem(Icons.people_outline, "Refer & Earn", () {}),
                  const Divider(height: 32),
                  _drawerItem(Icons.settings_outlined, "Settings", () {}),
                  _drawerItem(Icons.headset_mic_outlined, "Support", () {}),
                  _drawerItem(Icons.info_outline, "About", () {}),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close drawer first
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const RootApp()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ==================== COMPONENTS ====================
  Widget _topBarButton({required IconData icon, required VoidCallback onTap, Color? color}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: color ?? Colors.black87, size: 24),
        ),
      ),
    );
  }

  Widget _walletChip() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Color(0xFF7AAB98), size: 20),
              const SizedBox(width: 8),
              Text(
                "₹${_walletBalance.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rideOptionCard(Map<String, dynamic> ride, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRideIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7AAB98).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF7AAB98) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Emoji Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7AAB98) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(ride['icon'], style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ride['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF7AAB98) : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${ride['seats']} seats",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ride['description'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // ETA & Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      ride['eta'],
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${(50 * ride['multiplier']).toStringAsFixed(0)}+",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF7AAB98) : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickOption(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF7AAB98)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _goToCurrentLocation() async {
    if (_currentLatLng == null) return;
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sos, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text("Emergency SOS"),
          ],
        ),
        content: const Text("Send emergency alert to your emergency contacts and local authorities?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Emergency alert sent!")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Send Alert", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
