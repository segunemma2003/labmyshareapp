import 'package:flutter/widgets.dart';
import 'package:flutter_app/app/networking/notification_api_service.dart';
import 'package:flutter_app/app/services/notification_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';

class AnalyticsService {
  static final NotificationApiService _api = NotificationApiService();

  static Future<bool> trackEvent({
    required String eventType,
    String? pageUrl,
    String? referrer,
    int? serviceId,
    String? bookingId,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final result = await _api.trackEvent(
        eventType: eventType,
        pageUrl: pageUrl,
        referrer: referrer,
        serviceId: serviceId,
        bookingId: bookingId,
        properties: properties,
      );
      return result != null;
    } catch (e) {
      print('Track event error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserAnalytics() async {
    try {
      return await _api.getUserAnalytics();
    } catch (e) {
      print('Get user analytics error: $e');
      return null;
    }
  }

  // Common tracking methods
  static Future<void> trackPageView(String pageName) async {
    await trackEvent(
      eventType: 'page_view',
      pageUrl: pageName,
      properties: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> trackSearch(String query, {String? category}) async {
    await trackEvent(
      eventType: 'search',
      properties: {
        'search_query': query,
        if (category != null) 'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> trackBookingStarted(
      int serviceId, int professionalId) async {
    await trackEvent(
      eventType: 'booking_started',
      serviceId: serviceId,
      properties: {
        'professional_id': professionalId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> trackBookingCompleted(String bookingId) async {
    await trackEvent(
      eventType: 'booking_completed',
      bookingId: bookingId,
      properties: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
