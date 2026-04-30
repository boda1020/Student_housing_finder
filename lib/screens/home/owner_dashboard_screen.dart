import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../owner/add_property_screen.dart';
import '../owner/owner_stats_screen.dart';
import '../notifications/notifications_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _myProperties = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchMyProperties();
  }

  Future<void> _fetchMyProperties() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await supabase
          .from('properties')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myProperties = data as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sarah',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    isArabic ? 'مالك عقار' : 'Property Owner',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.primaryColor),
            title: Text(
              isDark ? (appProvider.translate('light.mode') ?? 'Light Mode') : (appProvider.translate('dark.mode') ?? 'Dark Mode'),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (value) => appProvider.toggleTheme(),
              activeColor: theme.primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.translate_rounded, color: theme.primaryColor),
            title: Text(
              isArabic ? 'English Language' : 'اللغة العربية',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.primaryColor.withOpacity(0.5)),
            onTap: () => appProvider.toggleLanguage(),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              appProvider.translate('logout') ?? 'Logout',
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHomeBody(AppProvider appProvider, ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = appProvider.isDarkMode;
    final isArabic = appProvider.isArabic;
    final userName = authProvider.user?.fullName ?? (isArabic ? 'سارة' : 'Sarah');
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? (appProvider.isDarkMode ? Colors.white : Colors.black);
    final cardColor = theme.cardTheme.color ?? (appProvider.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white);

    return RefreshIndicator(
      onRefresh: _fetchMyProperties,
      color: primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: appProvider.isDarkMode ? Colors.white : theme.primaryColor,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              appProvider.translate('app.title') ?? 'Housing Finder',
              style: TextStyle(
                color: appProvider.isDarkMode ? Colors.white : theme.primaryColor,
                fontWeight: FontWeight.bold
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: appProvider.isDarkMode ? Colors.white : theme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<Map<String, dynamic>>(
                    stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('id', supabase.auth.currentUser?.id ?? '').map((l) => l.isNotEmpty ? l.first : {}),
                    builder: (context, snapshot) {
                      final name = snapshot.data?['full_name'] ?? (isArabic ? 'سارة' : 'Sarah');
                      return Text(
                        '${appProvider.translate('hello') ?? 'Hello'}, $name! 👋',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                      );
                    }
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appProvider.translate('owner.subtitle'),
                    style: TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.home_work_rounded,
                          _myProperties.length.toString(),
                          appProvider.translate('total.properties') ?? 'Total',
                          appProvider.translate('lifetime') ?? 'Lifetime',
                          cardColor,
                          primaryColor,
                          textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.list_alt_rounded,
                          _myProperties.length.toString(),
                          appProvider.translate('active.listings') ?? 'Active',
                          appProvider.translate('active') ?? 'Active',
                          cardColor,
                          primaryColor,
                          textColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.visibility_rounded,
                          '1.2k',
                          appProvider.translate('total.views') ?? 'Views',
                          appProvider.translate('30days') ?? '30 Days',
                          cardColor,
                          primaryColor,
                          textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appProvider.translate('my.properties.title'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const AddPropertyScreen())
                          );
                          if (result == true) {
                            _fetchMyProperties();
                          }
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text(appProvider.translate('add.property')),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ))
                      : _myProperties.isEmpty
                          ? _buildEmptyState(appProvider, textColor!)
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _myProperties.length,
                              itemBuilder: (context, index) {
                                return _buildOwnerPropertyCard(_myProperties[index], isArabic, isDark, primaryColor, textColor!, cardColor);
                              },
                            ),
                  const SizedBox(height: 24),
                  _buildAddAnotherCard(appProvider, isDark, primaryColor, textColor!, cardColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, String period, Color cardColor, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      height: 130,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  period,
                  style: TextStyle(color: Colors.grey[500], fontSize: 7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerPropertyCard(dynamic property, bool isArabic, bool isDark, Color primaryColor, Color textColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  (property['images'] as List).isNotEmpty ? property['images'][0] : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text('4.8', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(property['location'] ?? 'Cairo, Egypt', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${isArabic ? 'ج.م' : '\$'}${property['price']}',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          TextSpan(
                            text: isArabic ? '/شهرياً' : '/mo',
                            style: TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionIcon(Icons.edit_rounded, () {}, isDark),
                        const SizedBox(width: 8),
                        _buildActionIcon(Icons.delete_rounded, () {}, isDark, color: Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color ?? (isDark ? Colors.white70 : Colors.black54)),
      ),
    );
  }

  Widget _buildEmptyState(AppProvider appProvider, Color textColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF5C61F2).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.home_work_rounded, size: 80, color: const Color(0xFF5C61F2).withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'No properties yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first student housing!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAnotherCard(AppProvider appProvider, bool isDark, Color primaryColor, Color textColor, Color cardColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: primaryColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(appProvider.translate('add.another'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            const SizedBox(height: 4),
            Text(appProvider.translate('list.next'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppProvider appProvider, ThemeData theme) {
    final isArabic = appProvider.isArabic;
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.dashboard_rounded, isArabic ? 'الرئيسية' : 'Dashboard', 0, theme),
          _navItem(Icons.analytics_rounded, isArabic ? 'إحصائيات' : 'Stats', 1, theme),
          _navItem(Icons.chat_bubble_rounded, isArabic ? 'الرسائل' : 'Messages', 2, theme),
          _navItem(Icons.person_rounded, isArabic ? 'حسابي' : 'Profile', 3, theme),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, ThemeData theme) {
    final isActive = _currentIndex == index;
    final primaryColor = theme.primaryColor;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? primaryColor : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? primaryColor : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
