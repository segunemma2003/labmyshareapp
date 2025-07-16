import 'package:flutter/material.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BookingsApiService extends NyApiService {
  BookingsApiService({BuildContext? buildContext})
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

  Future<List<dynamic>?> getBookings({
    String? status,
    String? paymentStatus,
    bool? upcoming,
    String? dateFrom,
    String? dateTo,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (status != null) queryParams['status'] = status;
    if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
    if (upcoming != null) queryParams['upcoming'] = upcoming;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    return await network(
      request: (request) =>
          request.get("/bookings/", queryParameters: queryParams),
    );
  }

  Future<Map<String, dynamic>?> createBooking({
    required dynamic professional,
    required dynamic service,
    required String scheduledDate,
    required String scheduledTime,
    required bool bookingForSelf,
    String? recipientName,
    String? recipientPhone,
    String? recipientEmail,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? locationNotes,
    String? customerNotes,
    List<Map<String, dynamic>>? selectedAddons,
    required String paymentType,
  }) async {
    Map<String, dynamic> data = {
      "professional": professional,
      "service": service,
      "scheduled_date": scheduledDate,
      "scheduled_time": scheduledTime,
      "booking_for_self": bookingForSelf,
      "payment_type": paymentType,
    };
    if (addressLine1 != null) data["address_line1"] = addressLine1;
    if (city != null) data["city"] = city;
    if (postalCode != null) data["postal_code"] = postalCode;
    if (!bookingForSelf) {
      data["recipient_name"] = recipientName;
      data["recipient_phone"] = recipientPhone;
      data["recipient_email"] = recipientEmail;
    }
    if (addressLine2 != null) data["address_line2"] = addressLine2;
    if (locationNotes != null) data["location_notes"] = locationNotes;
    if (customerNotes != null) data["customer_notes"] = customerNotes;
    if (selectedAddons != null) data["selected_addons"] = selectedAddons;
    return await network(
      request: (request) => request.post("/bookings/create/", data: data),
    );
  }

  Future<Map<String, dynamic>?> getBooking({required String bookingId}) async {
    return await network(
      request: (request) => request.get("/bookings/$bookingId/"),
    );
  }

  Future<Map<String, dynamic>?> updateBooking({
    required String bookingId,
    String? recipientName,
    String? recipientPhone,
    String? addressLine1,
    String? city,
    String? customerNotes,
  }) async {
    Map<String, dynamic> data = {};
    if (recipientName != null) data["recipient_name"] = recipientName;
    if (recipientPhone != null) data["recipient_phone"] = recipientPhone;
    if (addressLine1 != null) data["address_line1"] = addressLine1;
    if (city != null) data["city"] = city;
    if (customerNotes != null) data["customer_notes"] = customerNotes;

    return await network(
      request: (request) =>
          request.put("/bookings/$bookingId/update/", data: data),
    );
  }

  Future<Map<String, dynamic>?> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    return await network(
      request: (request) => request.post("/bookings/$bookingId/cancel/", data: {
        "reason": reason,
      }),
    );
  }

  Future<Map<String, dynamic>?> rescheduleBooking({
    required String bookingId,
    required String requestedDate,
    required String requestedTime,
    required String reason,
  }) async {
    return await network(
      request: (request) =>
          request.post("/bookings/$bookingId/reschedule/", data: {
        "requested_date": requestedDate,
        "requested_time": requestedTime,
        "reason": reason,
      }),
    );
  }

  Future<Map<String, dynamic>?> reviewBooking({
    required String bookingId,
    required int overallRating,
    required int serviceRating,
    required int professionalRating,
    required int valueRating,
    required String comment,
    required bool wouldRecommend,
  }) async {
    return await network(
      request: (request) => request.post("/bookings/$bookingId/review/", data: {
        "overall_rating": overallRating,
        "service_rating": serviceRating,
        "professional_rating": professionalRating,
        "value_rating": valueRating,
        "comment": comment,
        "would_recommend": wouldRecommend,
      }),
    );
  }

  Future<List<dynamic>?> getBookingMessages({required String bookingId}) async {
    return await network(
      request: (request) => request.get("/bookings/$bookingId/messages/"),
    );
  }

  Future<Map<String, dynamic>?> sendBookingMessage({
    required String bookingId,
    required String message,
  }) async {
    return await network(
      request: (request) =>
          request.post("/bookings/$bookingId/messages/", data: {
        "message": message,
      }),
    );
  }
}
