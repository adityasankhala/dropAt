import 'package:flutter/material.dart';
import 'driver_home_screen.dart';

class DriverLoginScreen extends StatelessWidget {
  const DriverLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
            );
          },
          child: const Text("Login (Temporary)"),
        ),
      ),
    );
  }
}
