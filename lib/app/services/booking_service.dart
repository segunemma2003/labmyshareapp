import 'package:flutter/material.dart';
import 'package:flutter_app/app/networking/bookings_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/config/keys.dart';
import '/app/models/booking.dart';

class BookingService {
  static final BookingsApiService _api = BookingsApiService();

  static Future<List<Booking>> getBookings({
    String? status,
    String? paymentStatus,
    bool? upcoming,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _api.getBookings(
        status: status,
        paymentStatus: paymentStatus,
        upcoming: upcoming,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      print('Raw API response: $response');
      print('Response type: ${response.runtimeType}');

      if (response != null) {
        // Handle paginated response structure
        if (response is Map<String, dynamic> &&
            response.containsKey('results')) {
          final results = response['results'];
          if (results is List) {
            return results.map((e) => Booking.fromJson(e)).toList();
          }
        }
        // Handle direct list response (fallback)
        else if (response is List) {
          return (response as List).map((e) => Booking.fromJson(e)).toList();
        }
      }

      print('No valid booking data found in response');
      return [];
    } catch (e, stackTrace) {
      print('Get bookings error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<Booking?> getBookingDetails({required String bookingId}) async {
    try {
      final response = await _api.getBooking(bookingId: bookingId);

      print('Booking details response: $response');

      if (response != null) {
        return Booking.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      print('Get booking details error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createBooking({
    required int professional,
    required int service,
    required String scheduledDate,
    required String scheduledTime,
    required bool bookingForSelf,
    String? recipientName,
    String? recipientPhone,
    String? recipientEmail,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String postalCode,
    String? locationNotes,
    String? customerNotes,
    List<Map<String, dynamic>>? selectedAddons,
    required String paymentType,
  }) async {
    try {
      final result = await _api.createBooking(
        professional: professional,
        service: service,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        bookingForSelf: bookingForSelf,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        recipientEmail: recipientEmail,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        postalCode: postalCode,
        locationNotes: locationNotes,
        customerNotes: customerNotes,
        selectedAddons: selectedAddons,
        paymentType: paymentType,
      );

      // Clear booking draft after successful creation
      if (result != null) {
        await Keys.bookingDraft.flush();
      }

      return result;
    } catch (e) {
      print('Create booking error: $e');
      return null;
    }
  }

  static Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final result =
          await _api.cancelBooking(bookingId: bookingId, reason: reason);
      return result != null;
    } catch (e) {
      print('Cancel booking error: $e');
      return false;
    }
  }

  static Future<bool> rescheduleBooking({
    required String bookingId,
    required String requestedDate,
    required String requestedTime,
    required String reason,
  }) async {
    try {
      final result = await _api.rescheduleBooking(
        bookingId: bookingId,
        requestedDate: requestedDate,
        requestedTime: requestedTime,
        reason: reason,
      );
      return result != null;
    } catch (e) {
      print('Reschedule booking error: $e');
      return false;
    }
  }

  static Future<bool> reviewBooking({
    required String bookingId,
    required int overallRating,
    required int serviceRating,
    required int professionalRating,
    required int valueRating,
    required String comment,
    required bool wouldRecommend,
  }) async {
    try {
      final result = await _api.reviewBooking(
        bookingId: bookingId,
        overallRating: overallRating,
        serviceRating: serviceRating,
        professionalRating: professionalRating,
        valueRating: valueRating,
        comment: comment,
        wouldRecommend: wouldRecommend,
      );
      return result != null;
    } catch (e) {
      print('Review booking error: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getBookingMessages(
      {required String bookingId}) async {
    try {
      return await _api.getBookingMessages(bookingId: bookingId);
    } catch (e) {
      print('Get booking messages error: $e');
      return null;
    }
  }

  static Future<bool> sendBookingMessage({
    required String bookingId,
    required String message,
  }) async {
    try {
      final result =
          await _api.sendBookingMessage(bookingId: bookingId, message: message);
      return result != null;
    } catch (e) {
      print('Send booking message error: $e');
      return false;
    }
  }

  // Booking draft management
  static Future<void> saveBookingDraft(Map<String, dynamic> bookingData) async {
    await Keys.bookingDraft.save(bookingData);
  }

  static Future<Map<String, dynamic>?> getBookingDraft() async {
    return await Keys.bookingDraft.read();
  }

  static Future<void> clearBookingDraft() async {
    await Keys.bookingDraft.flush();
  }

  // Helper methods for booking status
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rescheduled':
        return 'Rescheduled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }

  static String getPaymentStatusDisplayText(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Payment Pending';
      case 'deposit_paid':
        return 'Deposit Paid';
      case 'fully_paid':
        return 'Fully Paid';
      case 'refunded':
        return 'Refunded';
      case 'failed':
        return 'Payment Failed';
      default:
        return paymentStatus;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rescheduled':
        return Colors.amber;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static Color getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'deposit_paid':
        return Colors.orange;
      case 'fully_paid':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
