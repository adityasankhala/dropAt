class Environment {
  /// Base URL for the FastAPI backend
  /// Fallback for Android emulator is 10.0.2.2, for iOS simulator it's localhost
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lifeproject-production-58dd.up.railway.app/api/v1',
  );

  /// Supabase Configuration for Realtime Tracking
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
