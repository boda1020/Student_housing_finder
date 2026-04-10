import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  late Stream<List<NotificationModel>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _notificationsStream = _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map((data) => data.map((e) => NotificationModel.fromJson(e)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueAccent = const Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            StreamBuilder<List<NotificationModel>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
                return Text('$unreadCount unread',
                    style: const TextStyle(color: Colors.grey, fontSize: 13));
              },
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.done_all, color: blueAccent, size: 18),
            label: Text('Mark all read',
                style: TextStyle(color: blueAccent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: blueAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications yet', style: TextStyle(color: Colors.grey)),
            );
          }

          final notifications = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(notification: notification);
            },
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueAccent = const Color(0xFF2979FF);

    return Container(
      padding: const EdgeInsets.all(16),
      color: notification.isRead 
          ? Colors.transparent 
          : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: blueAccent, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.content,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Color blueAccent) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.message:
        iconData = Icons.chat_bubble_outline;
        iconColor = blueAccent;
        bgColor = blueAccent.withOpacity(0.15);
        break;
      case NotificationType.propertySaved:
        iconData = Icons.favorite_border;
        iconColor = Colors.pinkAccent;
        bgColor = Colors.pinkAccent.withOpacity(0.15);
        break;
      case NotificationType.propertyView:
        iconData = Icons.home_outlined;
        iconColor = Colors.orangeAccent;
        bgColor = Colors.orangeAccent.withOpacity(0.15);
        break;
      case NotificationType.welcome:
      default:
        iconData = Icons.notifications_none;
        iconColor = Colors.tealAccent;
        bgColor = Colors.tealAccent.withOpacity(0.15);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
