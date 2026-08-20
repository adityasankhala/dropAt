import 'package:flutter/material.dart';


class DriverSplashScreen extends StatefulWidget {
  final Widget? nextScreen;
  const DriverSplashScreen({super.key, this.nextScreen});

  @override
  State<DriverSplashScreen> createState() => _DriverSplashScreenState();
}

class _DriverSplashScreenState extends State<DriverSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late AnimationController _textCtrl;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)));

    _textCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _textFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 2500), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted || widget.nextScreen == null) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen!,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8BBFA8), Color(0xFF7AAB98), Color(0xFF6A9B88)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _textFade,
                child: const Column(
                  children: [
                    Text(
                      'DropAt',
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 32,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Driver Partner',
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 16,
                        color: Colors.white70, letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }
}
