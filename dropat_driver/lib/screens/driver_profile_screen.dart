import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/driver_theme.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
    if (mounted) setState(() { _profile = doc.data(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = _profile?['name'] ?? user?.displayName ?? 'Driver';
    final phone = _profile?['phone'] ?? user?.phoneNumber ?? '';
    final rating = (_profile?['rating'] ?? 4.9).toDouble();
    final vehicle = _profile?['vehicleName'] ?? 'Not set';
    final vehicleNum = _profile?['vehicleNumber'] ?? '';

    return Scaffold(
      backgroundColor: DriverColors.lightGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [DriverColors.primary, DriverColors.primaryDark]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const Text('Profile', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'D',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(phone, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, size: 18, color: DriverColors.starYellow),
                      const SizedBox(width: 6),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DriverColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: DriverColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.directions_car_rounded, color: DriverColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(vehicle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: DriverColors.black)),
                    Text(vehicleNum, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: DriverColors.grey)),
                  ])),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: DriverColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Edit', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: DriverColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu
            _menuCard([
              _menuItem(Icons.person_outline_rounded, 'Edit Profile'),
              _menuItem(Icons.description_outlined, 'Documents'),
              _menuItem(Icons.settings_outlined, 'Settings'),
            ]),
            const SizedBox(height: 14),
            _menuCard([
              _menuItem(Icons.help_outline_rounded, 'Help & Support'),
              _menuItem(Icons.info_outline_rounded, 'About DropAt'),
            ]),
            const SizedBox(height: 14),
            _menuCard([
              _menuItem(Icons.logout_rounded, 'Sign Out', color: DriverColors.error, onTap: () {
                FirebaseAuth.instance.signOut();
              }),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: DriverColors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: items),
    );
  }

  Widget _menuItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? DriverColors.primary, size: 22),
      title: Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: color ?? DriverColors.black)),
      trailing: Icon(Icons.chevron_right_rounded, color: DriverColors.grey, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
