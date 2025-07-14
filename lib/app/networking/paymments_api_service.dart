import 'package:flutter/material.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PaymmentsApiService extends NyApiService {
  PaymmentsApiService({BuildContext? buildContext})
      : super(
          buildContext,
          decoders: modelDecoders,
          baseOptions: (BaseOptions baseOptions) {
            return baseOptions
              ..connectTimeout = Duration(seconds: 30)
              ..sendTimeout = Duration(seconds: 30)
              ..receiveTimeout = Duration(seconds: 30);
          },
        );

  @override
  String get baseUrl => getEnv('API_BASE_URL',
      defaultValue: 'https://backend.beautyspabyshea.co.uk/api/v1');

  @override
  get interceptors => {
        if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger(),
        LabMyShareAuthInterceptor: LabMyShareAuthInterceptor(),
        RegionInterceptor: RegionInterceptor(),
      };

  Future<List<dynamic>?> getPayments({
    String? status,
    String? paymentType,
    String? ordering,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (status != null) queryParams['status'] = status;
    if (paymentType != null) queryParams['payment_type'] = paymentType;
    if (ordering != null) queryParams['ordering'] = ordering;

    return await network(
      request: (request) =>
          request.get("/payments/", queryParameters: queryParams),
    );
  }

  Future<Map<String, dynamic>?> getPayment({required String paymentId}) async {
    return await network(
      request: (request) => request.get("/payments/$paymentId/"),
    );
  }

  Future<Map<String, dynamic>?> getPaymentSummary() async {
    return await network(
      request: (request) => request.get("/payments/summary/"),
      cacheKey: "payment_summary",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Map<String, dynamic>?> createPaymentIntent({
    required String bookingId,
    required String paymentType,
    required String paymentMethodId,
    bool? savePaymentMethod,
    bool? useSavedMethod,
  }) async {
    return await network(
      request: (request) => request.post("/payments/create-intent/", data: {
        "booking_id": bookingId,
        "payment_type": paymentType,
        "payment_method_id": paymentMethodId,
        if (savePaymentMethod != null) "save_payment_method": savePaymentMethod,
        if (useSavedMethod != null) "use_saved_method": useSavedMethod,
      }),
    );
  }

  Future<Map<String, dynamic>?> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    return await network(
      request: (request) => request.post("/payments/confirm/", data: {
        "payment_intent_id": paymentIntentId,
        "payment_method_id": paymentMethodId,
      }),
    );
  }

  Future<Map<String, dynamic>?> refundPayment({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    return await network(
      request: (request) => request.post("/payments/refund/", data: {
        "payment_id": paymentId,
        "amount": amount.toString(),
        "reason": reason,
      }),
    );
  }

  Future<List<dynamic>?> getPaymentMethods() async {
    return await network(
      request: (request) => request.get("/payments/methods/"),
      cacheKey: "payment_methods",
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<void> deletePaymentMethod({required int id}) async {
    await network(
      request: (request) => request.delete("/payments/methods/$id/"),
    );
    // Clear cache after deletion
    await NyStorage.delete('payment_methods');
  }
}
