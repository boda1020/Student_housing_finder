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
    final isArabic = appProvider.isArabic;
    final isDark = appProvider.isDarkMode;
    final user = supabase.auth.currentUser;

    return Drawer(
      child: Column(
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', user?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
            builder: (context, snapshot) {
              final name = snapshot.data?['full_name'] ?? appProvider.translate('user');
              final avatarUrl = snapshot.data?['avatar_url'];
              
              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)]),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white24,
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                          : null,
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(appProvider.translate('property.owner'), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              );
            }
          ),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.primaryColor),
            title: Text(isDark ? (appProvider.translate('light.mode') ?? 'Light Mode') : (appProvider.translate('dark.mode') ?? 'Dark Mode')),
            trailing: Switch(value: isDark, onChanged: (value) => appProvider.toggleTheme(), activeColor: theme.primaryColor),
          ),
          ListTile(
            leading: Icon(Icons.translate_rounded, color: theme.primaryColor),
            title: Text(isArabic ? 'English Language' : 'اللغة العربية'),
            onTap: () => appProvider.toggleLanguage(),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(appProvider.translate('logout') ?? 'Logout', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('properties').stream(primaryKey: ['id']).eq('owner_id', userId).order('created_at', ascending: false),
      builder: (context, snapshot) {
        final myProperties = snapshot.data ?? [];
        int totalViews = 0;
        for (var p in myProperties) {
          totalViews += (p['views'] ?? 0) as int;
        }

        return CustomScrollView(
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
                appProvider.translate('app.title') ?? 'Housing Finder',
                style: TextStyle(color: appProvider.isDarkMode ? Colors.white : theme.primaryColor, fontWeight: FontWeight.bold),
              ),
              actions: [
                _buildNotificationBadge(appProvider, theme),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property, isOwnerView: true))),
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
        );
      }
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
                  Text('${appProvider.translate('hello') ?? 'Hello'}, $name! 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  Text(appProvider.translate('owner.subtitle') ?? 'Manage your listings', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
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
    final cardColor = theme.cardTheme.color!;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge!.color!;
    
    return Row(
      children: [
        Expanded(child: _statItem(Icons.home_work_rounded, '$count', appProvider.translate('total.properties') ?? 'Total', cardColor, primaryColor, textColor)),
        const SizedBox(width: 12),
        Expanded(child: _statItem(Icons.list_alt_rounded, '$count', appProvider.translate('active.listings') ?? 'Active', cardColor, primaryColor, textColor)),
        const SizedBox(width: 12),
        Expanded(child: _statItem(Icons.visibility_rounded, '$views', appProvider.translate('total.views') ?? 'Views', cardColor, primaryColor, textColor)),
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color cardColor, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.1))),
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
        Text(appProvider.translate('my.properties.title') ?? 'My Properties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(appProvider.translate('add.property') ?? 'Add'),
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
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<void> _deleteProperty(dynamic id) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appProvider.translate('delete.property.title')),
        content: Text(appProvider.translate('delete.property.confirm')),
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
              content: Text(appProvider.translate('deleted.success') ?? 'Deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appProvider.translate('error.deleting.property')),
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
            Text(appProvider.translate('no.properties.added'), style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAnotherCard(AppProvider appProvider, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 40),
            const SizedBox(height: 8),
            Text(appProvider.translate('add.property') ?? 'Add New Property', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider, ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: appProvider.translate('home')),
        BottomNavigationBarItem(icon: const Icon(Icons.analytics_rounded), label: appProvider.translate('views')),
        BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_rounded), label: appProvider.translate('messages')),
        BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: appProvider.translate('profile')),
      ],
    );
  }
}
