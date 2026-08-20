import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/vehicle_type.dart';

class VehicleCard extends StatelessWidget {
  final VehicleType vehicleType;
  final String fareEstimate;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicleType,
    required this.fareEstimate,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DropAtColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? DropAtColors.primary : Colors.black.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? DropAtShadows.medium : DropAtShadows.light,
        ),
        child: Row(
          children: [
            // Vehicle Image/Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? DropAtColors.primarySurface : DropAtColors.lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                vehicleType.icon,
                size: 30,
                color: DropAtColors.primaryDark,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicleType.displayName,
                        style: DropAtTextStyles.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      if (vehicleType == VehicleType.bike)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: DropAtColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ECO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: DropAtColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicleType == VehicleType.bike ? '3' : '5'} min away',
                    style: DropAtTextStyles.bodySmall.copyWith(
                      color: DropAtColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fareEstimate,
                  style: DropAtTextStyles.price,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: DropAtColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
