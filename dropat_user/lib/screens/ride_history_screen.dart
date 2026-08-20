import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../models/ride_status.dart';
import '../models/vehicle_type.dart';
import '../services/ride_repository.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<RideModel> _rides = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    final rides = await RideRepository.getUserRideHistory();
    if (mounted) setState(() { _rides = rides; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DropAtColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('My Rides', style: DropAtTextStyles.h1),
            ),

            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: DropAtColors.primary),
                ),
              )
            else if (_rides.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_rounded,
                          size: 80, color: DropAtColors.grey.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'No rides yet',
                        style: DropAtTextStyles.h3.copyWith(
                          color: DropAtColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ride history will appear here',
                        style: DropAtTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: DropAtColors.primary,
                  onRefresh: _loadRides,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _rides.length,
                    itemBuilder: (context, index) =>
                        _rideCard(_rides[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rideCard(RideModel ride) {
    final statusColor = ride.status == RideStatus.completed
        ? DropAtColors.success
        : ride.status == RideStatus.cancelled
            ? DropAtColors.error
            : DropAtColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status & date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DropAtRadius.round),
                ),
                child: Text(
                  ride.status.displayLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(ride.createdAt),
                style: DropAtTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DropAtColors.pickupGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 18,
                    color: const Color(0xFFCCCCCC),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DropAtColors.dropRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.pickupAddress.isNotEmpty
                          ? ride.pickupAddress
                          : 'Pickup',
                      style: DropAtTextStyles.bodyMedium.copyWith(
                        color: DropAtColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ride.dropAddress.isNotEmpty
                          ? ride.dropAddress
                          : 'Drop',
                      style: DropAtTextStyles.bodyMedium.copyWith(
                        color: DropAtColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '₹${ride.totalPaid.toInt()}',
                style: DropAtTextStyles.price,
              ),
            ],
          ),

          // Rating
          if (ride.rating != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < ride.rating!
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: DropAtColors.starYellow,
                  ),
                ),
                const Spacer(),
                Text(
                  ride.vehicleType.displayName,
                  style: DropAtTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month]}, ${date.year}';
  }
}
