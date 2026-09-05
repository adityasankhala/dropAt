import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Listen for new ride requests broadcast via Supabase Realtime
  static Stream<List<Map<String, dynamic>>> listenToNewRides() {
    return client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('status', 'requested')
        .eq('booking_type', 'ride') // Phase 2: On-demand rides
        .map((events) => events);
  }
}
