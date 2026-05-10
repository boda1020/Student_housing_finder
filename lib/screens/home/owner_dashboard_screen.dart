import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../models/property_model.dart';
import '../../widgets/property/property_card.dart';
import '../property/property_details_screen.dart';
import '../owner/add_property_screen.dart';
import '../owner/edit_property_screen.dart';
import '../owner/owner_stats_screen.dart';
import '../notifications/notifications_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../../data/services/property_service.dart';
import '../../data/services/chat_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final supabase = Supabase.instance.client;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isArabic = appProvider.isArabic;
    final theme = Theme.of(context);

    final List<Widget> screens = [
      _buildHomeBody(appProvider, theme),
      const OwnerStatsScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        drawer: _currentIndex == 0 ? _buildDrawer(appProvider, theme) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _buildBottomNav(appProvider, theme),
      ),
    );
  }

  Widget _buildDrawer(AppProvider appProvider, ThemeData theme) {
    final user = supabase.auth.currentUser;
    return Drawer(
      backgroundColor: const Color(0xFF1A1C20),
      child: Column(
        children: [
          // Header matching screenshot: Blue background with Profile Info
          StreamBuilder<Map<String, dynamic>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', user?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
            builder: (context, snapshot) {
              final name = snapshot.data?['full_name'] ?? "User";
              final avatarUrl = snapshot.data?['avatar_url'];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                color: const Color(0xFF5C61F2),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 45, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "BODA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Language Toggle
          ListTile(
            leading: const Icon(Icons.translate, color: Color(0xFF5C61F2)),
            title: Text(
              appProvider.isArabic ? "English" : "العربية",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () => appProvider.toggleLanguage(),
          ),
          // Theme Toggle
          ListTile(
            leading: Icon(
              appProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: const Color(0xFF5C61F2),
            ),
            title: Text(
              appProvider.isArabic
                  ? (appProvider.isDarkMode ? "الوضع الفاتح" : "الوضع الداكن")
                  : (appProvider.isDarkMode ? "Light Mode" : "Dark Mode"),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: Switch(
              value: appProvider.isDarkMode,
              onChanged: (val) => appProvider.toggleTheme(),
              activeColor: const Color(0xFF5C61F2),
            ),
          ),
          const Spacer(),
          const Divider(color: Colors.white10),
          // Logout at the bottom
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              appProvider.translate('logout') ?? "Logout",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            onTap: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHomeBody(AppProvider appProvider, ThemeData theme) {
    final userId = supabase.auth.currentUser?.id ?? '';
    final propertyService = PropertyService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: propertyService.getOwnerPropertiesStream(),
      builder: (context, snapshot) {
        final myProperties = snapshot.data ?? [];
        int totalViews = 0;
        for (var p in myProperties) {
          totalViews += (p['views'] ?? 0) as int;
        }

        return RefreshIndicator(
          onRefresh: () async {
            // بما أننا نستخدم Stream، الـ RefreshIndicator سيعطي إيحاء بصري للمستخدم
            // ويمكننا إضافة تأخير بسيط ليشعر المستخدم بعملية التحديث
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) setState(() {}); 
          },
          color: theme.primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
            SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu_rounded, color: appProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text(
                appProvider.translate('app_title'),
                style: TextStyle(color: appProvider.isDarkMode ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              actions: [
                _buildNotificationBadge(appProvider, theme),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(appProvider, theme),
                    const SizedBox(height: 32),
                    _buildStatsGrid(myProperties.length, totalViews, appProvider, theme),
                    const SizedBox(height: 40),
                    _buildPropertiesHeader(appProvider, theme),
                    const SizedBox(height: 16),
                    if (snapshot.connectionState == ConnectionState.waiting && myProperties.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (myProperties.isEmpty)
                      _buildEmptyState(appProvider, theme)
                    else
                      ...myProperties.map((p) {
                        final property = Property.fromJson(p);
                        return PropertyCard(
                          property: property,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property, isOwnerView: true)));
                          },
                          actionButtons: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _circleActionBtn(Icons.edit_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditPropertyScreen(property: p)))),
                              const SizedBox(width: 8),
                              _circleActionBtn(Icons.delete_rounded, Colors.redAccent, () => _deleteProperty(p['id'])),
                            ],
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 24),
                    _buildAddAnotherCard(appProvider, theme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildNotificationBadge(AppProvider appProvider, ThemeData theme) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('notifications').stream(primaryKey: ['id']).eq('user_id', supabase.auth.currentUser?.id ?? ''),
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? []).where((n) => n['is_read'] == false).length;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: Icon(Icons.notifications_none_rounded, color: appProvider.isDarkMode ? Colors.white : theme.primaryColor),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeHeader(AppProvider appProvider, ThemeData theme) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', supabase.auth.currentUser?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
      builder: (context, snapshot) {
        final name = snapshot.data?['full_name'] ?? appProvider.translate('user');
        final avatarUrl = snapshot.data?['avatar_url'];
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${appProvider.translate('hello')}, $name! 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  Text(appProvider.translate('owner_subtitle'), style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
              child: (avatarUrl == null || avatarUrl.isEmpty) ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)) : null,
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatsGrid(int count, int views, AppProvider appProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color!;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge!.color!;
    
    return Row(
      children: [
        Expanded(child: _statItem(Icons.home_work_rounded, '$count', appProvider.translate('total_properties'), cardColor, primaryColor, textColor, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _statItem(Icons.list_alt_rounded, '$count', appProvider.translate('active_listings'), cardColor, primaryColor, textColor, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _statItem(Icons.visibility_rounded, '$views', appProvider.translate('total_views'), cardColor, primaryColor, textColor, isDark)),
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color cardColor, Color primaryColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10), maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildPropertiesHeader(AppProvider appProvider, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(appProvider.translate('my_properties_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(appProvider.translate('add_property')),
          style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
        ),
      ],
    );
  }

  Widget _circleActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF252932) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 4,
               offset: const Offset(0, 2),
             )
          ]
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<void> _deleteProperty(dynamic id) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appProvider.translate('delete_property_title')),
        content: Text(appProvider.translate('delete_property_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(appProvider.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appProvider.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final propertyService = PropertyService();
        await propertyService.deleteProperty(id.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.translate('deleted_success')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.translate('error_deleting_property')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState(AppProvider appProvider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.house_rounded, size: 60, color: theme.primaryColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(appProvider.translate('no_properties_added'), style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAnotherCard(AppProvider appProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.primaryColor.withOpacity(isDark ? 0.4 : 0.3), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 40),
            const SizedBox(height: 8),
            Text(appProvider.translate('add_property'), style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1A1D23) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: appProvider.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.analytics_rounded), label: appProvider.translate('views')),
          BottomNavigationBarItem(
            icon: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService().getMyChats(),
              builder: (context, snapshot) {
                final chats = snapshot.data ?? [];
                int totalUnread = 0;
                for (var chat in chats) {
                  totalUnread += (chat['unread_count'] as int? ?? 0);
                }
                return Badge(
                  label: Text(totalUnread.toString()),
                  isLabelVisible: totalUnread > 0,
                  child: const Icon(Icons.chat_bubble_rounded),
                );
              },
            ),
            label: appProvider.translate('messages'),
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: appProvider.translate('profile')),
        ],
      ),
    );
  }
}
