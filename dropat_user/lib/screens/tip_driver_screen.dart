import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../services/ride_repository.dart';

class TipDriverScreen extends StatefulWidget {
  final String rideId;
  final String driverName;
  final double rating;

  const TipDriverScreen({
    super.key,
    required this.rideId,
    required this.driverName,
    required this.rating,
  });

  @override
  State<TipDriverScreen> createState() => _TipDriverScreenState();
}

class _TipDriverScreenState extends State<TipDriverScreen> {
  double? _selectedTip;
  final Set<String> _selectedTags = {};

  final List<double> _tipAmounts = [50, 70, 110, 90];
  final List<String> _serviceTags = [
    'Communication',
    'Location Discovery',
    'Driving Skills',
    'Cleanliness',
    'Punctuality',
  ];

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
          'Tips the Driver',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

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
            const SizedBox(height: 8),

            // Star rating display
            StarRating(
              rating: widget.rating,
              size: 36,
            ),
            const SizedBox(height: 28),

            // Tip amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _tipAmounts.map((amount) {
                final isSelected = _selectedTip == amount;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedTip = isSelected ? null : amount;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DropAtColors.primary
                          : DropAtColors.lightGrey,
                      borderRadius:
                          BorderRadius.circular(DropAtRadius.md),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      '₹${amount.toInt()}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? DropAtColors.white
                            : DropAtColors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            Text(
              'Choose other amount...',
              style: DropAtTextStyles.bodySmall.copyWith(
                color: DropAtColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 28),

            // Service quality tags
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What do you think about this service?',
                style: DropAtTextStyles.label,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _serviceTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DropAtColors.primary
                          : DropAtColors.white,
                      borderRadius:
                          BorderRadius.circular(DropAtRadius.round),
                      border: Border.all(
                        color: isSelected
                            ? DropAtColors.primary
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? DropAtColors.white
                            : DropAtColors.darkGrey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _done,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(height: 12),

            // Skip
            GestureDetector(
              onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(
                'Maybe next time',
                style: DropAtTextStyles.bodyMedium.copyWith(
                  color: DropAtColors.grey,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _done() async {
    if (_selectedTip != null) {
      await RideRepository.rateRide(
        rideId: widget.rideId,
        rating: widget.rating,
        tipAmount: _selectedTip,
      );
    }
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}
