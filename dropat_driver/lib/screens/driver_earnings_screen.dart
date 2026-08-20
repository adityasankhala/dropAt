import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/driver_theme.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  double _todayEarnings = 0;
  double _weekEarnings = 0;
  double _totalEarnings = 0;
  int _totalTrips = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    final allRides = await FirebaseFirestore.instance.collection('rides')
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'COMPLETED')
        .get();

    double today = 0, week = 0, total = 0;
    for (final doc in allRides.docs) {
      final fare = (doc.data()['totalPaid'] ?? 0).toDouble();
      final created = (doc.data()['createdAt'] as Timestamp?)?.toDate();
      total += fare;
      if (created != null && created.isAfter(startOfDay)) today += fare;
      if (created != null && created.isAfter(startOfWeek)) week += fare;
    }

    if (mounted) setState(() {
      _todayEarnings = today;
      _weekEarnings = week;
      _totalEarnings = total;
      _totalTrips = allRides.docs.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.lightGrey,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: DriverColors.primary))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [DriverColors.primary, DriverColors.primaryDark]),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          const Text('Earnings', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 24),
                          const Text('Today\'s Earnings', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('₹${_todayEarnings.toInt()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _card('This Week', '₹${_weekEarnings.toInt()}', Icons.calendar_today_rounded),
                          const SizedBox(width: 14),
                          _card('Total', '₹${_totalEarnings.toInt()}', Icons.account_balance_wallet_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _card('Total Trips', '$_totalTrips', Icons.directions_car_rounded),
                          const SizedBox(width: 14),
                          _card('Avg/Trip', _totalTrips > 0 ? '₹${(_totalEarnings / _totalTrips).toInt()}' : '₹0', Icons.trending_up_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Withdraw button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Withdrawal feature coming soon! 🏦'), backgroundColor: DriverColors.primary),
                            );
                          },
                          icon: const Icon(Icons.account_balance_rounded),
                          label: const Text('Withdraw Earnings'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _card(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DriverColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: DriverColors.primary, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: DriverColors.black)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: DriverColors.grey)),
          ],
        ),
      ),
    );
  }
}
