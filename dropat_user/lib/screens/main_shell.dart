import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../services/google_auth_service.dart';
import 'home_screen.dart';
import 'shuttle_screen.dart';
import 'ride_history_screen.dart';
import 'profile_screen.dart';
import 'voucher_screen.dart';
import 'payment_method_screen.dart';

class TabNavigationNotification extends Notification {
  final int index;
  TabNavigationNotification(this.index);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onDrawerItemTap(int index) {
    Navigator.pop(context); // Close drawer first
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShuttleScreen(),
    const RideHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return NotificationListener<TabNavigationNotification>(
      onNotification: (notification) {
        setState(() => _currentIndex = notification.index);
        return true;
      },
      child: Scaffold(
        extendBody: true,
        drawer: isDesktop ? null : _buildDrawer(),
        body: Row(
          children: [
            if (isDesktop)
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: DropAtColors.white,
                selectedIconTheme: const IconThemeData(color: DropAtColors.primaryDark),
                unselectedIconTheme: IconThemeData(color: DropAtColors.black.withOpacity(0.45)),
                selectedLabelTextStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: DropAtColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: DropAtColors.black.withOpacity(0.45),
                ),
                labelType: NavigationRailLabelType.all,
                useIndicator: true,
                indicatorColor: DropAtColors.primary.withOpacity(0.2),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.directions_bus_outlined),
                    selectedIcon: Icon(Icons.directions_bus_rounded),
                    label: Text('Shuttle'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history_rounded),
                    label: Text('Rides'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Account'),
                  ),
                ],
              ),
            if (isDesktop)
               const VerticalDivider(thickness: 1, width: 1, color: DropAtColors.lightGrey),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isDesktop
            ? null
            : DropAtBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      backgroundColor: DropAtColors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              color: DropAtColors.primary,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: DropAtColors.primaryLight,
                        child: Text(
                          user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: DropAtColors.primaryDark),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: DropAtColors.accent, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if ((user?.phoneNumber ?? '').isNotEmpty)
                  Text(
                    user!.phoneNumber!,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  ),
                if ((user?.email ?? '').isNotEmpty)
                  Text(
                    user!.email!,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                  ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _drawerItem(
                  Icons.home_rounded,
                  'Home',
                  subtitle: 'Back to map',
                  onTap: () => _onDrawerItemTap(0),
                ),
                _drawerItem(
                  Icons.history_rounded,
                  'My Rides',
                  subtitle: 'View ride history',
                  onTap: () => _onDrawerItemTap(2),
                ),
                _drawerItem(
                  Icons.account_balance_wallet_outlined,
                  'Payments',
                  subtitle: 'Manage payment methods',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
                    );
                  },
                ),
                _drawerItem(
                  Icons.local_offer_outlined,
                  'Vouchers',
                  subtitle: 'Apply promo codes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoucherScreen()),
                    );
                  },
                ),
                _drawerItem(
                  Icons.directions_bus_rounded,
                  'Shuttle Service',
                  subtitle: 'Campus shuttle routes',
                  onTap: () => _onDrawerItemTap(1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 24),
                ),
                _drawerItem(
                  Icons.support_agent_rounded,
                  'Help & Support',
                  subtitle: 'Get assistance',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog();
                  },
                ),
                _drawerItem(
                  Icons.info_outline_rounded,
                  'About DropAt',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),

          // Sign Out
          const Divider(height: 1),
          _drawerItem(
            Icons.logout_rounded,
            'Sign Out',
            color: DropAtColors.error,
            subtitle: 'Log out of your account',
            onTap: () async {
              Navigator.pop(context); // Close drawer first
              await GoogleAuthService.signOut();
              // StreamBuilder in main.dart handles navigation back to login
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? DropAtColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? DropAtColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? DropAtColors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: DropAtColors.grey,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? DropAtColors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showHelpDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: DropAtColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DropAtColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.support_agent_rounded, size: 48, color: DropAtColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Help & Support',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Need help? Our support team is here for you.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: DropAtColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _helpOption(Icons.email_outlined, 'Email Support', 'support@dropat.in'),
            _helpOption(Icons.phone_outlined, 'Call Us', '+91 98765 43210'),
            _helpOption(Icons.chat_outlined, 'Live Chat', 'Available 9 AM - 9 PM'),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  Widget _helpOption(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DropAtColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: DropAtColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: DropAtColors.grey)),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: DropAtColors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DropAtColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_taxi_rounded, size: 36, color: DropAtColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'DropAt',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: DropAtColors.black),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: DropAtColors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your campus ride, simplified.\nBuilt by Team DropAt.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: DropAtColors.darkGrey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
