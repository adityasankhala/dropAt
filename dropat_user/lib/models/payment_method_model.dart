import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PaymentType { cash, gpay, creditCard, paypal }

class PaymentMethodModel {
  final PaymentType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double? balance;
  final String? discountText;

  const PaymentMethodModel({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.balance,
    this.discountText,
  });

  String get value => type.name.toUpperCase();

  static List<PaymentMethodModel> getAll() {
    return [
      const PaymentMethodModel(
        type: PaymentType.gpay,
        label: 'GPay',
        subtitle: 'Balance : ₹2000',
        icon: Icons.g_mobiledata_rounded,
        iconColor: DropAtColors.primary,
        balance: 2000,
        discountText: 'Get ₹60 discount',
      ),
      const PaymentMethodModel(
        type: PaymentType.cash,
        label: 'Cash',
        subtitle: 'Prepare your cash',
        icon: Icons.money_rounded,
        iconColor: DropAtColors.accent,
        discountText: 'Get ₹50 discount',
      ),
      const PaymentMethodModel(
        type: PaymentType.creditCard,
        label: 'Credit Card',
        subtitle: 'Visa or Master Card',
        icon: Icons.credit_card_rounded,
        iconColor: Colors.blueAccent,
        discountText: 'Get ₹30 discount',
      ),
      const PaymentMethodModel(
        type: PaymentType.paypal,
        label: 'Paypal',
        subtitle: 'Pay with your paypal balance',
        icon: Icons.paypal_rounded,
        iconColor: Colors.indigo,
        discountText: 'Get ₹30 discount',
      ),
    ];
  }
}
