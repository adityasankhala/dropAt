import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/payment_method_model.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentType _selected = PaymentType.cash;

  @override
  Widget build(BuildContext context) {
    final methods = PaymentMethodModel.getAll();

    return Scaffold(
      backgroundColor: DropAtColors.white,
      appBar: AppBar(
        backgroundColor: DropAtColors.darkHeader,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark top section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            color: DropAtColors.darkHeader,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Choose Payment Method',
              style: DropAtTextStyles.h3,
            ),
          ),

          // Payment options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                final isSelected = method.type == _selected;

                return GestureDetector(
                  onTap: () =>
                      setState(() => _selected = method.type),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DropAtColors.white,
                      borderRadius:
                          BorderRadius.circular(DropAtRadius.lg),
                      border: Border.all(
                        color: isSelected
                            ? DropAtColors.primary
                            : const Color(0xFFE8E8E8),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: method.iconColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(DropAtRadius.md),
                          ),
                          child: Icon(method.icon,
                              color: method.iconColor, size: 24),
                        ),
                        const SizedBox(width: 14),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.label,
                                style: DropAtTextStyles.label,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method.subtitle,
                                style: DropAtTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // Discount badge
                        if (method.discountText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DropAtColors.primarySurface,
                              borderRadius: BorderRadius.circular(
                                  DropAtRadius.round),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_offer_rounded,
                                    size: 12,
                                    color: DropAtColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  method.discountText!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: DropAtColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(width: 10),

                        // Radio
                        Container(
                          width: 22,
                          height: 22,
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
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: DropAtColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Confirm button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final method = methods.firstWhere(
                    (m) => m.type == _selected,
                  );
                  Navigator.pop(context, method.label);
                },
                child: const Text('Confirm Payment Method'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
