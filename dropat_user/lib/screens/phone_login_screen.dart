import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // 📞 FORMAT + VALIDATE PHONE
  String _formatPhone(String phone) {
    phone = phone.replaceAll(' ', '').trim();

    if (phone.length < 10) {
      throw Exception('Enter valid phone number');
    }

    if (!phone.startsWith('+')) {
      return '+91$phone';
    }
    return phone;
  }

  // 📲 SEND OTP
  Future<void> _sendOTP() async {
    if (_loading) return;

    debugPrint('📲 [OTP] Starting OTP flow...');
    setState(() => _loading = true);

    late String formattedPhone;

    try {
      formattedPhone = _formatPhone(_phoneController.text);
      debugPrint('📲 [OTP] Formatted phone: $formattedPhone');
    } catch (e) {
      debugPrint('❌ [OTP] Phone format error: $e');
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid phone number')));
      return;
    }

    try {
      debugPrint('📲 [OTP] Calling verifyPhoneNumber...');
      
      // Enable test mode for Firebase test phone numbers
      // This allows testing without APNs configuration
      FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 120),

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ [OTP] Auto-verification completed!');
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          setState(() => _loading = false);
          Navigator.pop(context); // RootApp decides next screen
        },

        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ [OTP] Verification FAILED: ${e.code} - ${e.message}');
          if (!mounted) return;
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ [OTP] Code sent! VerificationId: $verificationId');
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _loading = false;
          });
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ [OTP] Auto-retrieval timeout');
          _verificationId = verificationId;
        },
      );
      debugPrint('📲 [OTP] verifyPhoneNumber call completed (awaited)');
    } catch (e) {
      debugPrint('❌ [OTP] EXCEPTION: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  // 🔑 VERIFY OTP
  Future<void> _verifyOTP() async {
    if (_verificationId == null || _loading) return;

    setState(() => _loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pop(context); // RootApp routes automatically
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7AAB98),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login with Phone",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // 📱 PHONE INPUT
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                decoration: InputDecoration(
                  hintText: "9876543210",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔢 OTP INPUT
              if (_otpSent)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter OTP",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // 🚀 ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : _otpSent
                      ? _verifyOTP
                      : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _otpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
