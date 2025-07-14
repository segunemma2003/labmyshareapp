import 'package:nylo_framework/nylo_framework.dart';

class NotificationModel extends Model {
  static StorageKey key = "notification";

  String? notificationId;
  String? notificationType;
  String? title;
  String? message;
  String? actionUrl;
  bool? isRead;
  String? timeAgo;
  String? createdAt;

  NotificationModel() : super(key: key);

  NotificationModel.fromJson(data) : super(key: key) {
    notificationId = data['notification_id'];
    notificationType = data['notification_type'];
    title = data['title'];
    message = data['message'];
    actionUrl = data['action_url'];
    isRead = data['is_read'];
    timeAgo = data['time_ago'];
    createdAt = data['created_at'];
  }

  @override
  toJson() {
    return {
      'notification_id': notificationId,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'is_read': isRead,
      'time_ago': timeAgo,
      'created_at': createdAt,
    };
  }
}
