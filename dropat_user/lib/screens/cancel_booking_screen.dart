import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  String? _selectedReason;

  final List<String> _reasons = [
    "I don't need this journey.",
    "I want to change the details of the journey.",
    "The driver took too long to be appointed.",
    "I found an alternative ride.",
    "Other reason.",
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
          'Cancel Booking',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image with X
            Center(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 160,
                    height: 110,
                    decoration: BoxDecoration(
                      color: DropAtColors.lightGrey,
                      borderRadius:
                          BorderRadius.circular(DropAtRadius.lg),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 80,
                      color: DropAtColors.grey,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: DropAtColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Question
            Text(
              'Why do you want to cancel?',
              style: DropAtTextStyles.h3,
            ),
            const SizedBox(height: 20),

            // Reasons
            ...List.generate(_reasons.length, (index) {
              final reason = _reasons[index];
              final isSelected = _selectedReason == reason;

              return GestureDetector(
                onTap: () => setState(() => _selectedReason = reason),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DropAtColors.primarySurface
                        : DropAtColors.lightGrey,
                    borderRadius:
                        BorderRadius.circular(DropAtRadius.md),
                    border: isSelected
                        ? Border.all(color: DropAtColors.primary)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Radio
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? DropAtColors.primary
                                : DropAtColors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DropAtColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          reason,
                          style: DropAtTextStyles.bodyMedium.copyWith(
                            color: DropAtColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null
                    ? () => Navigator.pop(context, _selectedReason)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DropAtColors.primary,
                  disabledBackgroundColor: DropAtColors.grey.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Send'),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
