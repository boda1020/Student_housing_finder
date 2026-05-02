import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  // 1. Send notification
  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    String? type,
    String? data,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': receiverId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // 2. Stream notifications for current user
  Stream<List<Map<String, dynamic>>> getNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // 3. Mark all as read
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .select('id');
  }

  // 4. Mark single as read
  Future<void> markAsRead(String id) async {
    final dynamic queryId = int.tryParse(id) ?? id;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', queryId)
        .select('id');
  }

  // 5. Delete notification
  Future<void> deleteNotification(String id) async {
    final dynamic queryId = int.tryParse(id) ?? id;
    await _supabase.from('notifications').delete().eq('id', queryId);
  }

  // 6. Delete all notifications
  Future<void> deleteAllNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('notifications').delete().eq('user_id', userId);
  }
}
