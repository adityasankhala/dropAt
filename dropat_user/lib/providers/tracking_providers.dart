/// DropAt — Tracking Providers (Riverpod)
/// ──────────────────────────────────────
/// WHY RIVERPOD?
/// → StatefulWidget + setState() rebuilds the ENTIRE widget tree on every GPS tick (3-5s).
///   With Riverpod, only the map marker widget rebuilds. The rest of the screen stays untouched.
///   This is critical for 60fps map animations — you can't afford full-tree rebuilds.
///
/// HOW THIS WORKS:
/// 1. User opens tracking screen with a trip_id
/// 2. tripLocationProvider(tripId) subscribes to Supabase Realtime
/// 3. Supabase pushes every DB UPDATE on location_updates as a stream event
/// 4. The StreamProvider emits the new DriverLocation
/// 5. Only the Consumer widget wrapping the map marker rebuilds
///
/// ALTERNATIVES CONSIDERED:
/// - BLoC: More boilerplate, same reactive result. Riverpod is lighter for streams.
/// - Provider (vanilla): No autodispose, no family (parameterized providers).
/// - Raw StreamBuilder: Works, but no caching. If user switches tabs and comes back,
///   the stream restarts. Riverpod caches it with autoDispose + keepAlive.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

/// Stream provider for tracking a specific trip's driver location.
///
/// Usage:
///   final location = ref.watch(tripLocationProvider('some-trip-id'));
///   location.when(
///     data: (loc) => updateMarker(loc.lat, loc.lng),
///     loading: () => showSpinner(),
///     error: (e, _) => showError(e),
///   );
final tripLocationProvider = StreamProvider.autoDispose.family<DriverLocation, String>(
  (ref, tripId) {
    // autoDispose: When the tracking screen is popped off the navigator,
    // Riverpod automatically cancels the Supabase subscription. No memory leaks.
    return SupabaseService.listenToTripLocation(tripId);
  },
);

/// Stream provider for tracking a specific driver by driver_id.
/// Used internally (e.g. admin views) when you have the driver_id directly.
final driverLocationProvider = StreamProvider.autoDispose.family<DriverLocation, String>(
  (ref, driverId) {
    return SupabaseService.listenToDriverLocation(driverId);
  },
);

/// Stream provider for booking status updates.
/// Emits whenever the booking row changes (status, driver assignment, etc.)
final bookingStatusProvider = StreamProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, bookingId) {
    return SupabaseService.listenToBookingStatus(bookingId);
  },
);
