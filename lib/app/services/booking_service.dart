import 'package:flutter_app/app/networking/bookings_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';
import '/config/keys.dart';

class BookingService {
  static final BookingsApiService _api = BookingsApiService();

  static Future<List<dynamic>?> getBookings({
    String? status,
    String? paymentStatus,
    bool? upcoming,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      return await _api.getBookings(
        status: status,
        paymentStatus: paymentStatus,
        upcoming: upcoming,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      print('Get bookings error: $e');
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

  static Future<Map<String, dynamic>?> getBooking(
      {required String bookingId}) async {
    try {
      return await _api.getBooking(bookingId: bookingId);
    } catch (e) {
      print('Get booking error: $e');
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
}
