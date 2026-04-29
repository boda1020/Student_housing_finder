import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dummy data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Message',
        'body': 'You have a new message from a student regarding your property.',
        'time': '2 hours ago',
        'isRead': false,
        'icon': Icons.chat_bubble_outline,
      },
      {
        'title': 'Property Approved',
        'body': 'Your property "Modern Studio" has been approved and is now live.',
        'time': '5 hours ago',
        'isRead': true,
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'New Inquiry',
        'body': 'Someone is interested in your apartment in Cairo.',
        'time': '1 day ago',
        'isRead': true,
        'icon': Icons.info_outline,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read logic
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: notification['isRead'] 
                        ? theme.colorScheme.surfaceVariant 
                        : theme.colorScheme.primaryContainer,
                    child: Icon(
                      notification['icon'],
                      color: notification['isRead'] 
                          ? theme.colorScheme.onSurfaceVariant 
                          : theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification['body']),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'],
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate or mark as read
                  },
                );
              },
            ),
    );
  }
}
