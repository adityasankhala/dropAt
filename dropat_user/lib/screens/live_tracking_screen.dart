/// DropAt — Live Tracking Screen
/// This screen shows a real-time map with the shuttle's position.
/// It uses Mapbox GL for the map and Riverpod to listen to Supabase events.
///
/// ARCHITECTURE FLOW:
/// ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
/// │ Driver App   │ ──▶ │ FastAPI      │ ──▶ │ PostgreSQL   │
/// │ (GPS batch)  │     │ (upsert row) │     │ (location_   │
/// │              │     │              │     │  updates)    │
/// └──────────────┘     └──────────────┘     └──────┬───────┘
///                                                  │ Supabase
///                                                  │ Realtime
///                                                  ▼
///                                           ┌──────────────┐
///                                           │ This Screen  │
///                                           │ (Riverpod    │
///                                           │  Consumer)   │
///                                           └──────────────┘

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../providers/tracking_providers.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String routeName;

  const LiveTrackingScreen({
    super.key,
    required this.tripId,
    required this.routeName,
  });

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  PointAnnotation? _driverAnnotation;

  // Track whether we've centered the camera on first location
  bool _hasCenteredOnDriver = false;

  @override
  Widget build(BuildContext context) {
    // WHY ref.watch here?
    // → Riverpod rebuilds ONLY this widget when a new GPS event arrives.
    //   The rest of the widget tree (AppBar, bottom sheet) stays untouched.
    final locationAsync = ref.watch(tripLocationProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Live indicator dot
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: locationAsync.hasValue ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  locationAsync.hasValue ? 'LIVE' : 'CONNECTING...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: locationAsync.hasValue ? Colors.green : Colors.orange,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAP
          MapWidget(
            key: const ValueKey('mapbox_tracking'),
            onMapCreated: _onMapCreated,
            styleUri: MapboxStyles.LIGHT,
            cameraOptions: CameraOptions(
              // Default center: Jaipur
              center: Point(coordinates: Position(75.7873, 26.9124)),
              zoom: 14.0,
            ),
          ),

          // BOTTOM INFO CARD
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInfoCard(locationAsync),
          ),
        ],
      ),
    );
  }

  /// Called once when the Mapbox map is ready
  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
  }

  /// Build a translucent info card at the bottom with speed/heading data
  Widget _buildInfoCard(AsyncValue<DriverLocation> locationAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: locationAsync.when(
        data: (loc) {
          // Update the map marker whenever new data arrives
          _updateDriverMarker(loc);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus, color: Color(0xFF6C63FF), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.routeName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shuttle is ${loc.isMoving ? "en route" : "stopped"}',
                          style: TextStyle(
                            color: loc.isMoving ? Colors.green.shade700 : Colors.orange.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statTile(
                    'Speed',
                    loc.speed != null ? '${loc.speed!.toStringAsFixed(0)} km/h' : '--',
                    Icons.speed,
                  ),
                  _statTile(
                    'Heading',
                    loc.heading != null ? '${loc.heading!.toStringAsFixed(0)}°' : '--',
                    Icons.explore,
                  ),
                  _statTile(
                    'Updated',
                    _timeAgo(loc.timestamp),
                    Icons.access_time,
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Text('Tracking error: $e', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  /// Move/create the driver marker on the map
  void _updateDriverMarker(DriverLocation loc) async {
    if (_annotationManager == null) return;
    if (loc.lat == 0 && loc.lng == 0) return; // No valid location yet

    final point = Point(coordinates: Position(loc.lng, loc.lat));

    if (_driverAnnotation != null) {
      // Update existing marker position (smooth movement)
      _driverAnnotation!.geometry = point;
      await _annotationManager!.update(_driverAnnotation!);
    } else {
      // Create new marker
      _driverAnnotation = await _annotationManager!.create(
        PointAnnotationOptions(
          geometry: point,
          iconSize: 1.5,
          textField: '🚌',
          textSize: 24,
        ),
      );
    }

    // Center camera on first location received
    if (!_hasCenteredOnDriver) {
      _hasCenteredOnDriver = true;
      await _mapboxMap?.flyTo(
        CameraOptions(center: point, zoom: 15.0),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 10) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
