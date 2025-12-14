import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen; // ✅ Allow navigation to any next screen

  const SplashScreen({super.key, this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // 🚀 Automatically go to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;

    if (widget.nextScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.nextScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7AAB98), // your mint green color
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SvgPicture.asset(
            'assets/images/splash_screen.svg',
            width: MediaQuery.of(context).size.width * 0.75,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
