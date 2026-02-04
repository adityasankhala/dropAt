import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_options_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ❗ KEEP THIS ONLY DURING DEVELOPMENT
  // ❗ REMOVE before production / TestFlight
  await FirebaseAuth.instance.signOut();

  runApp(const DropAtApp());
}

class DropAtApp extends StatelessWidget {
  const DropAtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DropAt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF7AAB98),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7AAB98),
          secondary: Colors.black,
        ),
      ),
      home: const RootApp(),
    );
  }
}

/// 🔑 ROOT AUTH DECIDER (DO NOT USE const SCREENS INSIDE)
class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Firebase booting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ✅ USER LOGGED IN
        if (snapshot.hasData) {
          return SplashScreen(nextScreen: HomeScreen());
        }

        // ❌ USER NOT LOGGED IN
        return SplashScreen(nextScreen: LoginOptionsScreen());
      },
    );
  }
}
