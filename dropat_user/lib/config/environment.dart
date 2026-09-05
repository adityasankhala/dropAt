class Environment {
  /// Base URL for the FastAPI backend.
  ///
  /// Default points to the production Railway deployment.
  /// To use a LOCAL backend during development, override with:
  ///   flutter run --dart-define=API_BASE_URL=http://<YOUR-MAC-IP>:8000/api/v1
  ///
  /// Example (find your IP with `ipconfig getifaddr en0`):
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.0.100:8000/api/v1
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
