import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/voucher_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback onUse;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discount header
          Row(
            children: [
              Expanded(
                child: Text(
                  voucher.discountLabel,
                  style: DropAtTextStyles.h3.copyWith(
                    color: DropAtColors.primary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onUse,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DropAtColors.primary,
                    borderRadius: BorderRadius.circular(DropAtRadius.sm),
                  ),
                  child: const Text(
                    'Use this',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: DropAtColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            voucher.subLabel,
            style: DropAtTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),

          // Validity
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: DropAtColors.grey),
              const SizedBox(width: 6),
              Text(
                'valid until ${_formatDate(voucher.validUntil)}',
                style: DropAtTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
