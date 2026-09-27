import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_client.dart';

class PaymentGatewayService {
  static final ApiClient _api = ApiClient();
  late Razorpay _razorpay;
  
  final Function(String) onSuccess;
  final Function(String) onError;

  PaymentGatewayService({required this.onSuccess, required this.onError}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> startPayment({
    required String bookingId,
    required double amount,
    required String method,
  }) async {
    try {
      // 1. Create order on backend
      final orderData = await _api.post('/payments/create-order', body: {
        'booking_id': bookingId,
        'method': method,
      });

      // 2. Launch Razorpay UI
      var options = {
        'key': orderData['key_id'],
        'amount': orderData['amount'],
        'name': 'DropAt',
        'description': 'Booking Payment',
        'order_id': orderData['order_id'],
        'prefill': {
          'contact': '', // fetch from user profile if needed
          'email': ''
        }
      };

      _razorpay.open(options);
    } catch (e) {
      onError(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // 3. Verify on backend
      await _api.post('/payments/verify', body: {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });
      onSuccess(response.paymentId ?? '');
    } catch (e) {
      onError('Payment verification failed on server');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  void dispose() {
    _razorpay.clear();
  }
}
