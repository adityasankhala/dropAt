import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/driver_theme.dart';

class DriverRideHistoryScreen extends StatefulWidget {
  const DriverRideHistoryScreen({super.key});

  @override
  State<DriverRideHistoryScreen> createState() => _DriverRideHistoryScreenState();
}

class _DriverRideHistoryScreenState extends State<DriverRideHistoryScreen> {
  List<Map<String, dynamic>> _rides = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance.collection('rides')
        .where('driverId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50).get();

    if (mounted) setState(() { _rides = snap.docs.map((d) => d.data()).toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Ride History', style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold, color: DriverColors.black)),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: DriverColors.primary)))
            else if (_rides.isEmpty)
              Expanded(
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history_rounded, size: 80, color: DriverColors.grey.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('No rides yet', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: DriverColors.grey)),
                ])),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: DriverColors.primary,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _rides.length,
                    itemBuilder: (_, i) => _rideCard(_rides[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rideCard(Map<String, dynamic> ride) {
    final status = ride['status'] ?? '';
    final pickup = ride['pickupAddress'] ?? 'Pickup';
    final drop = ride['dropAddress'] ?? 'Drop';
    final fare = (ride['totalPaid'] ?? 0).toDouble();
    final isCompleted = status == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isCompleted ? DriverColors.success : DriverColors.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(status, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: isCompleted ? DriverColors.success : DriverColors.error)),
            ),
            const Spacer(),
            Text('₹${fare.toInt()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: DriverColors.primary)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Column(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: DriverColors.success, shape: BoxShape.circle)),
              Container(width: 1, height: 16, color: DriverColors.grey),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: DriverColors.error, shape: BoxShape.circle)),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pickup, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Text(drop, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ],
      ),
    );
  }
}
