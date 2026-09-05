import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_options_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  await SupabaseService.initialize();

  // ProviderScope is the root of all Riverpod providers.
  // It must wrap the entire app so any screen can use ref.watch().
  runApp(const ProviderScope(child: DropAtApp()));
}

class DropAtApp extends StatelessWidget {
  const DropAtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DropAt',
      debugShowCheckedModeBanner: false,
      theme: DropAtTheme.lightTheme,
      home: const RootApp(),
    );
  }
}

/// 🔑 ROOT AUTH DECIDER
class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash for 2.8 seconds on cold start, then reveal the auth-based screen
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash on cold start
    if (_showSplash) {
      return const SplashScreen();
    }

    // ❌ USER NOT LOGGED IN → Login (Bypassing Firebase to show UI)
    return const LoginOptionsScreen();
  }
}
