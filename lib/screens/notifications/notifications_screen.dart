import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final primaryColor = const Color(0xFF5C61F2);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final bgColor = isDark ? const Color(0xFF0D1217) : Colors.white;

    // Dummy data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': isArabic ? 'رسالة جديدة' : 'New Message',
        'body': isArabic 
            ? 'لديك رسالة جديدة من طالب بخصوص عقارك.' 
            : 'You have a new message from a student regarding your property.',
        'time': isArabic ? 'منذ ساعتين' : '2 hours ago',
        'isRead': false,
        'icon': Icons.chat_bubble_outline,
      },
      {
        'title': isArabic ? 'تمت الموافقة على العقار' : 'Property Approved',
        'body': isArabic 
            ? 'تمت الموافقة على عقارك "استوديو مودرن" وهو الآن متاح.' 
            : 'Your property "Modern Studio" has been approved and is now live.',
        'time': isArabic ? 'منذ 5 ساعات' : '5 hours ago',
        'isRead': true,
        'icon': Icons.check_circle_outline,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appProvider.translate('notifications'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد تنبيهات بعد' : 'No notifications yet',
                    style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notification['isRead'] 
                          ? (isDark ? Colors.white10 : Colors.grey.withOpacity(0.1))
                          : primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification['icon'],
                      color: notification['isRead'] ? Colors.grey : primaryColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    notification['title'],
                    style: TextStyle(
                      color: textColor,
                      fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification['body'],
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => _showNotificationDetails(context, notification, isDark, isArabic, primaryColor, textColor),
                );
              },
            ),
    );
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification, bool isDark, bool isArabic, Color primaryColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notification['icon'], color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        notification['time'],
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'محتوى التنبيه:' : 'Notification Content:',
              style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              notification['body'],
              style: TextStyle(color: textColor, fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'فهمت' : 'Got it',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (notification['title'].contains('Message') || notification['title'].contains('رسالة')) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // هنا ممكن نفتح شاشة الشات مستقبلاً
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isArabic ? 'الرد الآن' : 'Reply Now',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

