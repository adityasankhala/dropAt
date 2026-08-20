import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../services/ride_repository.dart';
import 'tip_driver_screen.dart';

class RateTripScreen extends StatefulWidget {
  final String rideId;
  final String driverName;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final double discount;
  final double total;

  const RateTripScreen({
    super.key,
    required this.rideId,
    required this.driverName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.discount,
    required this.total,
  });

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  double _rating = 5;
  final TextEditingController _feedbackCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DropAtColors.white,
      appBar: AppBar(
        backgroundColor: DropAtColors.darkHeader,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate Your Trip',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Driver avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: DropAtColors.primarySurface,
                child: Text(
                  widget.driverName.isNotEmpty
                      ? widget.driverName[0].toUpperCase()
                      : 'D',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: DropAtColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.driverName, style: DropAtTextStyles.h3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: DropAtColors.starYellow),
                  const SizedBox(width: 4),
                  Text('4.9', style: DropAtTextStyles.labelSmall),
                ],
              ),
              const SizedBox(height: 24),

              // Rating
              const Text('How is your trip?',
                  style: DropAtTextStyles.h3),
              const SizedBox(height: 12),
              StarRating(
                rating: _rating,
                size: 44,
                interactive: true,
                onRatingChanged: (r) => setState(() => _rating = r),
              ),
              const SizedBox(height: 20),

              // Feedback
              TextField(
                controller: _feedbackCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your feedback...',
                  hintStyle: DropAtTextStyles.bodyMedium
                      .copyWith(color: DropAtColors.grey),
                  filled: true,
                  fillColor: DropAtColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DropAtRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Trip Detail
              _sectionHeader('Trip Detail'),
              const SizedBox(height: 12),
              _routeDetail(),
              const SizedBox(height: 20),

              // Payment Detail
              _sectionHeader('Payment Detail'),
              const SizedBox(height: 12),
              _paymentDetail(),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: DropAtTextStyles.h3),
    );
  }

  Widget _routeDetail() {
    return Column(
      children: [
        _routeRow(DropAtColors.pickupGreen, widget.pickupAddress),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 1.5,
            height: 16,
            color: const Color(0xFFCCCCCC),
          ),
        ),
        _routeRow(DropAtColors.dropRed, widget.dropAddress),
      ],
    );
  }

  Widget _routeRow(Color color, String address) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: DropAtTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _paymentDetail() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DropAtColors.lightGrey,
        borderRadius: BorderRadius.circular(DropAtRadius.md),
      ),
      child: Column(
        children: [
          _paymentRow('Trip Expense', '₹${widget.fare.toInt()}'),
          if (widget.discount > 0) ...[
            const SizedBox(height: 8),
            _paymentRow(
              'Discount Voucher',
              '-₹${widget.discount.toInt()}',
              valueColor: DropAtColors.primary,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _paymentRow(
            'Total',
            '₹${widget.total.toInt()}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? DropAtTextStyles.label
              : DropAtTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: (isBold
                  ? DropAtTextStyles.price
                  : DropAtTextStyles.priceSmall)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }

  void _submit() async {
    await RideRepository.rateRide(
      rideId: widget.rideId,
      rating: _rating,
      feedback: _feedbackCtrl.text.trim().isNotEmpty
          ? _feedbackCtrl.text.trim()
          : null,
    );

    if (!mounted) return;

    // Navigate to tip screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TipDriverScreen(
          rideId: widget.rideId,
          driverName: widget.driverName,
          rating: _rating,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }
}
