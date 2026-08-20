import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static Future<UserCredential?> signIn() async {
    final googleUser = await GoogleSignIn().signIn();
    
    // User cancelled the sign-in flow
    if (googleUser == null) return null;
    
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn().disconnect();
    } catch (_) {}
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}
