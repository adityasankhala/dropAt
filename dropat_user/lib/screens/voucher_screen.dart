import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';
import '../widgets/voucher_card.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  List<VoucherModel> _vouchers = [];
  bool _loading = true;
  String? _error;

  // Demo vouchers for UI preview
  final List<VoucherModel> _demoVouchers = [
    VoucherModel(
      id: '1',
      code: 'DROPAT78',
      discountAmount: 78,
      description: '₹78 discount',
      minOrderAmount: 406,
      validUntil: DateTime(2025, 3, 1),
    ),
    VoucherModel(
      id: '2',
      code: 'CASH10',
      discountAmount: 10,
      description: '10% Cashback Guaranteed',
      minOrderAmount: 0,
      validUntil: DateTime(2025, 2, 10),
      isPercentage: true,
    ),
    VoucherModel(
      id: '3',
      code: 'SAVE100',
      discountAmount: 100,
      description: '₹100 discount',
      minOrderAmount: 384,
      validUntil: DateTime(2025, 2, 26),
    ),
    VoucherModel(
      id: '4',
      code: 'CASH10B',
      discountAmount: 10,
      description: '10% Cashback Guaranteed',
      minOrderAmount: 0,
      validUntil: DateTime(2025, 3, 4),
      isPercentage: true,
    ),
    VoucherModel(
      id: '5',
      code: 'CAMPUS50',
      discountAmount: 100,
      description: '₹100 discount',
      minOrderAmount: 384,
      validUntil: DateTime(2025, 6, 30),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    try {
      final vouchers = await VoucherService.getAvailableVouchers();
      setState(() {
        _vouchers = vouchers.isNotEmpty ? vouchers : _demoVouchers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _vouchers = _demoVouchers;
        _loading = false;
      });
    }
  }

  Future<void> _applyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    final voucher = await VoucherService.validateCode(code);
    if (voucher != null && mounted) {
      Navigator.pop(context, voucher.discountAmount);
    } else {
      // Check demo vouchers
      final demo = _demoVouchers.where(
        (v) => v.code.toUpperCase() == code.toUpperCase(),
      );
      if (demo.isNotEmpty && mounted) {
        Navigator.pop(context, demo.first.discountAmount);
      } else if (mounted) {
        setState(() => _error = 'Invalid promo code');
      }
    }
  }

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
          'Voucher',
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
          // Promo code input
          Container(
            padding: const EdgeInsets.all(20),
            color: DropAtColors.darkHeader,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Have a promo code? enter it here',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DropAtRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _applyCode(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _applyCode,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DropAtColors.primary,
                      borderRadius: BorderRadius.circular(DropAtRadius.md),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: DropAtColors.error,
                  fontSize: 13,
                ),
              ),
            ),

          // Available vouchers
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Voucher available',
              style: DropAtTextStyles.h3,
            ),
          ),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child:
                    CircularProgressIndicator(color: DropAtColors.primary),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _vouchers.length,
                itemBuilder: (context, index) {
                  final voucher = _vouchers[index];
                  return VoucherCard(
                    voucher: voucher,
                    onUse: () =>
                        Navigator.pop(context, voucher.discountAmount),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }
}
