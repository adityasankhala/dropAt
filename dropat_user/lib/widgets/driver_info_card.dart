import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/driver_model.dart';

class DriverInfoCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const DriverInfoCard({
    super.key,
    required this.driver,
    this.onCall,
    this.onMessage,
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: DropAtColors.primarySurface,
            backgroundImage: driver.photoUrl != null
                ? NetworkImage(driver.photoUrl!)
                : null,
            child: driver.photoUrl == null
                ? Text(
                    driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DropAtColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),

          // Name & rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: DropAtTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: DropAtColors.starYellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: DropAtTextStyles.labelSmall,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${driver.vehicleName} · ${driver.vehicleNumber}',
                      style: DropAtTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          if (onCall != null)
            _actionButton(Icons.call_rounded, DropAtColors.primary, onCall!),
          if (onMessage != null) ...[
            const SizedBox(width: 8),
            _actionButton(
                Icons.chat_rounded, DropAtColors.primaryDark, onMessage!),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DropAtRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
