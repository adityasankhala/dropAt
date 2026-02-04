import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'signup_screen.dart';
import 'phone_login_screen.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7AAB98),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),

            // LOGO
            Column(
              children: [
                SvgPicture.asset('assets/images/dropat_logo.svg', height: 100),
                const SizedBox(height: 10),
                const Text(
                  "Dropat",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // ACTIONS
            Column(
              children: [
                SvgPicture.asset('assets/images/login_people.svg', height: 220),
                const SizedBox(height: 30),

                // GOOGLE (DISABLED – PHASE 2)
                _buildLoginButton(
                  icon: 'assets/icons/google_icon.svg',
                  label: 'Login with Google',
                  color: Colors.white,
                  textColor: Colors.black,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google login will be enabled soon'),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // APPLE (DISABLED – PHASE 2)
                _buildLoginButton(
                  icon: 'assets/icons/apple_icon.svg',
                  label: 'Login with Apple',
                  color: const Color(0xFF6E6B6B),
                  textColor: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apple login will be enabled soon'),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // PHONE LOGIN (ACTIVE – PHASE 1)
                _buildLoginButton(
                  icon: 'assets/icons/phone_icon.svg',
                  label: 'Login with Phone Number',
                  color: Colors.white,
                  textColor: Colors.black,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhoneLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // BUTTON BUILDER
  Widget _buildLoginButton({
    required String icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
