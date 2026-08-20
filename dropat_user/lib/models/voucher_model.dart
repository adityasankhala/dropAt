import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final double discountAmount;
  final String description;
  final double minOrderAmount;
  final DateTime validUntil;
  final bool isPercentage;
  final int usageLimit;
  final int usedCount;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.description,
    required this.minOrderAmount,
    required this.validUntil,
    this.isPercentage = false,
    this.usageLimit = 1,
    this.usedCount = 0,
  });

  bool get isValid =>
      validUntil.isAfter(DateTime.now()) && usedCount < usageLimit;

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrderAmount) return 0;
    if (isPercentage) {
      return (orderAmount * discountAmount / 100).roundToDouble();
    }
    return discountAmount;
  }

  String get discountLabel {
    if (isPercentage) return '${discountAmount.toInt()}% Cashback Guaranteed';
    return '₹${discountAmount.toInt()} discount';
  }

  String get subLabel {
    if (isPercentage) return 'Cashback will go to your balance';
    return 'You just need to pay ₹${minOrderAmount.toInt()}';
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountAmount': discountAmount,
      'description': description,
      'minOrderAmount': minOrderAmount,
      'validUntil': Timestamp.fromDate(validUntil),
      'isPercentage': isPercentage,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
    };
  }

  factory VoucherModel.fromMap(String id, Map<String, dynamic> map) {
    return VoucherModel(
      id: id,
      code: map['code'] ?? '',
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      minOrderAmount: (map['minOrderAmount'] ?? 0).toDouble(),
      validUntil: (map['validUntil'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      isPercentage: map['isPercentage'] ?? false,
      usageLimit: map['usageLimit'] ?? 1,
      usedCount: map['usedCount'] ?? 0,
    );
  }
}
