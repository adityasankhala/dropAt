import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/supabase_service.dart';
import 'theme/driver_theme.dart';
import 'screens/driver_splash_screen.dart';
import 'screens/driver_login_screen.dart';
import 'screens/driver_main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.initialize();
  runApp(const DropAtDriverApp());
}

class DropAtDriverApp extends StatelessWidget {
  const DropAtDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DropAt Driver',
      debugShowCheckedModeBanner: false,
      theme: DriverTheme.lightTheme,
      home: const DriverRootApp(),
    );
  }
}

class DriverRootApp extends StatelessWidget {
  const DriverRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DriverSplashScreen();
        }

        if (snapshot.hasData) {
          return DriverSplashScreen(nextScreen: const DriverMainShell());
        }

        return DriverSplashScreen(nextScreen: const DriverLoginScreen());
      },
    );
  }
}
