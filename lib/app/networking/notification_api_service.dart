import 'package:flutter/material.dart';
import 'package:flutter_app/app/networking/dio/interceptors/lab_my_share_auth_interceptor.dart';
import 'package:flutter_app/app/networking/dio/interceptors/region_interceptor.dart';
import 'package:flutter_app/config/keys.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '/config/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NotificationApiService extends NyApiService {
  NotificationApiService({BuildContext? buildContext})
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

  Future<List<dynamic>?> getNotifications({
    bool? unreadOnly,
    String? notificationType,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly;
    if (notificationType != null)
      queryParams['notification_type'] = notificationType;

    return await network(
      request: (request) =>
          request.get("/notifications/", queryParameters: queryParams),
    );
  }

  Future<Map<String, dynamic>?> getUnreadNotificationCount() async {
    return await network(
      request: (request) => request.get("/notifications/unread-count/"),
    );
  }

  Future<Map<String, dynamic>?> markNotificationAsRead(
      {required String notificationId}) async {
    return await network(
      request: (request) => request.post("/notifications/mark-read/", data: {
        "notification_id": notificationId,
      }),
    );
  }

  Future<Map<String, dynamic>?> markAllNotificationsAsRead() async {
    return await network(
      request: (request) => request.post("/notifications/mark-all-read/"),
    );
  }

  Future<Map<String, dynamic>?> getNotificationPreferences() async {
    return await network(
      request: (request) => request.get("/notifications/preferences/"),
      cacheKey: "notification_preferences",
      cacheDuration: const Duration(hours: 1),
    );
  }

  Future<Map<String, dynamic>?> updateNotificationPreferences({
    bool? bookingUpdatesPush,
    bool? paymentUpdatesPush,
    bool? remindersPush,
    bool? promotionsPush,
    bool? bookingUpdatesEmail,
    bool? paymentUpdatesEmail,
    bool? remindersEmail,
    bool? promotionsEmail,
    bool? bookingUpdatesSms,
    bool? remindersSms,
  }) async {
    Map<String, dynamic> data = {};
    if (bookingUpdatesPush != null)
      data["booking_updates_push"] = bookingUpdatesPush;
    if (paymentUpdatesPush != null)
      data["payment_updates_push"] = paymentUpdatesPush;
    if (remindersPush != null) data["reminders_push"] = remindersPush;
    if (promotionsPush != null) data["promotions_push"] = promotionsPush;
    if (bookingUpdatesEmail != null)
      data["booking_updates_email"] = bookingUpdatesEmail;
    if (paymentUpdatesEmail != null)
      data["payment_updates_email"] = paymentUpdatesEmail;
    if (remindersEmail != null) data["reminders_email"] = remindersEmail;
    if (promotionsEmail != null) data["promotions_email"] = promotionsEmail;
    if (bookingUpdatesSms != null)
      data["booking_updates_sms"] = bookingUpdatesSms;
    if (remindersSms != null) data["reminders_sms"] = remindersSms;

    final result = await network(
      request: (request) =>
          request.put("/notifications/preferences/", data: data),
    );

    // Clear cache after update
    await NyStorage.delete('notification_preferences');
    return result;
  }

  Future<Map<String, dynamic>?> registerPushDevice({
    required String deviceToken,
    required String platform,
    required String appVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    return await network(
      request: (request) => request.post("/notifications/devices/", data: {
        "device_token": deviceToken,
        "platform": platform,
        "app_version": appVersion,
        if (deviceInfo != null) "device_info": deviceInfo,
      }),
    );
  }

  Future<void> unregisterPushDevice({required String deviceToken}) async {
    await network(
      request: (request) => request.delete("/notifications/devices/", data: {
        "device_token": deviceToken,
      }),
    );
  }

  // ===== ANALYTICS ENDPOINTS =====

  Future<Map<String, dynamic>?> trackEvent({
    required String eventType,
    String? pageUrl,
    String? referrer,
    int? serviceId,
    String? bookingId,
    Map<String, dynamic>? properties,
  }) async {
    Map<String, dynamic> data = {"event_type": eventType};
    if (pageUrl != null) data["page_url"] = pageUrl;
    if (referrer != null) data["referrer"] = referrer;
    if (serviceId != null) data["service_id"] = serviceId;
    if (bookingId != null) data["booking_id"] = bookingId;
    if (properties != null) data["properties"] = properties;

    return await network(
      request: (request) => request.post("/analytics/track/", data: data),
    );
  }

  Future<Map<String, dynamic>?> getUserAnalytics() async {
    return await network(
      request: (request) => request.get("/analytics/user/"),
      cacheKey: "user_analytics",
      cacheDuration: const Duration(hours: 1),
    );
  }

  // ===== HEALTH CHECK ENDPOINTS =====

  Future<Map<String, dynamic>?> healthCheck() async {
    return await network(
      request: (request) => request.get("/health/"),
    );
  }

  Future<Map<String, dynamic>?> detailedHealthCheck() async {
    return await network(
      request: (request) => request.get("/health/detailed/"),
    );
  }

  // ===== CACHE MANAGEMENT =====

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await NyStorage.clear("");
  }

  /// Clear specific cache entries
  Future<void> clearServiceCache() async {
    final keys = [
      'service_categories',
      'featured_services',
    ];
    for (String key in keys) {
      await NyStorage.delete(key);
    }
  }

  Future<void> clearProfessionalsCache() async {
    await NyStorage.delete('top_rated_professionals');
  }

  Future<void> clearUserSpecificCache() async {
    final keys = [
      'payment_summary',
      'notification_preferences',
      'user_analytics',
      'payment_methods',
    ];
    for (String key in keys) {
      await NyStorage.delete(key);
    }
  }

  // ===== AUTH HEADERS =====

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    String? token = await Keys.auth.read();
    if (token != null) {
      headers["Authorization"] = "Token $token";
    }
    return headers;
  }

  @override
  Future<bool> shouldRefreshToken() async {
    return false; // Token-based auth doesn't need refresh
  }
}
