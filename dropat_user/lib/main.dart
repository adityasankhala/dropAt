import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_options_screen.dart'; // first onboarding screen
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ⚡ Force logout every time you rebuild (for demo/testing)
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
        scaffoldBackgroundColor: const Color(0xFF7AAB98), // mint background
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7AAB98),
          secondary: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      home: const RootApp(),
    );
  }
}

/// 🌟 RootApp decides which screen to show
class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ While Firebase initializes → show Splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // 🔓 If user logged in → show Home
        if (snapshot.hasData) {
          return const SplashScreen(nextScreen: HomeScreen());
        }

        // 🔐 If user NOT logged in → show onboarding login options
        return const SplashScreen(nextScreen: LoginOptionsScreen());
      },
    );
  }
}
