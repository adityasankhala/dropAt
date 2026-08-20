import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/driver_theme.dart';
import '../services/google_auth_service.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;
  int? _forceResendingToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DriverColors.primary, Color(0xFF5D8F7B)],
            stops: [0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_taxi_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('DropAt Driver', style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Start earning with every ride', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DriverColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_codeSent ? 'Enter OTP' : 'Sign In', style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: DriverColors.black)),
                      const SizedBox(height: 8),
                      Text(_codeSent ? 'Enter the 6-digit code sent to your phone' : 'Enter your phone number to get started', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DriverColors.grey)),
                      const SizedBox(height: 24),
                      if (!_codeSent)
                        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, style: const TextStyle(fontFamily: 'Poppins'), decoration: const InputDecoration(hintText: '+91 Phone Number', prefixIcon: Icon(Icons.phone_rounded, color: DriverColors.primary)))
                      else
                        TextField(controller: _otpCtrl, keyboardType: TextInputType.number, maxLength: 6, style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '------', counterText: '')),
                      if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(fontFamily: 'Poppins', color: DriverColors.error, fontSize: 13))],
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : (_codeSent ? _verifyOTP : _sendOTP), child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_codeSent ? 'Verify' : 'Send OTP'))),
                      if (_codeSent) ...[
                        const SizedBox(height: 14),
                        Center(child: GestureDetector(onTap: () => setState(() { _codeSent = false; _otpCtrl.clear(); _error = null; }), child: const Text('Change phone number', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DriverColors.primary)))),
                      ],
                      if (!_codeSent) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: DriverColors.grey.withOpacity(0.3))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: DriverColors.grey, fontWeight: FontWeight.w500)),
                            ),
                            Expanded(child: Divider(color: DriverColors.grey.withOpacity(0.3))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _googleLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: DriverColors.grey.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _googleLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFF4285F4)),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: DriverColors.black),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      final result = await GoogleAuthService.signIn();
      if (result == null && mounted) {
        setState(() { _googleLoading = false; });
      }
    } catch (e) {
      debugPrint('❌ [Google] Sign-in error: $e');
      if (mounted) setState(() { _error = 'Google sign-in failed. Please try again.'; _googleLoading = false; });
    }
  }

  Future<void> _sendOTP() async {
    final phone = _phoneCtrl.text.replaceAll(' ', '').trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final fullPhone = phone.startsWith('+') ? phone : '+91$phone';

    try {
      debugPrint('📲 [OTP] Sending to $fullPhone');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (credential) async {
          debugPrint('✅ [OTP] Auto-verification completed');
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          debugPrint('❌ [OTP] Verification failed: ${e.code} - ${e.message}');
          if (mounted) setState(() {
            _error = e.code == 'too-many-requests'
                ? 'Too many attempts. Try again later.'
                : (e.message ?? 'Verification failed');
            _loading = false;
          });
        },
        codeSent: (verificationId, resendToken) {
          debugPrint('✅ [OTP] Code sent! ID: $verificationId');
          _forceResendingToken = resendToken;
          if (mounted) setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _loading = false;
          });
        },
        codeAutoRetrievalTimeout: (id) {
          debugPrint('⏱️ [OTP] Auto-retrieval timeout');
          _verificationId = id;
          if (mounted) setState(() => _loading = false);
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [OTP] FirebaseAuthException: ${e.code} - ${e.message}');
      if (mounted) setState(() { _error = e.message ?? 'Auth error'; _loading = false; });
    } catch (e) {
      debugPrint('❌ [OTP] Exception: $e');
      if (mounted) setState(() { _error = 'Error: ${e.toString()}'; _loading = false; });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpCtrl.text.length != 6 || _verificationId == null) {
      setState(() => _error = 'Enter a valid 6-digit OTP');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: _otpCtrl.text.trim());
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [OTP] Verify error: ${e.code} - ${e.message}');
      if (mounted) setState(() { _error = e.message ?? 'Invalid OTP. Please try again.'; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Invalid OTP. Please try again.'; _loading = false; });
    }
  }

  @override
  void dispose() { _phoneCtrl.dispose(); _otpCtrl.dispose(); super.dispose(); }
}
