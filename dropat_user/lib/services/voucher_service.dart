import '../models/voucher_model.dart';
import 'api_client.dart';

class VoucherService {
  static final ApiClient _api = ApiClient();

  /// Fetch available vouchers from API
  static Future<List<VoucherModel>> getAvailableVouchers() async {
    try {
      final data = await _api.get('/vouchers');
      final list = data['vouchers'] as List;
      return list.map((v) => VoucherModel(
        id: v['id'],
        code: v['code'],
        discountAmount: (v['discount_amount'] as num).toDouble(),
        description: v['description'],
        minOrderAmount: (v['min_order_amount'] as num).toDouble(),
        validUntil: DateTime.parse(v['valid_until']),
        isPercentage: v['is_percentage'],
        usageLimit: v['max_discount'] != null ? 1 : 1, // mapping approximation
        usedCount: 0,
      )).toList();
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  /// Validate a promo code via API
  static Future<VoucherModel?> validateCode(String code) async {
    try {
      final data = await _api.post('/vouchers/validate', body: {'code': code});
      if (data['valid'] == true) {
        final v = data['voucher'];
        return VoucherModel(
          id: v['id'],
          code: v['code'],
          discountAmount: (v['discount_amount'] as num).toDouble(),
          description: v['description'],
          minOrderAmount: (v['min_order_amount'] as num).toDouble(),
          validUntil: DateTime.parse(v['valid_until']),
          isPercentage: v['is_percentage'],
          usageLimit: 1,
          usedCount: 0,
        );
      }
    } catch (e) {
      print('Error validating voucher: $e');
    }
    return null;
  }
}
