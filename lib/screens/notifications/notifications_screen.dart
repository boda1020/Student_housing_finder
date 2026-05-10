import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../data/services/notification_service.dart';
import '../chat/chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = appProvider.isDarkMode;
    final isAr = appProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.translate('notifications'), 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: appProvider.translate('mark_all_read'),
            onPressed: () => _notificationService.markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: appProvider.translate('delete_all'),
            onPressed: () => _showDeleteAllDialog(context, appProvider),
          ),
        ],
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _notificationService.getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show all notifications (both read and unread)
              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    _buildEmptyState(theme, appProvider),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Dismissible(
                    key: Key(item['id'].toString()),
                    direction: isAr ? DismissDirection.startToEnd : DismissDirection.endToStart,
                    background: Container(
                      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _notificationService.deleteNotification(item['id'].toString());
                    },
                    child: _buildNotificationCard(item, theme, appProvider, isDark),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context, AppProvider appProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appProvider.translate('delete_all_title')),
        content: Text(appProvider.translate('delete_all_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text(appProvider.translate('cancel'))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              appProvider.translate('delete'), 
              style: const TextStyle(color: Colors.red)
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.deleteAllNotifications();
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> data, ThemeData theme, AppProvider appProvider, bool isDark) {
    final bool isRead = data['is_read'] ?? false;
    final String rawTitle = data['title'] ?? '';
    final String displayTitle = appProvider.translate(rawTitle);

    return Container(
      decoration: BoxDecoration(
        color: isRead 
            ? (isDark ? const Color(0xFF1E2530).withOpacity(0.5) : theme.cardTheme.color?.withOpacity(0.6))
            : (isDark ? const Color(0xFF1E2530) : theme.cardTheme.color),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead 
              ? theme.dividerColor.withOpacity(0.05) 
              : theme.primaryColor.withOpacity(0.2)
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (data['type'] == 'chat' ? Colors.blue : Colors.orange).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            data['type'] == 'chat' ? Icons.chat_bubble_outline_rounded : Icons.notifications_active_outlined, 
            color: data['type'] == 'chat' ? Colors.blue : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          displayTitle,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, 
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            data['body'] ?? '', 
            style: TextStyle(
              color: isDark ? Colors.white70 : theme.textTheme.bodySmall?.color, 
              fontSize: 13
            )
          ),
        ),
        onTap: () async {
          await _notificationService.markAsRead(data['id'].toString());
          if (mounted && data['type'] == 'chat' && data['data'] != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: data['data'].toString())));
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            appProvider.translate('no_notifications'),
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
