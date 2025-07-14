import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/config/keys.dart';

class PaymentService {
  static final ApiService _api = ApiService();

  static Future<List<dynamic>?> getPayments({
    String? status,
    String? paymentType,
    String? ordering,
  }) async {
    try {
      return await _api.getPayments(
        status: status,
        paymentType: paymentType,
        ordering: ordering,
      );
    } catch (e) {
      print('Get payments error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPaymentSummary() async {
    try {
      return await _api.getPaymentSummary();
    } catch (e) {
      print('Get payment summary error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required String bookingId,
    required String paymentType,
    required String paymentMethodId,
    bool? savePaymentMethod,
    bool? useSavedMethod,
  }) async {
    try {
      return await _api.createPaymentIntent(
        bookingId: bookingId,
        paymentType: paymentType,
        paymentMethodId: paymentMethodId,
        savePaymentMethod: savePaymentMethod,
        useSavedMethod: useSavedMethod,
      );
    } catch (e) {
      print('Create payment intent error: $e');
      return null;
    }
  }

  static Future<bool> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final result = await _api.confirmPayment(
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId,
      );
      return result != null && result['status'] == 'succeeded';
    } catch (e) {
      print('Confirm payment error: $e');
      return false;
    }
  }

  static Future<bool> refundPayment({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final result = await _api.refundPayment(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );
      return result != null;
    } catch (e) {
      print('Refund payment error: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getPaymentMethods() async {
    try {
      return await _api.getPaymentMethods();
    } catch (e) {
      print('Get payment methods error: $e');
      return null;
    }
  }

  static Future<bool> deletePaymentMethod({required int id}) async {
    try {
      await _api.deletePaymentMethod(id: id);
      return true;
    } catch (e) {
      print('Delete payment method error: $e');
      return false;
    }
  }
}
