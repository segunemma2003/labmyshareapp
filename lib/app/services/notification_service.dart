import 'package:flutter_app/app/networking/notification_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/api_service.dart';

class NotificationService {
  static final NotificationApiService _api = NotificationApiService();

  static Future<List<dynamic>?> getNotifications({
    bool? unreadOnly,
    String? notificationType,
  }) async {
    try {
      return await _api.getNotifications(
        unreadOnly: unreadOnly,
        notificationType: notificationType,
      );
    } catch (e) {
      print('Get notifications error: $e');
      return null;
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final result = await _api.getUnreadNotificationCount();
      return result?['unread_count'] ?? 0;
    } catch (e) {
      print('Get unread notification count error: $e');
      return 0;
    }
  }

  static Future<bool> markNotificationAsRead(
      {required String notificationId}) async {
    try {
      final result =
          await _api.markNotificationAsRead(notificationId: notificationId);
      return result != null;
    } catch (e) {
      print('Mark notification as read error: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead() async {
    try {
      final result = await _api.markAllNotificationsAsRead();
      return result != null;
    } catch (e) {
      print('Mark all notifications as read error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getNotificationPreferences() async {
    try {
      return await _api.getNotificationPreferences();
    } catch (e) {
      print('Get notification preferences error: $e');
      return null;
    }
  }

  static Future<bool> updateNotificationPreferences({
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
    try {
      final result = await _api.updateNotificationPreferences(
        bookingUpdatesPush: bookingUpdatesPush,
        paymentUpdatesPush: paymentUpdatesPush,
        remindersPush: remindersPush,
        promotionsPush: promotionsPush,
        bookingUpdatesEmail: bookingUpdatesEmail,
        paymentUpdatesEmail: paymentUpdatesEmail,
        remindersEmail: remindersEmail,
        promotionsEmail: promotionsEmail,
        bookingUpdatesSms: bookingUpdatesSms,
        remindersSms: remindersSms,
      );
      return result != null;
    } catch (e) {
      print('Update notification preferences error: $e');
      return false;
    }
  }

  static Future<bool> registerPushDevice({
    required String deviceToken,
    required String platform,
    required String appVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final result = await _api.registerPushDevice(
        deviceToken: deviceToken,
        platform: platform,
        appVersion: appVersion,
        deviceInfo: deviceInfo,
      );
      return result != null;
    } catch (e) {
      print('Register push device error: $e');
      return false;
    }
  }

  static Future<bool> unregisterPushDevice(
      {required String deviceToken}) async {
    try {
      await _api.unregisterPushDevice(deviceToken: deviceToken);
      return true;
    } catch (e) {
      print('Unregister push device error: $e');
      return false;
    }
  }
}
