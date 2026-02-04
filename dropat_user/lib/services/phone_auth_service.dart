import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static int? _resendToken;

  // 🔐 SEND OTP
  static Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function()? onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _formatPhone(phoneNumber),
        timeout: const Duration(seconds: 60),

        // ⚡ Android auto-verification (rare on iOS)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (onAutoVerified != null) onAutoVerified();
        },

        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Phone verification failed');
        },

        codeSent: (String verificationId, int? resendToken) {
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // 🔑 VERIFY OTP
  static Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }

  // 📞 FORMAT PHONE NUMBER (CRITICAL)
  static String _formatPhone(String phone) {
    phone = phone.replaceAll(' ', '').replaceAll('-', '');
    if (!phone.startsWith('+')) {
      return '+91$phone'; // default India
    }
    return phone;
  }
}
