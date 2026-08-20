import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import 'api_client.dart';

class UserRepository {
  static final ApiClient _api = ApiClient();

  /// Creates or gets the profile from FastAPI via the /auth/verify endpoint.
  /// This is called right after Firebase login.
  static Future<void> createOrUpdateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _api.post('/auth/verify', body: {
      'name': name ?? user.displayName,
      'phone': phone ?? user.phoneNumber,
      'email': email ?? user.email,
      'photo_url': user.photoURL,
    });
  }

  /// Get profile from FastAPI
  static Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final data = await _api.get('/users/me');
      return UserProfileModel(
        uid: data['firebase_uid'],
        name: data['name'] ?? 'User',
        phone: data['phone'] ?? '',
        email: data['email'],
        photoUrl: data['photo_url'],
        rating: (data['rating'] as num).toDouble(),
        walletBalance: (data['wallet_balance'] as num).toDouble(),
        joinedAt: DateTime.parse(data['created_at']),
        savedPlaces: [],
      );
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// The rest of the methods would point to the FastAPI user endpoints...
  static Future<void> updateWalletBalance(String uid, double amount) async {
    // Should be handled securely by payment webhooks, not client side
  }

  static Future<void> addSavedPlace(String uid, SavedPlace place) async {
    await _api.post('/users/me/saved-places', body: place.toMap());
  }
}
