import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LocationInputCard extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropController;
  final VoidCallback? onPickupTap;
  final VoidCallback? onDropTap;
  final VoidCallback? onSwap;

  const LocationInputCard({
    super.key,
    required this.pickupController,
    required this.dropController,
    this.onPickupTap,
    this.onDropTap,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dots and line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: DropAtColors.pickupGreen,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 32,
                color: const Color(0xFFD0D0D0),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: DropAtColors.dropRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Input fields
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: onPickupTap,
                  child: AbsorbPointer(
                    absorbing: onPickupTap != null,
                    child: TextField(
                      controller: pickupController,
                      style: DropAtTextStyles.bodyMedium.copyWith(
                        color: DropAtColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Choose pick up point',
                        hintStyle: DropAtTextStyles.bodyMedium.copyWith(
                          color: DropAtColors.grey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        filled: false,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDropTap,
                  child: AbsorbPointer(
                    absorbing: onDropTap != null,
                    child: TextField(
                      controller: dropController,
                      style: DropAtTextStyles.bodyMedium.copyWith(
                        color: DropAtColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Choose your Drop at',
                        hintStyle: DropAtTextStyles.bodyMedium.copyWith(
                          color: DropAtColors.grey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        filled: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Swap button
          if (onSwap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSwap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DropAtColors.lightGrey,
                  borderRadius: BorderRadius.circular(DropAtRadius.sm),
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: DropAtColors.darkGrey,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
