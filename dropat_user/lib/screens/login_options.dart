import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7AAB98),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to DropAt 🚗",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            _loginButton("Continue with Google", Icons.g_mobiledata, context),
            const SizedBox(height: 16),
            _loginButton("Continue with Apple", Icons.apple, context),
            const SizedBox(height: 16),
            _loginButton("Login with Phone Number", Icons.phone, context),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text(
                "Don’t have an account? Sign Up",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(String text, IconData icon, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (text.contains("Phone")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      icon: Icon(icon, color: Colors.white, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
