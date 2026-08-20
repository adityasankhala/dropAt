import 'package:flutter/material.dart';
import '../theme/driver_theme.dart';
import 'driver_home_screen.dart';
import 'driver_ride_history_screen.dart';
import 'driver_earnings_screen.dart';
import 'driver_profile_screen.dart';

class DriverMainShell extends StatefulWidget {
  const DriverMainShell({super.key});

  @override
  State<DriverMainShell> createState() => _DriverMainShellState();
}

class _DriverMainShellState extends State<DriverMainShell> {
  int _index = 0;

  final _screens = const [
    DriverHomeScreen(),
    DriverRideHistoryScreen(),
    DriverEarningsScreen(),
    DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DriverColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'Home', 0),
                _navItem(Icons.history_rounded, 'Rides', 1),
                _navItem(Icons.account_balance_wallet_rounded, 'Earnings', 2),
                _navItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx) {
    final active = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? DriverColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? DriverColors.primary : DriverColors.grey, size: 24),
            if (active) ...[
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: DriverColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
