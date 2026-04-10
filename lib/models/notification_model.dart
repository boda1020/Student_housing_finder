import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationType { message, propertySaved, propertyView, welcome }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: _parseType(json['type']),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'message':
        return NotificationType.message;
      case 'property_saved':
        return NotificationType.propertySaved;
      case 'property_view':
        return NotificationType.propertyView;
      default:
        return NotificationType.welcome;
    }
  }
}
